local npcManager = require("npcManager")
local afterimages = require 'afterimages'

local npcID = NPC_ID
local npc_s = {}

npcManager.setNpcSettings{
	id = npcID,
	
	width = 64,
	height = 64,
	gfxwidth = 64,
	gfxheight = 64,
	
	frames = 1,
	framespeed = 4,
	
	jumphurt = true,
	
	nogravity = true,
	noblockcollision = true,
		
	lightradius = 128,
	lightbrightness = 0.5,
	lightcolor = Color.pink,
	lightflicker = false,
}

function npc_s.onInitAPI()
	npcManager.registerEvent(npcID, npc_s, "onCameraDrawNPC")
	npcManager.registerEvent(npcID, npc_s, "onTickNPC")
end

function npc_s.onCameraDrawNPC(v)
	-- local data = v.data
	
	-- if data.particle == nil then
		-- data.particle = data.particle or Particles.Emitter(v.x, v.y, "p_flame_small2.ini")
		-- data.particle:Attach(v)
	-- end
	
	-- if data.particle then
		-- data.particle:Draw()
	-- end
end

function npc_s.onTickNPC(v)
	local data = v.data
	
	local time = lunatime.tick()
	
	if time % 3 == 0 then
		afterimages.create(v, 15, Color.red .. 0.25, false, -75)
	end
	
	for k,n in NPC.iterateIntersecting(v.x, v.y, v.x + v.width, v.y + v.height) do
		if n.id == 756 then
			local new = NPC.spawn(758, v.x + (v.width / 2) - 16, v.y + (v.height / 2) - 16)
			new.speedX = -v.speedX
			new.speedY = -v.speedY
			
			afterimages.create(v, 30, Color.red .. 0.5, false, -75)
			
			v:kill(9)
			
			break
		end
	end
end

return npc_s