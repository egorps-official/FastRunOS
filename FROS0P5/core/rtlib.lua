-- FastRunOS
-- By egorps
-- Licensed by MIT License

-- Real-Time Thread Library for FastRunOS kernel

local lib = {}

--[[
Codes:
0x{type}{scriptNum}{code}

Code:
  0x00 - Core:
    0x01 - rtlib:
      0x01 - INVALID_PID
      0x02 - FS_LIB_NOT_FOUND

Message:
  INVALID_PID - Invalid Proccess ID
  FS_LIB_NOT_FOUND - File System Library wasn't found
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

local thread = require("thread")
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

local fs

function lib.init()
  fs = loadfile("/FROS0P5/libs/fs.lua")
  if fs == nil then return getLog(0x000102, "FS_LIB_NOT_FOUND", 2) end
  lib.addrs["SYS"] = bootaddr
  return getLog(0x000100, "OK", 0)
end

local lastPID = -1
lib.PID_TABLE = {}
local lastError = ""
local lastErrorPID = 0
local lastErrorHandled = true
function lib.newProccess(path, title)
  lastPID = lastPID + 1
  local function task()
    
  end
  lib.PID_TABLE[lastPID] = {
    ["Path"] = path,
    ["Title"] = title,
    ["Thread"] = thread.create(task),
    ["Works"] = true
  }
  local log = getLog(0x000100, "OK", 0)
  log["PID"] = lastPID
  return log
end

function lib.setProccessWork(PID, status)
  if not lib.PID_TABLE[PID] then return getLog(0x000101, "INVALID_PID", 2) end
  if status == false then
    lib.PID_TABLE[PID]["Thread"]:suspend()
    lib.PID_TABLE[PID]["Works"] = status
  elseif status == true then
    lib.PID_TABLE[PID]["Thread"]:resume()
    lib.PID_TABLE[PID]["Works"] = status
  end
  return getLog(0x000100, "OK", 0)
end

function lib.killProccess(PID)
  if not lib.PID_TABLE[PID] then return getLog(0x000101, "INVALID_PID", 2) end
  lib.PID_TABLE[PID]["Thread"]:kill()
  lib.PID_TABLE[PID] = nil
  return getLog(0x000100, "OK", 0)
end

_G.core = lib

function lib.mainloop()
  
end

return lib
