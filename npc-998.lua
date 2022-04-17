local npc = {}

local npcManager = require 'npcManager'
local id = NPC_ID

npcManager.setNpcSettings{
	id = id,
	
	noharm = true,
	jumphurt = true,
}

return npc