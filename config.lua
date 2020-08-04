config = {
    -- twitch
    username = "staysaturobot",
    oauth = "x662ll07gqec4fu9tgniobz3rbz1s2",
    channels = {
        "ennopp112",
        --"sayvitv",
        --"ceehe",
    },
    -- admining
    commandStr = "??",
    admins = {
        "goshhhy",
    },
    -- dev
    debugLevel = 1,
    -- plugin config
    plugins = {
        "staysaturo"
    },
    mjolk = {
        participate = "off", -- off, pretend, on
        giverUsername = "goshhhy", -- should be "StreamElements" for prod
    },
    targetresponse = {
        enable = false;
        noppUsername = "EnNopp112",
        triggerPhrase = "filename is",
        response = "filename is saturo",
        oneshot = true,
    },
    staysaturo = {
        interval = 60 -- in minutes
    }
}