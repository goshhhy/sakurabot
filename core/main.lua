--init
plugins = {}
pluginsLoaded = false
dofile("config.lua");
dofile("core/ver.lua")
IRCe = require( "irce" )
local socket = require( "socket" )

quit = false

watching = {}

function LoadPlugins() 
    if pluginsLoaded then
        print( "Unloading plugins" )
        for key,val in pairs( plugins ) do
            package.loaded[key] = nil
        end
    end
    print( "Loading Plugins" )
    plugins = {}
    if config.noCore ~= true then
        local plugin = require( "core/corecommands" )
        print("  - corecommands: " .. plugin.name  .. " " .. plugin.version );
        table.insert( plugins, plugin )
    end
    for key,val in pairs(config.plugins) do
        plugin = require( "plugins/" .. val ) 
        print("  - " .. val .. ": " .. plugin.name  .. " " .. plugin.version );
        table.insert( plugins, plugin )
    end
    pluginsLoaded = true
end

print( "Initializing Sakurabot v" .. SAKURA_VERSION )
print( "Using " .. IRCe._VERSION .. " on " .. _VERSION )

local irc = IRCe.new()
print( "Loading IRCe modules" )
assert(irc:load_module(require("irce.modules.base")))
assert(irc:load_module(require("irce.modules.message")))
assert(irc:load_module(require("irce.modules.channel")))
assert(irc:load_module(require("core.irce_pass")))

print( "Configuring IRCe" )

local client = socket.tcp()

irc:set_send_func(function(self, message)
    return client:send(message)
end)

client:settimeout(1)

if ( config.debugLevel > 0 ) then
    irc:set_callback(IRCe.RAW, function(self, send, message)
        print(("%s %s"):format(send and ">>>" or "<<<", message))
    end)
end

irc:set_callback("CTCP", function(self, sender, origin, command, params, pm)
	if command == "VERSION" then
		assert(self:CTCP_REPLY(origin, "VERSION", "Sakurabot v" .. SAKURA_VERSION .. "using " .. IRCe._VERSION .. " on " .. _VERSION ))
	end
end)

irc:set_callback("001", function(self, ...)
    irc:JOIN("#" .. config.username); 
    for key,channel in pairs(config.channels) do 
        print("Joining channel #" .. channel)
        irc:JOIN("#" .. channel);
        watching[channel] = channel
    end
end)

irc:set_callback("PRIVMSG", function(self, sender, origin, message, pm)
    for k,plugin in pairs(plugins) do
        if ( plugin.HandleMessage( self, sender, origin, message, pm ) == true ) then
            return
        end
    end
end)

LoadPlugins();

-- connect

print( "Connecting to server" )

assert(client:connect("irc.chat.twitch.tv", 6667))

assert(irc:PASS("oauth:" .. config.oauth))
assert(irc:NICK(config.username))
assert(irc:USER(config.username, config.username))

-- main loop
print( "SakuraBot Ready" )

while ( quit == false ) do
    irc:process( client:receive() )
    for name,plugin in pairs( plugins ) do
        plugin.Tick( irc )
    end
end
