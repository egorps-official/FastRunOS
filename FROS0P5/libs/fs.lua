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
      0x04 - INVALID_PATH

Message:
  INVALID_ADDRESS - Invalid Address or not a disk
  UNSCANNED_DISK - Attempt to get access to the disk before it gets scanned (by "scanDisks" method)
  LETTER_MAP_NOT_FOUND - index "DisksAddrs" in config.lua wasn't found
  INVALID_PATH - Invalid Path
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
local config
local serialization = require("serialization")

local function loadfile(addr, file)
  local handle = assert(invoke(addr, "open", file))
  local buffer = ""
  repeat
    local data = invoke(addr, "read", handle, math.maxinteger or math.huge)
    buffer = buffer .. (data or "")
  until not data
  invoke(addr, "close", handle)
  return load(buffer, "=" .. file, "bt", _G)()
end

lib.addrs = nil

function lib.init()
  config = loadfile(bootaddr, "/FROS0P5/core/config.lua")
  lib.addrs = config and config["DiskAddrs"] or nil
  if lib.addrs == nil then return getLog(0x010103, "LETTER_MAP_NOT_FOUND", 2) end
  lib.addrs["SYS"] = bootaddr
  return getLog(0x010100, "OK", 0)
end

function lib.getLetter(addr)
  for i, v in lib.addrs do
    if v == addr then return i end
  end
end

function lib.scanDisks()
  local scanned = getLog(0x010100, "OK", 0)
  
  for addr, componentType in component.list() do
    if componentType == "filesystem" then
      table.insert(scanned, addr)
      local letter = lib.getLetter(addr)
      if not letter then
        for i, v in lib.addrs do
          if v == "" then 
            lib.addrs[i] = addr 
            break 
          end
        end
      end
    end
  end
  
  config = loadfile(bootaddr, "/FROS0P5/core/config.lua")
  config["DiskAddrs"] = lib.addrs
  data = "return " .. serialization.serialize(config)
  local f = io.open("/FROS0P5/core/config.lua", "w")
  if f then
    f:write(data)
    f:close()
  end
  
  return scanned
end

function lib.getDisk(addr)
  if component.type(addr) == "filesystem" then
    local info = getLog(0x010100, "OK", 0)
    local proxy = component.proxy(addr)
    local letter = lib.getLetter(addr)
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
        for _, name in list do
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

function lib.dividePath(path, currentPath)
    if not path or path == "" then
        return getLog(0x010104, "INVALID_PATH", 2)
    end

    local letter = string.sub(path, 1, 1):upper()
    local rest = string.sub(path, 3)
    if letter:match("%a") and string.sub(path, 2, 2) == ":" then
        local addr = lib.addrs[letter]
        if not addr or addr == "" then
            return getLog(0x010104, "INVALID_PATH", 2)
        end
        local log = getLog(0x010100, "OK", 0)
        log["addr"] = addr
        log["path"] = "/" .. rest
        return log
    end

    if string.sub(path, 1, 4):upper() == "SYS:" then
        local addr = lib.addrs["SYS"]
        if not addr or addr == "" then
            return getLog(0x010104, "INVALID_PATH", 2)
        end
        local log = getLog(0x010100, "OK", 0)
        log["addr"] = addr
        log["path"] = "/" .. string.sub(path, 5)
        return log
    end

    if string.sub(path, 1, 1) == "/" then
        local addr = lib.addrs["SYS"]
        if not addr or addr == "" then
            return getLog(0x010104, "INVALID_PATH", 2)
        end
        local log = getLog(0x010100, "OK", 0)
        log["addr"] = addr
        log["path"] = path
        return log
    end

    if currentPath and currentPath.addr and currentPath.path then
        local fullPath = currentPath.path
        if fullPath == "/" then
            fullPath = "/" .. path
        else
            fullPath = fullPath .. "/" .. path
        end

        local parts = {}
        for part in string.gmatch(fullPath, "[^/]+") do
            if part == ".." then
                if #parts > 0 then
                    table.remove(parts)
                else
                    return getLog(0x010104, "INVALID_PATH", 2)
                end
            elseif part ~= "." and part ~= "" then
                table.insert(parts, part)
            end
        end
        local normalized = "/" .. table.concat(parts, "/")
        if normalized == "" then normalized = "/" end

        local log = getLog(0x010100, "OK", 0)
        log["addr"] = currentPath.addr
        log["path"] = normalized
        return log
    end

    return getLog(0x010104, "INVALID_PATH", 2)
end

return lib
