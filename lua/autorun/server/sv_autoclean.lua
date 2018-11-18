	CreateConVar('cfc_autoclean','500',{FCVAR_ARCHIVE, FCVAR_NOTIFY },'Autocleans the server based on seconds given')
	
function cfcCleanServer()
	local player_weps = {}
	local turrets = table.Add(ents.FindByClass("gmod_wire_turret"),ents.FindByClass("gmod_turret"))
	local count = 0
	--Manual fix for removing weapons held by player
	for _ , v in pairs(player.GetHumans()) do
		v:ChatPrint('[CFC_Autoclean] Cleaning server..')
		--Also cleanup decals and sounds while we're here
		v:ConCommand('r_cleardecals')
		v:ConCommand('stopsound')

		--
		local wp = v:GetWeapons()
		for _,m in pairs(wp) do
			if (not table.HasValue(player_weps, m))then
				table.insert(player_weps, m)
			end
		end
	end
	
	for k, v in pairs( ents.GetAll() ) do
			if v:IsWeapon() and not (table.HasValue(player_weps,v) or (table.HasValue(turrets,v))) then
				count = count + 1
				v:Remove()
			end
	end
	
	MsgAll('[CFC_Autoclean] Removed ' .. tostring(count) .. ' objects.')
end

timer.Create('cfcautoclean',GetConVar('cfc_autoclean'):GetInt(),0,cfcCleanServer)

hook.Remove("cfcCleanOnLag")
hook.Add( "APG_lagDetected", "cfcCleanOnLag", cfcCleanServer)