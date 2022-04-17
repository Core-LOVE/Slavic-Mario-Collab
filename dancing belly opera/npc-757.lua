local npcManager = require("npcManager")

local afterimages = require 'afterimages'

local id = NPC_ID
local npc = {}

npcManager.setNpcSettings{
	id = id,
	
	frames = 1,
	
	jumphurt = true,
	
	noblockcollision = true,
}

function npc.onInitAPI()
	npcManager.registerEvent(id, npc, "onTickNPC")
end

function npc.onTickNPC(v)
	local time = lunatime.tick()
	
	if time % 3 == 0 then
		local colors = {
			'white',
			'purple',
			'pink',
			'blue',
			'green',
			'red',
		}
		
		local color = colors[math.random(1, #colors)]
		
		afterimages.create(v, 25, Color[color], false, -75)
		afterimages.create(v, 25, Color[color], false, -75)
	end
end

return npc