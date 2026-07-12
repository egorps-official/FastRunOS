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
