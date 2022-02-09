local npc = {}

local npcManager = require 'npcManager'
local id = NPC_ID

local size = 16

npcManager.setNpcSettings{
	id = id,
	
	frames =1,
	
	jumphurt = true,
	nohurt = false,
	
	width=size,
	height=size,
	gfxwidth=size,
	gfxheight=size,
}

function npc.onTickEndNPC(v)
	if v.collidesBlockBottom or v.collidesBlockRight or v.collidesBlockLeft or v.collidesBlockTop then
		v:kill(9)
	end
end

function npc.onInitAPI()
	npcManager.registerEvent(id, npc, 'onTickEndNPC')
end

return npc