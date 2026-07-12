-- FastRunOS
-- By egorps
-- Licensed by MIT License

-- Real-Time Thread Library for FastRunOS kernel

--[[
Codes:
0x{type}{scriptNum}{code}

Code:
  0x00 - Core:
    0x01 - rtlib:
      0x01

Message:
  0x01 - 
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

function lib.
