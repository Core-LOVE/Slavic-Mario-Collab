local npc = {}

local npcManager = require 'npcManager'
local id = NPC_ID

npcManager.setNpcSettings{
	id = id,
	
	frames =1,
	
	jumphurt = true,
	nohurt = false,
	
	width=6,
	height=6,
	gfxwidth=6,
	gfxheight=6,
	
	nogravity = true,
}

local function traps(v)
	local bound = player.sectionObj.boundary
	
	for i = 1, v.ai1 do
		local n = NPC.spawn(755, player.x + (16 * i), bound.top + 64)
	end
end

function npc.onTickEndNPC(v)
	local data = v.data
	
	if not data.init then
		Effect.spawn(131, v.x - 12, v.y - 12)
		data.init = true
	end
	
	for k,b in Block.iterateIntersecting(v.x - 6, v.y - 6, v.x + v.width + 6, v.y + v.height + 6) do
		Effect.spawn(73, v.x - 12, v.y - 12)
		
		if v.ai1 ~= 0 then
			traps(v)
		end
		
		return v:kill(9)
	end
end

function npc.onInitAPI()
	npcManager.registerEvent(id, npc, 'onTickEndNPC')
end

return npc