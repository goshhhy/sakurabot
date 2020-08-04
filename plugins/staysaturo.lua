json = require( "json" )
http = require( "http.request" )
posix = require( "posix" )

lastTimeCheck = nil

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

function DoUptimeCheck( irc )
    print( "doing user uptime check" )
    for k,username in pairs( watching ) do
        local req = http.new_from_uri( "https://api.twitch.tv/kraken/users?login=" .. username )
        req.headers:upsert("accept", "application/vnd.twitchtv.v5+json")
        req.headers:upsert("authorization", "OAuth " .. config.oauth );
        local headers, stream = req:go(1)
        if headers == nil then
            print( "request failed" )
            break
        end
        local body = stream:get_body_as_string()
        local user = json.decode( body ).users[1]
        if user._id == nil then
            print( "couldn't find user" )
            break
        end
        local req = http.new_from_uri( "https://api.twitch.tv/kraken/streams/" .. user._id )
        req.headers:upsert("accept", "application/vnd.twitchtv.v5+json")
        req.headers:upsert("authorization", "OAuth " .. config.oauth );
        local headers, stream = req:go(1)
        if headers == nil then
            print( "request failed" )
            break
        end
        local body = stream:get_body_as_string()
        local stream = json.decode( body ).stream
        if type(stream) ~= "table" then
            print( "  " .. username .. " is not streaming" )
        else
            difference = posix.mktime( posix.gmtime(posix.time()) ) - posix.mktime( posix.strptime( stream.created_at, "%Y-%m-%dT%H:%M:%SZ" ) )
            print( "  " .. username .. " has been streaming for " .. posix.strftime( "%H hours, %M minutes", posix.gmtime( difference ) ) )
            if ( difference > 300 ) then
                if ( math.floor(math.fmod( difference / 60, math.floor( config.staysaturo.interval ) ) ) == 0 ) then
                    irc:PRIVMSG( "#" .. username, username .. " noppTella you have been streaming for " .. posix.strftime( "%H hours and %0M minutes", posix.gmtime( difference ) ) .. " noppTella At this point in your broadcast, you should have consumed " .. math.floor( difference / 3600 * 125 ) .. "ml of Saturo to maintain optimum nutrition noppTella" )
                end
            end
        end
    end
    lastTimeCheck = os.time()
end

function Tick( irc )
    if lastTimeCheck == nil then
        print( "first tick" )
        lastTimeCheck = os.time() - 60
    end
    if os.time() - lastTimeCheck >= 60 then
        DoUptimeCheck( irc )
    end
end

function HandleMessage( self, sender, origin, message, pm )
    if IsAdmin( sender ) then
        if message == config.commandStr .. "sscheck" then
            DoUptimeCheck()
            return true
        elseif message == config.commandStr .. "ssdoall" then

        end
    end
    return false
end

return {
    name = "StaySaturo",
    version = "0.1",
    HandleMessage = HandleMessage,
    Tick = Tick
}