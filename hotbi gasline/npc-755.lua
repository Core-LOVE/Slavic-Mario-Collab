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
	lightcolor = Color.purple,
	lightflicker = false,
}

function npc_s.onInitAPI()
	npcManager.registerEvent(npcID, npc_s, "onCameraDrawNPC")
	npcManager.registerEvent(npcID, npc_s, "onTickNPC")
end

function npc_s.onCameraDrawNPC(v)
	local data = v.data
	
	if data.particle == nil then
		data.particle = data.particle or Particles.Emitter(v.x, v.y, "p_flame_small2.ini")
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
	
	if data.movement and v.ai5 == 0 then
		local state = data.movement(v, data)
		
		if state then
			data.movement = nil
		end
	elseif v.ai5 ~= 0 then
		v.speedY = v.speedY + 0.3
	end
	
	if v.ai5 ~= 0 then return end
	
	for k,b in Block.iterateIntersecting(v.x, v.y, v.x + v.width, v.y + v.height) do
		SFX.play 'fire1.wav'
		Effect.spawn(131, v.x, v.y)
		
		local n = NPC.spawn(755, v.x, v.y)
		n.ai5 = 1
		n.speedY = -6
		n.speedX = -3
		local n = NPC.spawn(755, v.x, v.y)
		n.ai5 = 1
		n.speedY = -6
		n.speedX = 3
		
		v:kill(9)
		break
	end
end

return npc_s