local npc = {}
local npcManager = require("npcManager")
local id = NPC_ID

npcManager.setNpcSettings{
	id = id,
	
	width = 32,
	gfxwidth = 32,
	gfxheight = 48,
	height = 32,
	
	frames = 2,
	framestyle = 1,
	
	nogravity = true,
	noblockcollision = true,
	
	transform = id - 2,
	transformShell = 116,

	effect = 771,
}

function npc.onTickEndNPC(v)
	if v:mem(0x138, FIELD_WORD) == 5 then
		local config = NPC.config[id]
	
		v:transform(config.transformShell)
	end
end

function npc.onPostNPCHarm(v, r, c)
	if v.id ~= id then return end

	local config = NPC.config[id]
	
	if r == 1 then
		local shell = NPC.spawn(config.transform, v.x, v.y)
		shell.layerName = "Spawned NPCs"
		shell.y = shell.y + (v.height - shell.height) / 2
		shell.direction = v.direction
	elseif r == HARM_TYPE_TAIL then
		local shell = NPC.spawn(config.transformShell, v.x, v.y)
		shell.layerName = "Spawned NPCs"
		shell.y = shell.y + (v.height - shell.height) / 2
		shell.direction = v.direction
	end
end

function npc.onInitAPI()
	local config = NPC.config[id]
	
	npcManager.registerEvent(id, npc, 'onTickEndNPC')
	npcManager.registerHarmTypes(id,
		{
			HARM_TYPE_SPINJUMP,
			1,
			2,
			7,
			3,
			6,
			10,
		}, 
		{
			[HARM_TYPE_LAVA]=10,
			[3] = config.effect,
		}
	);
	
	registerEvent(npc, 'onPostNPCHarm')
end


return npc