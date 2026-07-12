-- FastRunOS
-- By egorps
-- Licensed by MIT License

-- Real-Time Thread Library for FastRunOS kernel

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
