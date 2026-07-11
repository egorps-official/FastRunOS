print("It seems, downloading the 'setup.lua' file was successfully.")
print("Running now: FastRunOS: setup.lua")
io.write("Initializating setup... ")
local component = require("component")
local gpu = component.gpu
gpu.setBackground(0x0000FF)
gpu.set(1, 1, " ")
