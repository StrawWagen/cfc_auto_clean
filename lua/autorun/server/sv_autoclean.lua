
local ConVarFlags = {FCVAR_ARCHIVE, FCVAR_NOTIFY}
local DEFAULT_CLEAN_INTERVAL_IN_SECONDS = "500"
CreateConVar("cfc_autoclean", DEFAULT_CLEAN_INTERVAL_IN_SECONDS, ConVarFlags, "Autocleans the server based on seconds given")

local CleanupCommands = {
    ["r_cleardecals"] = true,
    ["stopsound"] = true
}

local function notifyPlayers( count )
    local message = "[CFC_Autoclean] Removed " .. tostring(count) .. " objects."

    print(message) -- and server
    for _, ply in pairs( player.GetHumans() ) do
        ply:ChatPrint(message)
    end
end

local function runCleanupCommandsOnPlayers()
    for _, ply in pairs( player.GetHumans() ) do
        for command, _ in pairs( CleanupCommands ) do
            ply:ConCommand( command )
        end

        ply:ChatPrint("[CFC_Autoclean] Cleaning server...")
    end
end

function cfcCleanServer()
    local removedCount = 0
    
    runCleanupCommandsOnPlayers()

    for _, entity in pairs( ents.GetAll() ) do
        if not IsValid( entity ) then continue end

        local isUnownedWeapon = entity:IsWeapon() and not IsValid( entity.Owner )
        
        if isUnownedWeapon then
            removedCount = removedCount + 1
            entity:Remove()
        end
    end
    
    notifyPlayers( removedCount )
end

timer.Create("cfc_Autoclean", GetConVar("cfc_autoclean"):GetInt(), 0, cfcCleanServer)

hook.Remove("cfc_CleanOnLag")
hook.Add("APG_lagDetected", "cfc_CleanOnLag", cfcCleanServer)
