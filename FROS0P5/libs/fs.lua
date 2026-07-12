-- FastRunOS
-- By egorps
-- Licensed by MIT License

-- File system library for "disk name by letter" systems

local lib = {}

--[[
Codes:
0x{type}{scriptNum}{code}

Code:
  0x01 - Library:
    0x01 - fs:
      0x01 - INVALID_ADDRESS
      0x02 - UNSCANNED_DISK
      0x03 - LETTER_MAP_NOT_FOUND

Message:
  INVALID_ADDRESS - Invalid Address or not a disk
  UNSCANNED_DISK - Attempt to get access to the disk before it gets scanned (by "scanDisks" method)
  LETTER_MAP_NOT_FOUND - index "DisksAddrs" in config.lua wasn't found
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

lib.addrs = nil

function lib.init()
  local config = loadfile("/FROS0P5/core/config.lua")
  lib.addrs = config and config["DisksAddrs"] or nil
  if lib.addrs == nil then return getLog(0x010103, "LETTER_MAP_NOT_FOUND", 2) end
  lib.addrs["SYS"] = bootaddr
  return getLog(0x010100, "OK", 0)
end

function lib.scanDisks()
  local scanned = {}
  
  for addr, componentType in component.list() do
    if componentType == "filesystem" then
      table.insert(scanned, addr)
      local letter
      for i, v in lib.addrs do
        if v == addr then letter = i break end
      end
      if not letter then
        for i, v in lib.addrs do
          if v == "" then lib.addrs[i] = addr break end
        end
      end
    else
      return getLog(0x010101, "INVALID_ADDRESS", 2)
    end
  end
end

function lib.getDisk(addr)
  if component.type(addr) == "filesystem" then
    local info = getLog(0x010100, "OK", 0)
    local proxy = component.proxy(addr)
    local letter
    for i, v in lib.addrs do
      if v == addr then letter = i break end
    end
    if not letter then
      return getLog(0x010102, "UNSCANNED_DISK", 2)
    end
    info["Letter"] = letter
    info["Filesystem"] = proxy
    info["spaceTotal"] = proxy.spaceTotal()
    info["spaceUsed"] = proxy.spaceUsed()
    info["Label"] = proxy.getLabel()
    info["isReadOnly"] = proxy.isReadOnly()
    return info
  else
    return getLog(0x010101, "INVALID_ADDRESS", 2)
  end
end

function lib.format(addr)
    local diskInfo = lib.getDisk(addr)

    if not diskInfo or diskInfo.log.Code == 0x010101 or diskInfo.log.Code == 0x010102 then
        return getLog(0x010101, "INVALID_ADDRESS", 2)
    end
  
    local proxy = diskInfo.Filesystem

    local function clearDirectory(path)
        local list = proxy.list(path)
        for _, name in ipairs(list) do
            local fullPath = path == "/" and "/" .. name or path .. "/" .. name
            if proxy.isDirectory(fullPath) then
                clearDirectory(fullPath)
                proxy.remove(fullPath)
            else
                proxy.remove(fullPath)
            end
        end
    end

    clearDirectory("/")
    return getLog(0x010100, "OK", 0)
end

return lib
