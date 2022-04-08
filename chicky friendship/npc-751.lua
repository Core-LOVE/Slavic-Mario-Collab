local npc = {}
local id = NPC_ID

local npcManager = require 'npcManager'

npcManager.setNpcSettings{
	id = id,
	
	frames = 4,
	framestyle = 1,
	
	nohurt = true,
	jumphurt = true,
	
	grabside = true,
	harmlessgrab = true,
}

npcManager.registerHarmTypes(id,
{
	HARM_TYPE_FROMBELOW,
	HARM_TYPE_NPC,
	HARM_TYPE_PROJECTILE_USED,
},
{}
)

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
	
	if r == 3 and c and c.id ~= 13 then
		Effect.spawn(752, v.x, v.y)
		return
	else
		Effect.spawn(751, v.x, v.y)
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
			SFX.play 'flap.ogg'
			
			data.circle = nil

			return
		end
	else
		if v.direction == 1 then
			v.animationFrame = math.clamp(v.animationFrame, frames + 2, frames + 4) 
		else
			v.animationFrame = math.clamp(v.animationFrame, 2, frames) 
		end
		
		if v.speedX == 0 and v:mem(0x12C, FIELD_WORD) <= 0 then
			v.speedX = 5.5 * v.direction
			v.speedY = -6
			v.y = v.y - 1
			Effect.spawn(751, v.x, v.y)
		end
	end
	
	local pIdx = v:mem(0x12C, FIELD_WORD)
	
	if pIdx > 0 then
		local p = Player(pIdx)
		
		if p.keys.jump == KEYS_PRESSED then
			p.speedY = -1
			
			Effect.spawn(751, v.x, v.y)
		elseif p.keys.jump == KEYS_DOWN then
			p.speedY = math.clamp(p.speedY, -12, 1)
		end
	end
end

function npc.onInitAPI()
	npcManager.registerEvent(id, npc, 'onTickNPC')
	npcManager.registerEvent(id, npc, 'onTickEndNPC')
	registerEvent(npc, 'onNPCHarm')
end

return npc