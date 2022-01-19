--[[

	Written by MrDoubleA
	Please give credit!

    Part of MrDoubleA's NPC Pack

]]

local npcManager = require("npcManager")
local npcutils = require("npcs/npcutils")

local ai = require("cannonPipe_ai")


local cannonPipe = {}
local npcID = NPC_ID

local cannonPipeSettings = table.join({
	id = npcID,
	
	gfxwidth = 64,
	gfxheight = 32,

	gfxoffsetx = 0,
	gfxoffsety = 0,
	
	width = 64,
	height = 32,

	horizontal = false,
},ai.sharedSettings)

npcManager.setNpcSettings(cannonPipeSettings)
npcManager.registerHarmTypes(npcID,{},{})

ai.register(npcID)

return cannonPipe