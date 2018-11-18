-- Create cfc autoclean command
local ConVarFlags = {FCVAR_ARCHIVE, FCVAR_NOTIFY}
local DefaultCleanupIntervalInSeconds = '500'
CreateConVar( 'cfc_autoclean', DefaultCleanupIntervalInSeconds, ConVarFlags, 'Autocleans the server based on seconds given')

-- The table object class strings to remove
local ClassStringsToRemove = {}
ClassStringsToRemove["gmod_wire_turret"] = true
ClassStringsToRemove["gmod_turret"] = true

-- The commands to run on players on cleanup
local PlayerCleanupConsoleCommands = {}
PlayerCleanupFunctions["r_cleardecals"] = true
PlayerCleanupFunctions["stopsound"] = true

-- Get all objects of classes contained in ClassStringsToRemove
local function getObjectsToRemoveInServer()
    local objectsToRemoveInServer = {}

    for classString, _ in pairs( ClassStringsToRemove ) do
        local entitiesOfThisClass = ents.FindByClass( classString )

        table.Add( objectsToRemoveInServer, entitiesOfThisClass )
    end

    return objectsToRemoveInServer
end

-- Run all PlayerCleanupConsoleCommands on ply
local function runCleanupCommandsOnPlayer(ply)
    if not IsValid( ply ) then return end

    for command, _ in pairs( PlayerCleanupConsoleCommands ) do
        ply:ConCommand( command )
    end
end

-- Adds weapons to existingWeapons from newWeapons that are not already there
local function addNewWeaponsToTable(newWeapons, existingWeapons)
    if not IsValid( newWeapons ) then return end
    if not IsValid( existingWeapons ) then return end

    -- Only add non-referenced weapons to allWeps table
    for _, weapon in pairs( newWeapons ) do
        local tableDoesNotHaveWeaponReference = ~table.HasValue( allPlayerWeaponsToRemove, weapon )

        if tableDoesNotHaveWeaponReference then table.insert( existingWeapons, weapon ) end
    end
end

-- Checks to see if a weapons is currently "dropped" (unheld by a player)
local function entityIsUnheldWeapon( entityReference, allPlayerWeapons )
    if not IsValid( entityReference ) then return end
    if not IsValid( allPlayerWeapons ) then return end
    
    if not entityReference:IsWeapon() then return false end
    
    -- Weapon is in player inventory
    if table.HasValue( allPlayerWeapons, entityReference ) then return false end
    
    return true
end

-- Clean server of player weapons and objects of classes in ClassStringsToRemove
function cfcCleanServer()
    local objectsToRemoveInServer = getObjectsToRemoveInServer()
    local removedCount = 0

    local allPlayerWeapons = {}

    -- Run cleanup commands on players and get all held weapons
    for _ , ply in pairs( player.GetHumans() ) do
        ply:ChatPrint('[CFC_Autoclean] Cleaning server..')

        runCleanupCommandsOnPlayer( ply )

        local playerWeapons = ply:GetWeapons()
        addNewWeaponsToTable( playerWeapons, allPlayerWeapons )
    end

    -- Delete all references to non-player weapons & objects in objectsToRemoveFromServer
    for _, entityReference in pairs( ents.GetAll() ) do
        local removeTableContainsReference = table.HasValue( objectsToRemoveInServer, entityReference )

        -- Increment count and remove reference
        if entityIsUnheldWeapon( entityReference, allPlayerWeapons ) or removeTableContainsReference then
            removedCount = removedCount + 1
            entityReference:Remove()
        end
    end

    MsgAll('[CFC_Autoclean] Removed ' .. tostring(removedCount) .. ' objects.')
end

-- Automatically cleanup every cfc_autoclean seconds
timer.Create( 'cfcautoclean', GetConVar('cfc_autoclean'):GetInt(), 0, cfcCleanServer )

hook.Remove( "cfc_cleanOnLag" )
hook.Add( "APG_lagDetected", "cfc_cleanOnLag", cfcCleanServer )
