Graphics.activateHud(false)

local textplus = require 'textplus'
local font =  textplus.loadFont("devkit/font.ini")

local credits = "<align center>Slavic Mario Collab</align>"

function onStart()
	player.forcedState = 8
end

function onCameraDraw()
	textplus.print{
		text = credits,
		
		x = 400,
		y = 0,
		
		font = font,
		xscale = 2,
		yscale = 2,
	}
end