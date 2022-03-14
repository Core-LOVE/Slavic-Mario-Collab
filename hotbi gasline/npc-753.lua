local boss = {}

local hud = require 'devkit/hud'

local npcManager = require 'npcManager'
local id = NPC_ID

local maxHp = 10

npcManager.setNpcSettings{
	id = id,
	
	frames = 2,
	framestyle = 0,
	framespeed = 8,
	
	jumphurt = false,
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
		priority = -40,
		
		color = Color.white .. col,
	}
	
	hud.showBossHP{
		icon = icon,
		amount = data.hp,
		max = maxHp,
	}
end

phases[1] = {}
phases[1].onTick = function(v)
	-- local data = v.data
	
	if player.x > v.x then
		v.speedX = v.speedX + 0.1
	elseif player.x < v.x then
		v.speedX = v.speedX - 0.1
	end
	
	v.ai1 = v.ai1 + 1
	
	if v.ai1 % 32 == 0 then
		NPC.spawn(348, v.x + 16, v.y + 32)
	end
	
	v.speedX = math.clamp(v.speedX, -6, 6)
end
phases[1].condition = function(phase, v)
	if v.ai1 > 160 then
		v.ai1 = 0
		return true
	end
end

phases[2] = {}
phases[2].onTick = function(v)
	v.speedX = 0
	
	v.ai1 = v.ai1 + 1
	if v.ai1 > 64 and v.ai1 % 32 == 0 then
		NPC.spawn(361, v.x + 16, v.y + 32)	
	end
end

phases[2].condition = function(phase, v)
	if v.ai1 > 160 then
		v.ai1 = 0
		return true
	end
end

phases[3] = {}
phases[3].onTick = function(v)
	if player.x > v.x then
		v.speedX = v.speedX + 0.05
	elseif player.x < v.x then
		v.speedX = v.speedX - 0.05
	end
	
	v.ai1 = v.ai1 + 1
	
	if v.ai1 % 48 == 0 then
		local n = NPC.spawn(348, v.x + 16, v.y + 32)
		n.speedX = -3
		n.speedY = -1
		NPC.spawn(348, v.x + 16, v.y + 32)
		local n = NPC.spawn(348, v.x + 16, v.y + 32)
		n.speedY = -1
		n.speedX = 4
	end
	
	v.speedX = math.clamp(v.speedX, -6, 6)
end

phases[3].condition = function(phase, v)
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
	Audio.SeizeStream(player.section)
	Audio.MusicStop()
	
	-- local n = NPC.spawn(489, v.x, v.y)
	Misc.pause()
	
	Routine.wait(1, true)
	Misc.unpause()
	-- Effect.spawn(752, n.x, n.y)
	-- n:kill(9)
	
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
	
	SFX.play(1)
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