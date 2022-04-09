local npc = {}
local id = NPC_ID

local npcManager = require 'npcManager'

npcManager.setNpcSettings{
	id = id,
	
	width = 800,
	height = 600,
	gfxwidth = 800,
	gfxheight = 600,
	
	jumphurt = true,
	nohurt = true,
	
	nogravity = true,
	noblockcollision = true,
}

local img = Graphics.loadImageResolved 'people.png'

function npc.onCameraDrawNPC(v)
	if v.despawnTimer <= 0 then return end
	
	local time = lunatime.tick() / 8
	
	local y = (math.sin(time) * 16)
	local h = (img.height + y)
	
	Graphics.drawBox{
		texture = img,
		
		x = 0,
		y = (600 - h),
		
		height = h,
	}
end


function npc.onInitAPI()
	npcManager.registerEvent(id, npc, 'onCameraDrawNPC')
end

return npc