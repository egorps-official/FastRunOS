-- FastRunOS
-- By egorps
-- Licensed by MIT License

-- GPU Library

local lib = {}

--[[
Code:
  0x01 - Library:
    0x00 - gpu:
      0x01 - INVALID_HRAW
Message:
  INVALID_HRAW - Invalid HRAW
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

function lib.cls()
  gpu.setBackground(0x000000)
  gpu.fill(1, 1, maxW, maxH, " ")
end

function lib.drawStroke(bg, fg, x, y, stroke)
  gpu.setBackground(bg)
  gpu.setForeground(fg)
  gpu.set(x+1, y+1, stroke)
end

function lib.fillStroke(bg, fg, x, y, sx, sy, sym)
  gpu.setBackground(bg)
  gpu.setForeground(fg)
  gpu.fill(x+1, y+1, sx+1, sy+1, sym)
end
