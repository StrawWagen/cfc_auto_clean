local cleanupCommands = {
    ["r_cleardecals"] = true
}

local function notifyPlayer( notification )
    local message = "[CFC_AutoClean] " .. notification

    print( message )
end

net.Receive( "CFC_RunAutoClean", function() 
    for command, _ in pairs(cleanupCommands) do
        RunConsoleCommand( command )
    end
end )
