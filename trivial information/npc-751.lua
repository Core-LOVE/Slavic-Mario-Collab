local npc = {}
local npcManager = require 'npcManager'

local id = NPC_ID

npcManager.setNpcSettings{
	id = id,
	
	nogravity = true,
	noblockcollision = true,
}

function npc.onTickEndNPC(v)
	if v.despawnTimer <= 0 then return end
	
	if not v.friendly then
		v.friendly = true
	end
	
	local data = v.data
	local settings = data._settings
	
	local direction = settings.direction
	
	data.state = (data.state or 1)
	data.timer = (data.timer or 0)
	
	data.timer = data.timer + 1
	
	if data.timer > settings.rate * 32 then
		local n = NPC.spawn(id + 1, v.x, v.y)
		
		if direction == -1 then
			n.speedX = -6
		elseif direction == 1 then
			n.speedX = 6
		elseif direction == 2 then
			n.speedY = 6
		else
			n.speedY = -6
		end
		
		data.timer = 0
	end
end

function npc.onInitAPI()
	npcManager.registerEvent(id, npc, 'onTickEndNPC')
end

return npc