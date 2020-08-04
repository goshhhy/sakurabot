--- Include ---
local _NAME = (...):match("^(.+)%..+%.") -- Get parent module.

local IRCe = require("irce")
local util = require("irce.util")
--- ==== ---


return {
    senders = {
		PASS = function(self, state, pass)
			return "PASS " .. pass
		end,
	},
}