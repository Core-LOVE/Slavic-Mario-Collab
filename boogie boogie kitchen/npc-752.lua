local npc = {}
local id = NPC_ID

local npcManager = require 'npcManager'
local npcutils = require 'npcs/npcutils'

npcManager.setNpcSettings{
	id = id,
	
	width = 64,
	height = 64,
	gfxwidth = 64,
	gfxheight = 64,
	
	nohurt = true,
	jumphurt = true,
	nogravity = true,
	noblockcollision = true,
	
	noiceball = true,
	noyoshi = true,
	
	frames = 1,
}


function npc.onCameraDrawNPC(v)
	if v.despawnTimer <= 0 then return end
	
	local id = v.ai1
	
	npcutils.drawNPC(v, {frame = 0, priority = -55})
	
	if id <= 0 then return end
	
	local img = Graphics.sprites.npc[id].img
	
	local x = (v.x + v.width * 0.5) - 16
	local y = (v.y + v.height * 0.5) - 8
	
	Graphics.drawImageToSceneWP(img, x, y, 0, 0, 32, 32, 0.5, -54)
end

local max = 80

function npc.onTickEndNPC(v)
	if v.despawnTimer <= 0 then return end
	
	local timer = lunatime.tick()
	
	if timer % max == 0 then
		local spawned = NPC.spawn(v.ai1, v.x + (v.width / 2) - 16, v.y - 8)
		spawned.speedY = -6
		spawned.direction = v.direction
		spawned.dontMove = v.dontMove
	end
	
	v.animationFrame = -1
end

function npc.onInitAPI()
	npcManager.registerEvent(id, npc, 'onCameraDrawNPC')
	npcManager.registerEvent(id, npc, 'onTickEndNPC')
end

return npc