local npc = {}
local id = NPC_ID

local npcManager = require 'npcManager'

local head = Graphics.loadImageResolved 'head.png'
local line = Graphics.loadImageResolved 'line.png'
local box = Graphics.loadImageResolved 'box.png'

function npc.onCameraDrawNPC(v)
	local y = (v.y - box.height) + v.height
	
	Graphics.drawBox{
		texture = box,
		
		x = v.x,
		y = y,
		
		sceneCoords = true,
	}
end

function npc.onTickEndNPC(v)

end

function npc.onInitAPI()
	npcManager.registerEvent(id, npc, 'onCameraDrawNPC')
end

return npc