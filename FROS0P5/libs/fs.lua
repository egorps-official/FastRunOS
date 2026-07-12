local lib = {}

--[[
Codes:
0x{type}{scriptNum}{code}

Code:
  0x01 - Library:
    0x01 - fs:
      0x00 - INVALID_ADDRESS

Message:
  INVALID_ADDRESS - Invalid Address or not a disk
]]--

local function getLog(code, msg, status)
  return {
    "log": {
      "Msg": msg,
      "Code": code,
      "Status": status
    }
  }
end

local component = require("component")
local computer = require("computer")
local invoke = component.invoke
local bootaddr = computer.getBootAddress()

function lib.loadfile(addr, file)
  local handle = assert(invoke(addr, "open", file))
  local buffer = ""
  repeat
      local data = invoke(addr, "read", handle, math.maxinteger or math.huge)
      buffer = buffer .. (data or "")
  until not data
  invoke(addr, "close", handle)
  return load(buffer, "=" .. file, "bt", _G)
end

function lib.scanDisks()
  local scanned = {}
  
  for addr, componentType in component.list() do
      if componentType == "filesystem" then
          table.insert(scanned, addr)
      end
  end
end

function lib.getDisk(addr)
  if not (component.type(addr) == "filesystem") then
    getLog(0x010100, "INVALID_ADDRESS", 2) -- 0 - все ок, 1 - предупреждение, 3 - ошибка, 4 - инфо
  end
end

lib.addrs = loadfile("/FROS0P5/core/config.lua")["DisksAddrs"]
lib.addrs["SYS"] = bootaddr

return lib
