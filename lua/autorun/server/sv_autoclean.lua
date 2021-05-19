util.AddNetworkString( "CFC_RunAutoClean" )

local ConVarFlags = {FCVAR_ARCHIVE, FCVAR_NOTIFY}
local DEFAULT_CLEAN_INTERVAL_IN_SECONDS = "500"
CreateConVar( "cfc_autoclean", DEFAULT_CLEAN_INTERVAL_IN_SECONDS, ConVarFlags, "Autocleans the server based on seconds given" )

local clearingServerMessages = {
    "[CFC - AutoClean] Scrubbing the ethernet...",
    "[CFC - AutoClean] Dusting the heatsinks...",
    "[CFC - AutoClean] Applying more thermal paste...",
    "[CFC - AutoClean] Tidying...",
    "[CFC - AutoClean] Replacing internet juice...",
    "[CFC - AutoClean] Washing threads...",
    "[CFC - AutoClean] Cleaning forks...",
    "[CFC - AutoClean] Downloading more RAM...",
    "[CFC - AutoClean] Updating drivers...",
    "[CFC - AutoClean] Installing more antivirus...",
    "[CFC - AutoClean] Brushing teeth...",
    "[CFC - AutoClean] Cleaning behind the ears...",
    "[CFC - AutoClean] Vacuuming...",
    "[CFC - AutoClean] Taking vitamins...",
    "[CFC - Antibullying] Calling moms...",
    "[CFC - Antiminge] Removing users...",
    "[CFC - Criminal] Stealing copies of phatmania...",
    "[CFC - Raincore] Soaking your builds...",
    "[CFC - Minecraftcore] Removing legokidlogan's minecraft E2...",
    "[CFC - Anticheat] Removing RadioJackal...",
    "[CFC - Antispam] Removing chat...",
    "[CFC - Antimicspam] Removing voicechat...",
    "[CFC - Robostaff] Banning all humans...",
    "[CFC - Spartan] Deleting boats...",
    "[CFC - Minecraft] Commencing crash...",
    "[CFC - Phatcore] Removing minges...",
    "[CFC - Antiphatcore] Commencing dazzling...",
    "[CFC - Awards] Handing MetaKnight award for having lemon cat...",
    "[CFC - Piracy] Downloading pirated phatmania...",
    "[CFC - Antirdm] Calling admins...",
    "[CFC - Musiccore] Purchasing phatmania album...",
    "[CFC - Fashion] Purchasing phatso merchandise...",
    "[CFC - Mingecore] Spawning emitters...",
    "[CFC - Chefcore] Burning the food...",
    "[CFC - Chefcore] Consulting Gordon Ramsay...",
    "[CFC - Discordmanager] Removing permissions...",
    "[CFC - Fallcore] Did you know you can't reduce the amount of damage you take from falling by crouching and looking down before you impact a surface?"
}

local function getClearingServerMessage()
    return table.Random( clearingServerMessages )
end

local function runCleanupCommandsOnPlayers()
    local notificationMsg = getClearingServerMessage()

    net.Start( "CFC_RunAutoClean" )
        net.WriteString( notificationMsg )
    net.Broadcast()
end

local function removeUnownedWeapons()
    local removedCount = 0

    for _, entity in pairs( ents.GetAll() ) do
        if IsValid( entity ) then
            local isUnownedWeapon = entity:IsWeapon() and not IsValid( entity.Owner )

            if isUnownedWeapon then
                removedCount = removedCount + 1
                entity:Remove()
            end
        end
    end

    if removedCount == 0 then return end

    local message = "Removed " .. tostring( removedCount ) .. " object"

    if removedCount > 1 then message = message .. "s" end

    notifyPlayers( message )
end

local function runCleanupFunctions()
    runCleanupCommandsOnPlayers()
    removeUnownedWeapons()
end

timer.Create( "CFC_AutoClean", GetConVar( "cfc_autoclean" ):GetInt(), 0, runCleanupFunctions )

hook.Remove( "APG_lagDetected", "CFC_CleanOnLag" )
hook.Add( "APG_lagDetected", "CFC_CleanOnLag", runCleanupFunctions )
