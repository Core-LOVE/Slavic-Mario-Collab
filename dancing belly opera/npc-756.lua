local boss = {}

local hud = require 'devkit/hud'

local npcManager = require 'npcManager'
local id = NPC_ID

local maxHp = 12

npcManager.setNpcSettings{
	id = id,
	
	frames = 5,
	framestyle = 0,
	framespeed = 8,
	
	jumphurt = false,
	nohurt = false,
	
	noiceball = true,
	noyoshi = true,
	
	-- noblockcollision=true,

	width=64,
	height=64,
	gfxwidth=64,
	gfxheight=64,
}

local harmTypes = {
	HARM_TYPE_JUMP,
	HARM_TYPE_FROMBELOW,
	HARM_TYPE_NPC,
	HARM_TYPE_PROJECTILE_USED,
	HARM_TYPE_LAVA,
	HARM_TYPE_HELD,
	HARM_TYPE_TAIL,
	HARM_TYPE_SPINJUMP,
}
		
npcManager.registerHarmTypes(id, harmTypes, {})

local phases = {}

phases.onAnimation = function(v)
	local data = v.data
	data.frame = data.frame or 0
	data.frameTimer = data.frameTimer or 0
	
	data.frameTimer = data.frameTimer + 1
	
	if not v.collidesBlockBottom then
		if data.frame ~= 1 and data.frame ~= 2 then
			data.frame = 1
		end
		
		if data.frameTimer >= 4 then
			if data.frame == 1 then
				data.frame = 2
			else
				data.frame = 1
			end
			
			data.frameTimer = 0
		end
	else
		data.frame = 0
		
		if data.phase == 1 then
			data.frame = 3
		end
		
		if v.speedX ~= 0 then
			if data.frameTimer >= 4 and data.frameTimer < 8 then
				data.frame = 4
			elseif data.frameTimer >= 8 then
				data.frameTimer = 0
			else
				data.frame = 0
			end
		end
	end

	v.animationFrame = -1
end

local icon = Graphics.loadImageResolved 'bossIcon.png'

phases.onCameraDraw = function(v)
	local data = v.data
	local cfg = NPC.config[id]
	
	if data.hp <= 0 then
		data.frame = -1
	end
	
	if data.frame and data.frame < 0 then return end
	
	local w = cfg.gfxwidth
	local y = (cfg.gfxheight - cfg.height) * 0.5
	if v.direction == 1 then
		w = -w
	end
	
	-- Graphics.drawBox{
		-- x = v.x,
		-- y = v.y,
		-- width = v.width,
		-- height = v.height,
		
		-- sceneCoords = true,
		-- color = Color.red .. 0.5,
	-- }
	
	local col = 1
	
	if data.immune > 0 then
		col = math.random()
	end
	
	Sprite.draw{
		texture = Graphics.sprites.npc[id].img,
		
		x = (v.x + v.width / 2),
		y = (v.y + v.height / 2) - y,
		
		sceneCoords = true,
		frame = data.frame + 1,
		frames = cfg.frames,
		
		width = w,
		
		pivot = Sprite.align.CENTER,
		priority = -75,
		
		color = Color.white .. col,
	}
	
	hud.showBossHP{
		icon = icon,
		amount = data.hp,
		max = maxHp,
	}
end

phases[1] = {}

-- local function movement1(s, vs)
	-- return function(v)
		-- v.speedY = vs or 3
		-- v.speedX = s
		-- v.ai1 = v.ai1 + 1
		
		-- if v.ai1 >= 16 then
			-- v.speedX = 0
			-- return true
		-- end
	-- end
-- end

phases[1].onTick = function(v)
	if v.collidesBlockBottom then
		v.ai1 = v.ai1 + 1
		Defines.earthquake = math.abs(v.speedX)
		
		local n = NPC.spawn(757, v.x, v.y + (v.height - 32))
		n.speedY = -6
		n.speedX = -(v.ai1 - 0.5)
		
		local n = NPC.spawn(757, v.x + (v.width - 32), v.y + (v.height - 32))
		n.speedY = -6
		n.speedX = v.ai1 - 0.5
		
		Effect.spawn(73, v.x + 16, v.y + (v.height - 32))
		
		-- v.speedX = v.speedX * 0.5
		v.speedY = -12
		
		local p = player
		v.speedX = -((v.x + v.width / 2) - (p.x + p.width / 2)) / 48
	end
end

phases[1].condition = function(phase, v)
	if v.ai1 > 3 and v.collidesBlockBottom then
		v.ai1 = 0
		v.speedX = 0
		v.speedY = 0
		
		return true
	end
end

phases[2] = {}

phases[2].onTick = function(v)
	v.ai1 = v.ai1 + 1
	
	if v.ai1 % 24 == 0 then
		local bound = Section(v.section).boundary
		v.ai2 = v.ai2 + 64
		
		local x = (bound.left + (v.ai2 * 2)) - 80
		
		local n = NPC.spawn(755, x, bound.top)
		n.y = n.y - 63
		n.data.init = true
		n.speedY = 8
	end
end

phases[2].condition = function(phase, v)
	if v.ai1 > 24 * 10 then
		v.ai2 = 0
		v.ai1 = 0
		
		local p = player
		v.direction = ((p.x + p.width / 2 > v.x + v.width / 2) and 1) or -1
		
		return true
	end
end

phases[3] = {}

phases[3].onTick = function(v)
	v.ai1 = v.ai1 + 1
	
	if v.ai1 > 32 then
		v.speedX = 2 * v.direction
	end
end

phases[3].condition = function(phase, v)
	-- if v.ai2 > 400 then
		
	-- end
end

local function call(phase, name, ...)
	if phase[name] then
		phase[name](...)
	else
		if phases[name] then
			phases[name](...)
		end
	end
end

local function condition(phase, v)
	local data = v.data
	
	return (data.phaseTimer > (phase.maxTimer or 180))
end

local function death(v)
	local n = NPC.spawn(489, v.x, v.y)
	Audio.SeizeStream(player.section)
	Audio.MusicStop()
	
	-- local n = NPC.spawn(489, v.x, v.y)
	Misc.pause()
	
	Routine.wait(1, true)
	Text.showMessageBox("<portrait hotbi>That's not cool.")
	
	Routine.waitFrames(2)
	Misc.unpause()

	for y = 0, n.height do
		local e = Effect.spawn(265, n.x + math.random(n.height), n.y + y)
		e.speedX = math.random(4)
	end
	
	n:kill(9)
	-- Routine.wait(2)
	-- local l = Layer.get("door")
	-- l:toggle(false)
end

function boss.onNPCHarm(e, v, r, o)
	if v.id ~= id then return end
	
	local data = v.data
	
	local dmg = 1
	
	if o and o.id == 13 then
		dmg = 0.25
	end
	
	if data.immune > 0 then
		e.cancelled = true
		return
	end
	
	-- SFX.play('bossHit.ogg')
	Defines.earthquake = 6
	
	if data.hp > 0 then
		data.hp = (data.hp - dmg)
		data.immune = 60
		
		e.cancelled = true
	end
	
	if data.hp <= 0 then
		e.cancelled = false
		data.frame = -1
		Routine.run(death, v)
	end
end

function boss.onTickNPC(v)
	local data = v.data
	
	if not data.init then
		data.phaseTimer = 0
		data.phase = 0
		data.hp = maxHp
		data.immune = 0
		
		data.init = true
	end
	
	-- immune
	if data.immune > 0 then
		data.immune = (data.immune - 1)
		v.friendly = true
	else
		v.friendly = false
	end
	
	-- phases
	local phase = phases[data.phase + 1]
	
	if not phase then return end
	
	call(phase, 'onTick', v)
	
	-- player death
	if player.deathTimer == 1 then
		Audio.SeizeStream(player.section)
		Audio.MusicStop()
	end
end

function boss.onTickEndNPC(v)
	local data = v.data
	if not data.init then return end
	
	-- phases
	local phase = phases[data.phase + 1]
	
	if not phase then return end
	
	call(phase, 'onTickEnd', v)
	call(phase, 'onAnimation', v)
	
	local nextPhase = (phase.condition or condition)
	
	if nextPhase(phase, v) then
		data.phase = (data.phase + 1) % #phases
		data.phaseTimer = 0
	else
		data.phaseTimer = (data.phaseTimer + 1)
	end
end

function boss.onCameraDrawNPC(v)
	local data = v.data
	
	if not data.init then return end
	
	-- phases
	local phase = phases[data.phase + 1]
	
	if not phase then return end
	
	call(phase, 'onCameraDraw', v)
end

function boss.onPlayerHarm(v)
	local bound = Section(player.section).boundary
	local x = bound.left + math.random(800 - 100)
	
	local e = Effect.spawn(753, x, bound.bottom - 64)
	e.speedX = 0.001 * math.random(-1,1)
end

function boss.onInitAPI()
	registerEvent(boss, 'onPlayerHarm')
	registerEvent(boss, 'onNPCHarm')
	npcManager.registerEvent(id, boss, 'onTickNPC')
	npcManager.registerEvent(id, boss, 'onTickEndNPC')
	npcManager.registerEvent(id, boss, 'onCameraDrawNPC')
end

return boss