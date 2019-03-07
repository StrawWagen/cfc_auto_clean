
local ConVarFlags = {FCVAR_ARCHIVE, FCVAR_NOTIFY}
local DEFAULT_CLEAN_INTERVAL_IN_SECONDS = "500"
CreateConVar("cfc_autoclean", DEFAULT_CLEAN_INTERVAL_IN_SECONDS, ConVarFlags, "Autocleans the server based on seconds given")

local BlacklistedEntityTypes = {
    ["gmod_wire_turret"] = true,
    ["gmod_turret"] = true
}

local CleanupCommands = {
    ["r_cleardecals"] = true,
    ["stopsound"] = true
}

local function notifyPlayers( count )
    local message = "[CFC_Autoclean] Removed " .. tostring(count) .. "objects."

    print(Message) -- and server
    for _, ply in pairs( player.GetHumans() ) do
        ply:ChatPrint(Message)
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

        local isEquippedWeapon = entity:IsWeapon() and IsValid( entity.Owner )
        local classIsBlacklisted = BlacklistedEntityTypes[entity:GetClass()]
        if isEquippedWeapon or not classIsBlacklisted then continue end

        removedCount = removedCount + 1
        entity:Remove()
    end
    
    MsgAll("[CFC_Autoclean] Removed " .. tostring( removedCount ) .. " objects.")
end

timer.Create("cfc_Autoclean", GetConVar("cfc_autoclean"):GetInt(), 0, cfcCleanServer)

hook.Remove("cfc_CleanOnLag")
hook.Add("APG_lagDetected", "cfc_CleanOnLag", cfcCleanServer)