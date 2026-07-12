local lib = {}

local component = require("component")
local computer = require("computer")
local invoke = component.invoke
local bootaddr = computer.getBootAddress()

local function loadfile(addr, file)
    local handle = assert(invoke(addr, "open", file))
    local buffer = ""
    repeat
        local data = invoke(addr, "read", handle, math.maxinteger or math.huge)
        buffer = buffer .. (data or "")
    until not data
    invoke(addr, "close", handle)
    return load(buffer, "=" .. file, "bt", _G)
end

dAddrs = loadfile("/FROS0P5/core/config.lua")["DisksAddrs"]
dAddrs["SYS"] = bootaddr

return lib
