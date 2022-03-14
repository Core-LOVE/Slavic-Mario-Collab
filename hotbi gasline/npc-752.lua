--[[

	Written by MrDoubleA
	Please give credit!

    Part of MrDoubleA's NPC Pack

]]

local npcManager = require("npcManager")

local ai = require("yiDoor_ai")


local yiDoor = {}
local npcID = NPC_ID

local yiDoorSettings = table.join({
	id = npcID,
	
	gfxwidth = 64,
	gfxheight = 64,

	gfxoffsetx = 0,
	gfxoffsety = 0,
	
	width = 64,
	height = 64,
},ai.sharedSettings)

npcManager.setNpcSettings(yiDoorSettings)
npcManager.registerHarmTypes(npcID,{},{})


ai.register(npcID)


return yiDoor