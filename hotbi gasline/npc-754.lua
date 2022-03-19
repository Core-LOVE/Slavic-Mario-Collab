local npcManager = require("npcManager")

local npcID = NPC_ID
local npc_s = {}

npcManager.setNpcSettings{
	id = npcID,
	frames = 4,
	framespeed = 4,
	
	jumphurt = true,
	
	nogravity = true,
	noblockcollision = true,
	
	lightradius = 64,
	lightbrightness = 0.5,
	lightcolor = Color.blue,
	lightflicker = false,
}

function npc_s.onInitAPI()
	npcManager.registerEvent(npcID, npc_s, "onCameraDrawNPC")
	npcManager.registerEvent(npcID, npc_s, "onTickNPC")
end

function npc_s.onCameraDrawNPC(v)
	local data = v.data
	
	if data.particle == nil then
		data.particle = data.particle or Particles.Emitter(v.x, v.y, "p_flame_small.ini")
		data.particle:Attach(v)
	end
	
	if data.particle then
		data.particle:Draw()
	end
end

function npc_s.onTickNPC(v)
	local data = v.data
	
	if not data.init then	
		SFX.play 'shoot.wav'
		data.init = true
	end
	
	if data.movement then
		local state = data.movement(v, data)
		
		if state then
			data.movement = nil
		end
	end
end

return npc_s