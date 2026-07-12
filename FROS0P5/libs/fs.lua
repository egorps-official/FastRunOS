local lib = {}

--[[
Codes:
0x{type}{scriptNum}{code}

Code:
  0x01 - Library:
    0x01 - fs:
      0x01 - INVALID_ADDRESS

Message:
  INVALID_ADDRESS - Invalid Address or not a disk
]]--

local function getLog(code, msg, status)
  return {
    ["log"] = {
      ["Msg"] = msg,
      ["Code"] = code,
      ["Status"] = status
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

function lib.scanDisks(onlyFormated)
  if onlyFormated == nil then onlyFormated = true end
  local scanned = {}
  
  for addr, componentType in component.list() do
      if componentType == "filesystem" or (componentType == "drive" and onlyFormated == false) then
          table.insert(scanned, addr)
      end
  end
end

function lib.getDisk(addr)
  local info = getLog(0x010100, "OK", 0)
  if component.type(addr) == "filesystem" then
    local proxy = component.proxy(addr)
    info["Formated"] = true
    info["Filesystem"] = proxy
    info["spaceTotal"] = proxy.spaceTotal()
    info["spaceUsed"] = proxy.spaceUsed()
    info["Label"] = proxy.getLabel()
    info["isReadOnly"] = proxy.isReadOnly()
  elseif component.type(addr) == "drive" then
    local proxy = component.proxy(addr)
    info["Formated"] = false
    info["Filesystem"] = proxy
    info["spaceTotal"] = proxy.getCapacity()
    info["Label"] = proxy.getLabel()
  else
    return getLog(0x010101, "INVALID_ADDRESS", 2)
  end
  return info
end

lib.addrs = loadfile("/FROS0P5/core/config.lua")["DisksAddrs"]
lib.addrs["SYS"] = bootaddr

return lib
