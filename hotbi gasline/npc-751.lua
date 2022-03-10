local npcManager = require("npcManager")

local npcID = NPC_ID
local npc_s = {}

npcManager.setNpcSettings{
	id = npcID,
	
	nogravity = true,
	noblockcollision = true,
}

local settings = {
timer = 75,
timer2 = 125
}
local vars = {
timer = -25
}

function npc_s.onInitAPI()
	npcManager.registerEvent(npcID, npc_s, "onTickNPC")
	npcManager.registerEvent(npcID, npc_s, "onDrawNPC")
	registerEvent(npc_s, "onTick")
end

local function init(v)
	local data = v.data
	
	data.effect = Particles.Emitter(v.x, v.y, "p_smoke.ini")
	data.effect:attach(v, true)
	data.effect.enabled = false
	
	data.init = true
end

function npc_s.onTick()
	vars.timer = vars.timer + 1
	
	if vars.timer == settings.timer then
		for k,v in ipairs(NPC.get(npcID)) do
			if v.x >= camera.x and
			v.x <= camera.x + camera.width and
			v.y >= camera.y and
			v.y <= camera.y + camera.height then
				SFX.play("steam_pipe.wav")
				break
			end
		end
	end

	if vars.timer > settings.timer2 then
		vars.timer = -25
	end
end

function npc_s.onDrawNPC(v)
	local data = v.data
	
	if data.effect ~= nil then
		data.effect:draw(-5)
	end
end

function npc_s.onTickNPC(v)
	local data = v.data
	
	if not v.friendly then v.friendly = true end
	
	if data.init == nil then
		init(v)
	end
	
	if vars.timer > settings.timer then
		data.effect.enabled = true
	
		for k,p in ipairs(Player.getIntersecting(v.x, v.y - 24, v.x + v.width, v.y)) do
			p:harm()
		end
		
		for k,n in NPC.iterateIntersecting(v.x, v.y  - 64, v.x + v.width, v.y) do
			if n ~= v then
				n.speedY = -7
			end
		end
	end
	
	if vars.timer >= settings.timer2 then
		data.effect.enabled = false
	end
	
	if v.layerName ~= nil then
		for k,n in ipairs(NPC.get()) do
			if n.attachedLayerName == v.layerName then
				if player.section == 1 then
					v.speedX = n.speedX
					v.speedY = n.speedY
				else
					v.speedX = 0
					v.speedY = 0
				end
			end
		end
	end
end

return npc_s