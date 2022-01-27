-- a lib for boss creation

local boss = {}
local npcManager = require 'npcManager'

local registerEvents = {
	'onTickNPC', 'onTickEndNPC',
	'onCameraDrawNPC',
	'onNPCHarm',
}

local nonNPCEvents = {
	['onNPCHarm'] = true,
}

function boss.new(args)
	local self = args or {}
	
	--sum settings
	args.hp = args.hp or 3
	args.immuneTimer = args.immuneTimer or 60
	args.flashWhenImmune = (args.flashWhenImmune == nil and true) or args.flashWhenImmune
	
	args.phase = args.phase or 0
	args.randomizedPhases = args.randomizedPhases or false
	
	-- config (MUST HAVE)
	args.config = args.config or args.configuration
	npcManager.setNpcSettings(args.config)
	
	-- harm types
	do
		local harmTypes = args.harmTypes or {
			HARM_TYPE_JUMP,
			HARM_TYPE_FROMBELOW,
			HARM_TYPE_NPC,
			HARM_TYPE_PROJECTILE_USED,
			HARM_TYPE_LAVA,
			HARM_TYPE_HELD,
			HARM_TYPE_TAIL,
			HARM_TYPE_SPINJUMP,
		}
		
		local harmEffects = args.harmEffects or {}
		
		npcManager.registerHarmTypes(args.config.id, harmTypes, harmEffects)
	end
	
	-- i need to init data (and more)
	do
		local onTickNPC = args.onTickNPC
		args.onTickNPC = function(v)
			local data = v.data
			
			if not data.bossInit then
				data.phaseTimer = 0
				data.phase = args.phase
				
				data.hp = args.hp
				data.immuneTimer = 0
				
				data.bossInit = true
			end
			
			if data.immuneTimer > 0 then
				data.immuneTimer = data.immuneTimer - 1
			end
			
			if args.phases then
				local phase = args.phases[data.phase + 1]
				
				phase[1](v, data.phaseTimer)
				data.phaseTimer = data.phaseTimer + 1
				
				if data.phaseTimer > phase.maxTimer or 180 then
					if args.randomizedPhases then
						data.phase = math.random(1, #args.phases) - 1
					else
						data.phase = (data.phase + 1) % #args.phases
					end
					
					data.phaseTimer = 0
				end
			end
			
			if onTickNPC then
				onTickNPC(v)
			end
		end
	end
	
	-- flash handling
	do
		local onTickEndNPC = args.onTickEndNPC
		args.onTickEndNPC = function(v)
			local data = v.data
			
			if data.immuneTimer > 0 and args.flashWhenImmune then
				if math.random() > 0.5 then
					v.animationFrame = -1
				end
			end
			
			if onTickEndNPC then
				onTickEndNPC(v)
			end
		end
	end
	
	-- i need to make auto harming registering
	do
		local onNPCHarm = args.onNPCHarm
		args.onNPCHarm = function(e, v, r, c)
			if v.id ~= args.config.id then return end

			local data = v.data
			
			if data.hp > 0 then
				data.hp = data.hp - 1
				data.immuneTimer = args.immuneTimer
			end
			
			if data.immuneTimer > 0 then
				e.cancelled = true
			end
			
			if onNPCHarm then
				onNPCHarm(e, v, r, c)
			end
		end
	end
	
 	-- registering events...
	for k,v in ipairs(registerEvents) do
		if not nonNPCEvents[v] then
			npcManager.registerEvent(args.config.id, args, v)
		else
			registerEvent(args, v)
		end
	end
	
	args.onNPCHarm = args.onNPCHarm or function(e, v, r, c)
		
	end
	
	return self
end

return boss