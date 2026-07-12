local lib = {}

local component = component or require("component")
local invoke = component.invoke

local bootaddr, invoke = computer.getBootAddress()
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

return lib
