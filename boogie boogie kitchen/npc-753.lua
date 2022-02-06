local boss = {}

local npcManager = require 'npcManager'
local id = NPC_ID

npcManager.setNpcSettings{
	id = id,
	
	frames =4,
	jumphurt = false,
	nohurt = false,
	jumphurt = false,
	
	width=64,
	height=64,
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
	
	if not v.collidesBlockBottom then
		if math.abs(v.speedX) >= 6 then
			data.frame = 3
		else
			data.frame = 2
		end
	end

	v.animationFrame = -1
end

phases.onCameraDraw = function(v)
	local data = v.data
	local cfg = NPC.config[id]
	
	local rot = 0
	
	if math.abs(v.speedX) >= 6 and not v.collidesBlockBottom then 
		data.rot = data.rot or 0
		
		data.rot = data.rot + 24
		
		rot = data.rot
	end
	
	local w = v.width
	local x = 0
	
	if v.direction == 1 then
		w = -w
		x = 0
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
		
		x = (v.x + v.width / 2) + x,
		y = v.y + v.height / 2,
		
		sceneCoords = true,
		frame = data.frame + 1,
		frames = cfg.frames,
		
		width = w,
		
		pivot = Sprite.align.CENTER,
		rotation = rot,
		priority = -40,
		
		color = Color.white .. col,
	}
end

phases[1] = {}
phases[1].onTick = function(v)
	if not v.collidesBlockBottom then return end
	
	v.speedX = 0.5 * v.direction
end

phases[2] = {}
phases[2].onTick = function(v)
	if math.abs(v.speedX) < 3 then
		v.speedX = 3 * v.direction
	end
	
	if v.collidesBlockBottom then
		v.speedY = -12
		SFX.play('bossJump.ogg')
	end
	
	if v.collidesBlockLeft or v.collidesBlockRight then
		Defines.earthquake = 10
		v.speedX = 12 * v.direction
		v.speedY = -8
		SFX.play('bossBounce.ogg')	
		
		for i = 0, 360, 60 do
			local angle = math.rad(i)
			
			local n = NPC.spawn(202, v.x + 16, v.y + 16)
			n.speedX = math.cos(angle) * 4
			n.speedY = math.sin(angle) * 4
		end
	end
	
	if v.collidesBlockTop then
		Defines.earthquake = 10
		v.speedX = 8 * v.direction
		v.speedY = 12
		SFX.play('bossBounce.ogg')	
	end
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

function boss.onNPCHarm(e, v, r, o)
	if v.id ~= id then return end
	
	local data = v.data
	
	if data.immune > 0 then
		e.cancelled = true
		return
	end
	
	SFX.play('bossBonk.ogg')
	Defines.earthquake = 6
	
	if data.hp > 0 then
		data.hp = (data.hp - 1)
		data.immune = 60
		
		e.cancelled = true
	else
	
	end
end

function boss.onTickNPC(v)
	local data = v.data
	
	if not data.init then
		data.phaseTimer = 0
		data.phase = 0
		data.hp = 6
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