local cleanupCommands = {
    "r_cleardecals"
}

local function notifyPlayer( notification )
    local message = "[CFC_AutoClean] " .. notification

    print( message )
end

net.Receive( "CFC_RunAutoClean", function()
    for _, command in pairs( cleanupCommands ) do
        RunConsoleCommand( command )
    end
end )