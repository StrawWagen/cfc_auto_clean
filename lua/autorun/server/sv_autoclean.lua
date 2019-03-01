
local ConVarFlags = {FCVAR_ARCHIVE, FCVAR_NOTIFY}
local DefaultCleanIntervalInSeconds = "500"	
CreateConVar("cfc_autoclean", DefaultCleanIntervalInSeconds, ConVarFlags, "Autocleans the server based on seconds given")

local BlacklistedEntityTypes = {
	["gmod_wire_turret"] = true,
	["gmod_turret"] = true
}

local CleanupCommands = {
	["r_cleardecals"] = true,
	["stopsound"] = true
}

local function runCleanupCommandsOnPlayers()
	if not IsValid( ply ) then return end

	for k,v in pairs( player.GetHumans() ) do
		for command, _ in pairs( CleanupCommands ) do
			ply:ConCommand( command )
		end
	end
end

function cfcCleanServer()
	local removedCount = 0
	
	runCleanupCommandsOnPlayers()

	for _, entity in pairs( ents.GetAll() ) do
		if not IsValid( entity ) then continue end
		if (entity:IsWeapon() and IsValid( entity.Owner )) or not BlacklistedEntityTypes[entity:GetClass()] then continue end

		removedCount++
		entity:Remove()
	end
	
	MsgAll("[CFC_Autoclean] Removed " .. tostring( removedCount ) .. " objects.")
end

timer.Create("cfc_autoclean", GetConVar("cfc_autoclean"):GetInt(), 0, cfcCleanServer)

hook.Remove("cfc_CleanOnLag")
hook.Add("APG_lagDetected", "cfc_CleanOnLag", cfcCleanServer)