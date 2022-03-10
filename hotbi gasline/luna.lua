require 'extraNPCProperties'

local particles = require("particles")

local lights = particles.Emitter(0, 0, "p_lights.ini")
lights:AttachToCamera(camera)

function onCameraDraw()
    lights:Draw()
end