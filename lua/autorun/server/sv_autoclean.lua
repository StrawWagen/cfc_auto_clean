-- Create cfc autoclean command
local ConVarFlags = {FCVAR_ARCHIVE, FCVAR_NOTIFY}
local DefaultCleanupIntervalInSeconds = '500'
CreateConVar( 'cfc_autoclean', DefaultCleanupIntervalInSeconds, ConVarFlags, 'Autocleans the server based on seconds given')

-- The class strings to remove
local Contraband = {}
Contraband["gmod_wire_turret"] = true
Contraband["gmod_turret"] = true

-- The commands to run on players on cleanup
local SearchProtocols = {}
SearchProtocols["r_cleardecals"] = true
SearchProtocols["stopsound"] = true

local function isContraband(ent)
    return Contraband[ent:GetClass()]
end

local function searchPlayer(ply)
    -- They got away!
    if not IsValid( ply ) then return end

    ply:ChatPrint('[CFC_Autoclean] You are being cleaned. Please remain calm.')
    
    for protocol, _ in pairs( SearchProtocols ) do
        ply:ConCommand( protocol )
    end
end

local function searchAllPlayers()
    for _ , ply in pairs( player.GetHumans() ) do
        searchPlayer( ply )
    end
end

local function isUnregisteredFirearm( ent )
    if ent:IsWeapon() and IsValid( ent.Owner ) then return true end
    
    return false
end

local function removeAllWrongdoers()
    local justicesServed = 0
    
    for _, ent in pairs( ents.GetAll() ) do
        if not IsValid( ent ) then continue end
        
        if isUnregisteredFirearm( ent ) or isContraband( ent ) then
            justicesServed = justicesServed + 1
            ent:Remove()
        end
    end
    
    print( '[CFC_Autoclean] Removed ' .. tostring( justicesServed ) .. ' objects.' )
end

function cfcCleanTheStreets()
    print( '[CFC_Autoclean] Cleaning server...' )
   
    searchAllPlayers()
    
    removeAllWrongdoers()
end

-- Automatically cleanup every cfc_autoclean seconds
timer.Create( 'cfc_autoclean_timer', GetConVar('cfc_autoclean'):GetInt(), 0, cfcCleanTheStreets )

hook.Remove( "CFC_CleanOnLag" )
hook.Add( "APG_lagDetected", "CFC_CleanOnLag", cfcCleanTheStreets )
