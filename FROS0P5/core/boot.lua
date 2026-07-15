-- FastRunOS
-- By egorps
-- Licensed by MIT License

-- FastRunOS Kernel

--[[
Code:
  0x00 - Core:
    0x00 - boot (kernel):
      0x01 - FS_LIB_NOT_FOUND
      0x02 - CONFIG_NOT_FOUND
      0x03 - RT_LIB_NOT_FOUND
      0x04 - GPU_LIB_NOT_FOUND

Message:
  FS_LIB_NOT_FOUND - File System Library wasn't found
  CONFIG_NOT_FOUND - config.lua wasn't found
  RT_LIB_NOT_FOUND - Real-Time Thread Library wasn't found
  GPU_LIB_NOT_FOUND - GPU Library wasn't found
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
  return load(buffer, "=" .. file, "bt", _G)()
end

local fs
local config
local rt
local gpu

local function init()
  fs = loadfile(bootaddr, "/FROS0P5/libs/fs.lua")
  if fs == nil then return getLog(0x000001, "FS_LIB_NOT_FOUND", 2) end
  config = loadfile(bootaddr, "/FROS0P5/core/config.lua")
  if config == nil then return getLog(0x000001, "CONFIG_NOT_FOUND", 2) end
  rt = loadfile(bootaddr, "/FROS0P5/core/rtlib.lua")
  if rt == nil then return getLog(0x000103, "RT_LIB_NOT_FOUND", 2) end
  gpu = loadfile(bootaddr, "/FROS0P5/libs/gpu.lua")
  if gpu == nil then return getLog(0x000004, "GPU_LIB_NOT_FOUND", 2) end
  local fs_init = fs.init()
  local rt_init = rt.init()
  local gpu_init = gpu.init()
  if fs_init["log"]["Status"] ~= 0 then
    return fs_init
  elseif rt_init["log"]["Status"] ~= 0 then
    return rt_init
  elseif gpu_init["log"]["Status"] ~= 0 then
    return gpu_init
  end
  return getLog(0x000000, "OK", 0)
end

local function debug(log)
  
end

local function emergencyDebug(log)

end
