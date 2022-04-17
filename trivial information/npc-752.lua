local npc = {}
local npcManager = require 'npcManager'

local id = NPC_ID

npcManager.setNpcSettings{
	id = id,
	
	nogravity = true,
	noblockcollision = true,
	
	jumphurt = true,
	nohurt = false,
	
	noyoshi = true,
	noiceball = true,
	
	lightcolor = Color.green,
	lightradius = 96,
	lightbrightness=1.5, 	
}

local textplus = require 'textplus'

local chars = {
	'a',
	'b',
	'c',
	'd',
	'e',
	'f',
	'g',
	'u',
	'l',
	'q',
	'i',
	'1',
	'2',
	'0',
	'9',
	'm',
}

function npc.onCameraDrawNPC(v)
	if v.despawnTimer <= 0 then return end

	local data = v.data
	data.trail = data.trail or {}
	
	local char = chars[math.random(1, #chars)] .. chars[math.random(1, #chars)] .. chars[math.random(1, #chars)]
	char = char .. '\n' .. (chars[math.random(1, #chars)] .. chars[math.random(1, #chars)] .. chars[math.random(1, #chars)])
	
	local time = lunatime.tick()
	
	if time % 2 == 0 then
		data.trail[#data.trail + 1] = {
			text = char,
			
			x = v.x,
			y = v.y,
			
			alpha = 0.75,
		}
	end
	
	textplus.print{
		text = char,
		
		x = v.x,
		y = v.y,
		
		xscale = 2,
		yscale = 2,
		
		sceneCoords = true,
		color = Color.green,
	}
	
	for k,trail in ipairs(data.trail) do
		trail.alpha = trail.alpha - 0.04
		
		textplus.print{
			text = trail.text,
			
			x = trail.x,
			y = trail.y,
			
			xscale = 2,
			yscale = 2,
			
			sceneCoords = true,
			color = Color.green * trail.alpha,
		}
		
		if trail.alpha < 0 then
			table.remove(data.trail, k)
		end
	end
end

function npc.onInitAPI()
	npcManager.registerEvent(id, npc, 'onCameraDrawNPC')
end

return npc