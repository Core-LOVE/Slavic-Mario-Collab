local npcManager = require("npcManager")
local afterimages = require 'afterimages'

local npcID = NPC_ID
local npc_s = {}

npcManager.setNpcSettings{
	id = npcID,
	
	frames = 1,
	framespeed = 4,
	
	jumphurt = true,
	
	-- nogravity = true,
	-- noblockcollision = true,
		
	lightradius = 128,
	lightbrightness = 0.5,
	lightcolor = Color.pink,
	lightflicker = false,
}

function npc_s.onInitAPI()
	npcManager.registerEvent(npcID, npc_s, "onCameraDrawNPC")
	npcManager.registerEvent(npcID, npc_s, "onTickNPC")
end

function npc_s.onCameraDrawNPC(v)
	-- local data = v.data
	
	-- if data.particle == nil then
		-- data.particle = data.particle or Particles.Emitter(v.x, v.y, "p_flame_small2.ini")
		-- data.particle:Attach(v)
	-- end
	
	-- if data.particle then
		-- data.particle:Draw()
	-- end
end

function npc_s.onTickNPC(v)
	local data = v.data
	
	local time = lunatime.tick()
	
	if time % 3 == 0 then
		afterimages.create(v, 15, Color.red .. 0.25, false, -75)
	end
	
	if v.collidesBlockBottom then
		v.speedY = -9
	end
end

return npc_s