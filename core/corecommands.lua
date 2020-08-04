--[[]
This built-in "plugin" provides the basic commands for SakuraBot.
It also is intended to provide an example of how to write a plugin.
]]

function IsAdmin( sender )
    admin = nil
    for k,name in pairs( config.admins ) do
        if ( sender[1] == name ) then
            admin = name
        end
    end
    if admin == nil then
        return false
    else
        return true
    end
end

function Tick()

end

function HandleMessage( self, sender, origin, message, pm )
    if string.sub( message, 1, 2 ) == config.commandStr then
        local command = string.sub( message, 3 )
        local arg0 = command
        local args = ""
        if string.find( command, " " ) ~= nil then
            arg0 = string.sub( command, 1, string.find( command, " " ) - 1 )
            args = string.sub( command, string.find( command, " " ) + 1 )
        end

        for cmd,func in pairs( commands ) do
            if ( arg0 == cmd ) then
                print( sender[1] .. " running command \"" .. command .. "\"")
                func( self, sender, origin, args, pm )
                return true;
            end
        end
    end
end

-- Commands

function Exec( self, sender, origin, args, pm )
    if IsAdmin( sender ) then
        local f = loadstring( args )
        local result = f();
        if ( result == nil ) then
            result = "nil"
        end
        self:PRIVMSG( origin, sender[1] .. " result: " .. result )
    else
        self:PRIVMSG( origin, sender[1] .. " , you are not authorized to run this command" )
    end
end

function Hi( self, sender, origin, args, pm )
    self:PRIVMSG( origin, "hey there, " .. sender[1] .. " !" )
end

function Ver( self, sender, origin, args, pm )
    self:PRIVMSG( origin, "Sakurabot v" .. SAKURA_VERSION .. "using " .. IRCe._VERSION .. " on " .. _VERSION )
end

function Join( self, sender, origin, args, pm )
    if IsAdmin( sender ) or sender[1] == args then
        self:PRIVMSG( origin, sender[1] .. " , got it. Joining " .. args .. "'s channel." )
        self:JOIN( "#" .. args )
        watching[args] = args
    else
        self:PRIVMSG( origin, sender[1] .. " , you are not authorized to run this command" )
    end
end

function Leave( self, sender, origin, args, pm )
    if ( args == config.username ) then
        self:PRIVMSG( origin, sender[1] .. " , I can't leave my own channel!" )
    elseif IsAdmin( sender ) or sender[1] == args then
        self:PRIVMSG( origin, sender[1] .. " , got it. Leaving " .. args .. "'s channel." )
        self:PART( "#" .. args )
        watching[args] = nil
    else
        self:PRIVMSG( origin, sender[1] .. " , you are not authorized to run this command" )
    end
end

function JoinMe( self, sender, origin, args, pm )
    self:PRIVMSG( origin, sender[1] .. " , got it. Joining your channel." )
    self:JOIN( "#" .. sender[1] )
    watching[sender[1]] = sender[1]
end

function GoAway( self, sender, origin, args, pm )
    if ( ( "#" .. sender[1] ) == origin ) then
        self:PRIVMSG( origin, sender[1] .. " , got it. Going away now." )
        self:PART( origin )
        watching[sender[1]] = nil
    else
        self:PRIVMSG( origin, sender[1] .. " , you are not authorized to run this command" )
    end
end

function Reload( self, sender, origin, args, pm )
    if IsAdmin( sender ) then
        self:PRIVMSG( origin, sender[1] .. " , reloading plugins" )
        LoadPlugins()
        self:PRIVMSG( origin, sender[1] .. " , reload completed!" )
    else
        self:PRIVMSG( origin, sender[1] .. " , you are not authorized to run this command" )
    end
end

commands = {}
function AddCommand( command, func )
    commands[command] = func
end

AddCommand( "exec", Exec )
AddCommand( "hi", Hi )
AddCommand( "ver", Ver )
AddCommand( "join", Join )
AddCommand( "leave", Leave )
AddCommand( "joinme", JoinMe )
AddCommand( "goaway", GoAway )
AddCommand( "reload", Reload )

return {
    name = "CoreCommands",
    version = SAKURA_VERSION,
    HandleMessage = HandleMessage,
    Tick = Tick
}