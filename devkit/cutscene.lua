local cutscene = {}

cutscene.borders = {}
cutscene.defaultBorder = 'default'

function cutscene.registerBorder(name, f)
	cutscene.borders[name] = f
end

function cutscene.getDefaultBorder()
	return cutscene.borders[cutscene.defaultBorder]
end

cutscene.registerBorder('default', function(t)
	local h = t * 1.75
	
	if h > 48 then
		h = 48
	end
	
	Graphics.drawBox{
		x = 0,
		y = 0,
		width = 800,
		height = h,
		
		priority = 4,
		color = Color.black,
	}
	
	Graphics.drawBox{
		x = 0,
		y = 600 - h,
		width = 800,
		height = h,
		
		priority = 4,
		color = Color.black .. (h / 48),
	}
end)

cutscene.utils = {}

function cutscene.utils.lockInput()
	for _,p in ipairs(Player.get()) do
		for k,v in pairs(p.keys) do
			p.keys[k] = false
		end
 	end
end

do
	local hiddenPlayers = {}

	function cutscene.utils.hidePlayers()
		for _,p in ipairs(Player.get()) do
			if p.forcedState ~= FORCEDSTATE_INVISIBLE then
				hiddenPlayers[p] = p.forcedState
				
				p.forcedState = FORCEDSTATE_INVISIBLE
			end
		end
	end

	function cutscene.utils.showPlayers()
		for _,p in ipairs(Player.get()) do
			if p.forcedState == FORCEDSTATE_INVISIBLE and hiddenPlayers[p] then
				p.forcedState = hiddenPlayers[p]
			end
		end
	end
end

local easing = require 'ext/easing'

local exitBorder

function cutscene.utils.exitBorder(b, time)
	exitBorder = {
		f = b,
		time = time,
	}
end

local function cutsceneStopBorder(v, t)
	local b = v.border
	
	if type(b) == 'boolean' then
		b = cutscene.borders[cutscene.defaultBorder]
	end
			
	cutscene.utils.exitBorder(b, t)
end

function cutscene.new(v)
	local v = v or {}
	
	v.actions = v.actions or {}
	v.name = #cutscene + 1
	v.isRunning = false
	v.timer = 0
	v.canSkip = (v.canSkip ~= nil and v.canSkip) or true
	
	setmetatable(v, {__index = cutscene})
	cutscene[#cutscene + 1] = v
	return v
end

function cutscene:run()
	self.isRunning = true
	self.timer = 0
end

function cutscene:stop(borderT)
	self.isRunning = false
	self.timer = 0
	
	cutsceneStopBorder(self, borderT)
	
	for _,box in ipairs(littleDialogue.boxes) do
		box:close()
	end
end

function cutscene:add(order, f)
	if f ~= nil then
		self.actions[order] = f
	else
		self.actions[#self.actions + 1] = order
	end
end

function cutscene:remove()
	for k,v in ipairs(cutscene) do
		if v == self then
			return table.remove(cutscene, k)
		end
	end
end

function cutscene.onTick()
	local show = true
	
	for k,v in ipairs(cutscene) do
		if v.isRunning then
			v.timer = v.timer + 1
			
			local f = v.actions[v.timer]
			
			if f ~= nil then
				Routine.run(f)
			end
			
			if v.hidePlayers then
				show = false
				cutscene.utils.hidePlayers()
				break
			end
		end
	end
	
	if show then
		cutscene.utils.showPlayers()
	end
end

function cutscene.onInputUpdate()
	for k,v in ipairs(cutscene) do
		if v.isRunning and v.lockInput then
			-- if player.keys.altRun then
				-- local val
				
				-- if v.onSkip then
					-- val = v.onSkip()
				-- end
				
				-- v:stop(val)
			-- end
			
			return cutscene.utils.lockInput()
		end
	end
end

-- local skip = Graphics.loadImageResolved 'littleDialogue/keys/button_altrun.png'
local textplus = require 'textplus'

function cutscene.onCameraDraw()
	for k,v in ipairs(cutscene) do
		if v.isRunning and v.border then
			local b = v.border
			
			if type(b) == 'boolean' then
				cutscene.borders[cutscene.defaultBorder](v.timer)
			else
				b(v.timer)
			end
			
			-- if v.canSkip then
				-- Graphics.drawImageWP(skip, 800 - 128, 600 - 32, 5)
				
				-- textplus.print{
					-- text = "to Skip",
					
					-- x = 800 - 72,
					-- y = 600 - 32,
					
					-- xscale = 2,
					-- yscale = 2,
					
					-- priority = 5,
				-- }
			-- end
		end
	end
	
	if exitBorder then
		exitBorder.time = exitBorder.time - 1
		
		exitBorder.f(exitBorder.time)
	end
end

function cutscene.onInitAPI()
	registerEvent(cutscene, 'onInputUpdate')
	registerEvent(cutscene, 'onTick')
	registerEvent(cutscene, 'onCameraDraw')
end

return cutscene