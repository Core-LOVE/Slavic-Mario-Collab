local boss = {}

local hud = require 'devkit/hud'

local npcManager = require 'npcManager'
local id = NPC_ID

local maxHp = 9

npcManager.setNpcSettings{
	id = id,
	
	frames = 3,
	framestyle = 0,
	framespeed = 8,
	
	jumphurt = true,
	nohurt = false,
	
	nogravity = true,
	-- noblockcollision=true,
	
	lightradius = 256,
	lightbrightness = 1.25,
	lightcolor = white,
	lightflicker = false,

	width=42,
	height=42,
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
	
	if data.frameTimer >= 8 then
		data.frame = (data.frame + 1)
		
		if data.frame > 1 then
			data.frame = 0
		end
		
		data.frameTimer = 0
	end
	
	-- if not v.collidesBlockBottom then
		-- if math.abs(v.speedX) >= 6 then
			-- data.frame = 3
		-- else
			-- data.frame = 2
		-- end
	-- end

	v.animationFrame = -1
end

local icon = Graphics.loadImageResolved 'bossIcon.png'

local buffer = Graphics.CaptureBuffer(800, 600)
local isHot = false
local hot = 0

local fire = Shader()
fire:compileFromFile(nil, Misc.resolveFile("firewall.frag"))

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
	
	if isHot then
		hot = hot + 0.5
		if hot > 6 then
			hot = 6
		end
	else
		hot = hot - 0.5
		if hot < 0 then
			hot = 0
		end
	end
	
	if hot > 0 then
		local p = 2
		buffer:captureAt(p)
		
		Graphics.drawScreen{
			priority = p,
			texture = buffer,
			shader = fire,
			uniforms = {
				time = lunatime.tick(),
				intensity = hot,
			},
		}
	end
	
	hud.showBossHP{
		icon = icon,
		amount = data.hp,
		max = maxHp,
	}
end

phases[1] = {}

local function movement1(s, vs)
	return function(v)
		v.speedY = vs or 3
		v.speedX = s
		v.ai1 = v.ai1 + 1
		
		if v.ai1 >= 16 then
			v.speedX = 0
			return true
		end
	end
end

phases[1].onTick = function(v)
	local data = v.data
	
	if player.x > v.x then
		v.speedX = v.speedX + 0.1
	elseif player.x < v.x then
		v.speedX = v.speedX - 0.1
	end
	
	v.ai1 = v.ai1 + 1
	
	if v.ai1 % 36 == 0 and v.ai1 >= 64 then
		data.frameTimer = 0
		data.frame = 2
		
		local n = NPC.spawn(754, v.x + 8, v.y + 32)
		n.data.movement = movement1(-2)
		
		local n = NPC.spawn(754, v.x + 8, v.y + 32)
		n.data.movement = movement1(2)
	end
	
	v.speedX = math.clamp(v.speedX, -6, 6)
end
phases[1].condition = function(phase, v)
	if v.ai1 > 192 then
		v.ai1 = 0
		return true
	end
end

local function movement2(t, dir)
	return function(v)
		v.speedY = 8
		v.ai1 = v.ai1 + 1
		if v.ai1 >= t then
			v.speedX = 4 * dir
			v.speedY = 0.5
			return
		end
	end
end

phases[2] = {}
phases[2].onTick = function(v)
	local data = v.data
	v.speedX = 0
	
	v.ai1 = v.ai1 + 1
	
	if v.ai1 % 32 == 0 and v.ai1 >= 64 then
		v.ai2 = v.ai2 + 8
		
		data.frameTimer = 0
		data.frame = 2
		
		local n = NPC.spawn(754, v.x + 8, v.y + 32)
		n.data.movement = movement2(v.ai2, (player.x + player.width / 2 > v.x + v.width / 2 and 1) or -1)
	end
end

phases[2].condition = function(phase, v)
	if v.ai1 > 160 then
		v.ai1 = 0
		v.ai2 = 0
		
		return true
	end
end

phases[3] = {}
phases[3].onTick = function(v)
	local data = v.data
	
	if player.x > v.x then
		v.speedX = v.speedX + 0.1
	elseif player.x < v.x then
		v.speedX = v.speedX - 0.1
	end
	
	v.ai1 = v.ai1 + 1
	
	if v.ai1 % 48 == 0 and v.ai1 >= 64 then
		data.frameTimer = 0
		data.frame = 2
		
		local n = NPC.spawn(755, v.x + 8, v.y + 32)
		n.speedY = 6
	end
	
	v.speedX = math.clamp(v.speedX, -6, 6)
end
phases[3].condition = function(phase, v)
	if v.ai1 > 192 then
		v.ai1 = 0
		return true
	end
end

phases[4] = {}
phases[4].onTick = function(v)
	local data = v.data
	
	if player.x > v.x then
		v.speedX = v.speedX + 0.1
	elseif player.x < v.x then
		v.speedX = v.speedX - 0.1
	end
	
	v.ai1 = v.ai1 + 1
	
	if v.ai1 % 16 == 0 and v.ai1 >= 64 and v.ai1 <= 96 then
		data.frameTimer = 0
		data.frame = 2
		
		local n = NPC.spawn(754, v.x + 8, v.y + 32)
		n.speedY = 6
		n.data.movement = function(v)
			v.ai1 = v.ai1 + 0.05
			
			v.speedX = math.cos(v.ai1) * 6
		end
	end
	
	v.speedX = math.clamp(v.speedX, -6, 6)
end
phases[4].condition = function(phase, v)
	if v.ai1 > 128 then
		v.ai1 = 0
		return true
	end
end

phases[5] = {}
phases[5].onTick = function(v)
	local data = v.data
	
	if player.x > v.x then
		v.speedX = v.speedX + 0.1
	elseif player.x < v.x then
		v.speedX = v.speedX - 0.1
	end
	
	v.ai1 = v.ai1 + 1
	
	if v.ai1 % 16 == 0 and v.ai1 >= 64 then
		data.frameTimer = 0
		data.frame = 2
		
		local n = NPC.spawn(755, v.x + 8, v.y + 32)
		n.speedY = 4
	end
	
	v.speedX = math.clamp(v.speedX, -6, 6)
end
phases[5].condition = function(phase, v)
	if v.ai1 > 128 then
		v.ai1 = 0
		return true
	end
end

phases[6] = {}
phases[6].onTick = function(v)
	local data = v.data
	
	v.speedX = 0
	v.ai1 = v.ai1 + 1
	
	if v.ai1 % 16 == 0 and v.ai1 >= 64 then
		data.frameTimer = 0
		data.frame = 2
		
		local n = NPC.spawn(755, v.x + 8, v.y + 32)
		n.speedY = 4
	end
end
phases[6].condition = function(phase, v)
	if v.ai1 > 192 then
		isHot = true
		v.ai1 = 0
		return true
	end
end

phases[7] = {}
phases[7].onTick = function(v)
	local data = v.data
	
	if player.x > v.x then
		v.speedX = v.speedX + 0.1
	elseif player.x < v.x then
		v.speedX = v.speedX - 0.1
	end
	
	v.ai1 = v.ai1 + 0.5
	
	if v.ai1 % 32 == 0 and v.ai1 >= 64 and v.ai1 < 160 then
		data.frameTimer = 0
		data.frame = 2
		
		local n = NPC.spawn(754, v.x + 8, v.y + 32)
		n.data.movement = movement1(-12, 2)
		
		local n = NPC.spawn(754, v.x + 8, v.y + 32)
		n.data.movement = movement1(-8, 2)
		
		local n = NPC.spawn(754, v.x + 8, v.y + 32)
		n.data.movement = movement1(-4, 2)
		
		local n = NPC.spawn(754, v.x + 8, v.y + 32)
		n.data.movement = movement1(4, 2)
		
		local n = NPC.spawn(754, v.x + 8, v.y + 32)
		n.data.movement = movement1(8, 2)
		
		local n = NPC.spawn(754, v.x + 8, v.y + 32)
		n.data.movement = movement1(12, 2)	
	end
	
	v.speedX = math.clamp(v.speedX, -6, 6)
end
phases[7].condition = function(phase, v)
	if v.ai1 > 192 then
		isHot = false
		v.ai1 = 0
		return true
	end
end

-- phases[3] = {}
-- phases[3].onTick = function(v)
	-- if player.x > v.x then
		-- v.speedX = v.speedX + 0.05
	-- elseif player.x < v.x then
		-- v.speedX = v.speedX - 0.05
	-- end
	
	-- v.ai1 = v.ai1 + 1
	
	-- if v.ai1 % 48 == 0 then
		-- local n = NPC.spawn(348, v.x + 16, v.y + 32)
		-- n.speedX = -3
		-- n.speedY = -1
		-- NPC.spawn(348, v.x + 16, v.y + 32)
		-- local n = NPC.spawn(348, v.x + 16, v.y + 32)
		-- n.speedY = -1
		-- n.speedX = 4
	-- end
	
	-- v.speedX = math.clamp(v.speedX, -6, 6)
-- end

-- phases[3].condition = function(phase, v)
-- end


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
	
	SFX.play('bossHit.ogg')
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

function boss.onInitAPI()
	registerEvent(boss, 'onNPCHarm')
	npcManager.registerEvent(id, boss, 'onTickNPC')
	npcManager.registerEvent(id, boss, 'onTickEndNPC')
	npcManager.registerEvent(id, boss, 'onCameraDrawNPC')
end

return boss