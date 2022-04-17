local npc = {}

local id = NPC_ID

local npcManager = require 'npcManager'

npcManager.setNpcSettings{
	id = id,
	
	width = 32,
	height = 32,
	gfxwidth = 36,
	gfxheight = 36,
	gfxoffsety = 2,
	
	frames = 1,
	nogravity = true,
	noblockcollision = true,
	nohurt = true,
	jumphurt = true,
	
	noiceball = true,
	noyoshi = true,
	
	isinteractable = true,
}

local img2 = Graphics.loadImageResolved('npc-' .. id .. '_2.png')

function npc.onTickEndNPC(v)
	v.animationFrame = -1
	
	if v.despawnTimer <= 0 then return end
	
	local time = lunatime.tick() / 32
	v.speedY = ((math.sin(time) * 1.5) / 2) + (math.cos(time) * 1.25) / 2
	
	if math.random() > 0.92 then
		local id = 78
		
		if math.random() > 0.75 then
			id = 80
		end
		
		Effect.spawn(id, v.x + math.random(v.width), v.y + math.random(v.height))
	end
end

function npc.onNPCKill(e, v, r)
	if v.id ~= id then return end
	
	local p = npcManager.collected(v, r) or player

	SFX.play(59)

	if not(SaveData[Level.filename()] and SaveData[Level.filename()].__clovers and SaveData[Level.filename()].__clovers[v.idx]) then
		SaveData[Level.filename()] = SaveData[Level.filename()] or {}
		SaveData[Level.filename()].__clovers = SaveData[Level.filename()].__clovers or {}
		SaveData[Level.filename()].__clovers[v.idx] = true
		
		SaveData.cloversCount = SaveData.cloversCount or 0
		SaveData.cloversCount = SaveData.cloversCount + 1
	end
end

function npc.onCameraDrawNPC(v)
	if v.despawnTimer <= 0 then return end
	
	local cfg = NPC.config[id]
	
	local img = Graphics.sprites.npc[id].img
	
	local gfxheight = cfg.gfxheight
	local gfxwidth = cfg.gfxwidth
	
	local time = lunatime.tick() / 16
	local rot = -math.cos(time) * 16
	
	local c = 1
	
	if SaveData[Level.filename()] and SaveData[Level.filename()].__clovers and SaveData[Level.filename()].__clovers[v.idx] then
		c = 0.5
	end
	
	if c == 1 then
		local x = (v.width - img2.width) / 2
		local y = (v.height - img2.height) * 1.5
		local scale = -math.sin(time) * 2
		
		-- Graphics.drawImageToSceneWP(img2, v.x + x, v.y + y, -15)
		
		Sprite.draw{
			texture = img2,
			
			x = v.x + x + (img2.width / 2),
			y = v.y + y,
			
			sceneCoords = true,
			height = img2.height + scale,
			width = img2.width + scale,
			
			align = Sprite.align.TOP,
			priority = -15,
		}
	end
	
	Sprite.draw{
		texture = img,
		
		x = (v.x + v.width / 2),
		y = (v.y + v.height / 2),
		
		frames = 2,
		
		sceneCoords = true,
		rotation = rot,
		
		align = Sprite.align.CENTER,
		priority = -15,
		
		color = Color.white .. c,
	}
	
	if c == 1 then
		Graphics.drawImageToSceneWP(img, v.x - 2, v.y - 2, 0, gfxheight, gfxwidth, gfxheight, -15)
	end
end

function npc.onInitAPI()
	npcManager.registerEvent(id, npc, 'onCameraDrawNPC')
	npcManager.registerEvent(id, npc, 'onTickEndNPC')	
	registerEvent(npc, 'onNPCKill')
end

return npc