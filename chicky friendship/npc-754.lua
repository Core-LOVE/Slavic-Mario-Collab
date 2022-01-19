local npc = {}
local id = NPC_ID

local npcManager = require 'npcManager'

npcManager.setNpcSettings{
	id = id,
	
	frames = 4,
	framestyle = 1,
	
	nohurt = true,
	jumphurt = true,
}

function npc.onNPCHarm(e, v, r, c)
	if v.id ~= id then return end
	
	if v.ai1 == 0 then
		local data = v.data
		data.circle = nil
		
		v.ai1 = 1
		v.speedY = -6
		v.direction = -v.direction
		v.speedX = 5.5 * v.direction
	else
		v.speedY = -6
	end
	
	e.cancelled = true
end

function npc.onTickEndNPC(v)
	local data = v.data
	
	local cfg = NPC.config[id]
	local state = v.ai1
	
	local frames = cfg.frames
	
	if state == 0 then
		data.circle = data.circle or Colliders.Circle(v.x + v.width / 2, v.y + v.height / 2, v.width + v.height)
	
		v.animationFrame = (math.random() > 0.96 and 1) or 0
		
		if v.direction == 1 then
			v.animationFrame = v.animationFrame + frames
		end
		
		if Colliders.collide(player, data.circle) then
			v.ai1 = 1
			
			v.y = v.y - 1
			v.speedY = -6
			v.direction = -v.direction
			v.speedX = 5.5 * v.direction
			
			Effect.spawn(751, v.x, v.y)
			
			data.circle = nil

			return
		end
	else
		if v.direction == 1 then
			v.animationFrame = math.clamp(v.animationFrame, frames + 2, frames + 4) 
		else
			v.animationFrame = math.clamp(v.animationFrame, 2, frames) 
		end
	end
end

function npc.onInitAPI()
	npcManager.registerEvent(id, npc, 'onTickEndNPC')
	registerEvent(npc, 'onNPCHarm')
end

return npc