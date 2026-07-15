print("\nIt seems, downloading the 'setup.lua' file was successfully.")
print("Running now: FastRunOS: setup.lua")
io.write("Initializating setup... ")

local component = require("component")
local gpu = component.gpu
local maxW, maxH = gpu.maxResolution()

local function cls()
  gpu.setBackground(0x000000)
  gpu.fill(1, 1, maxW, maxH, " ")
end

cls()
io.write("\nInitializating setup... ")

if maxW < 160 and maxH < 50 then
  io.write("!\n")
  print("PC does not meet the system requirements: \nMinimal Resolution is 80x25 symbols.")
  os.exit(1)
end

if not component.isAvailable("internet") then
  io.write("!\n")
  print("PC does not meet the system requirements: \nInternet card needs to be installed.")
  os.exit(1)
end

gpu.setResolution(80, 25)

local function drawStroke(bg, fg, x, y, stroke)
  gpu.setBackground(bg)
  gpu.setForeground(fg)
  gpu.set(x+1, y+1, stroke)
end

local function fillStroke(bg, fg, x, y, sx, sy, sym)
  gpu.setBackground(bg)
  gpu.setForeground(fg)
  gpu.fill(x+1, y+1, sx+1, sy+1, sym)
end

io.write("OK.\n")
cls()

for stroke = 0, 24 do
    fillStroke(math.floor(255 * (1 - stroke / 24)), 0x000000, 0, stroke, 79, 0, " ")
end

drawStroke(244, 0xFFFFFF, 1, 1, "FastRunOS Setup")
