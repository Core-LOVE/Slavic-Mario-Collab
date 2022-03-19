local pauseDebug = false

local pause = {}
pause.disabled = false

SaveData.disableShake = SaveData.disableShake or false

SaveData.optimizeWeather = SaveData.optimizeWeather or false
SaveData.optimizeOther = SaveData.optimizeOther or false
SaveData.optimizeDarkness = SaveData.optimizeDarkness or false

local initDark = {}
local initWeather = {}

function pause.onTick()
	if not SaveData.disableShake then return end
	
	if Defines.earthquake ~= 0 then
		Defines.earthquake = 0
	end	
end

function pause.onStart()
	for k,v in ipairs(Section.get()) do
		local dark = v.darkness
		
		if dark.enabled ~= nil and dark.enabled == false then
			initDark[v.idx] = true
		end
	end
	
	if SaveData.optimizeOther and onOptimize then
		onOptimize(SaveData.optimizeOther)
	end
	
	for k,v in ipairs(Section.get()) do
		if SaveData.optimizeDarkness then
			local dark = v.darkness
			
			if dark.enabled ~= nil and initDark[v.idx] == nil then
				dark.enabled = not dark.enabled
			end
		end
		
		if SaveData.optimizeWeather then
			local effects = v.effects
			local weather = effects.weather
			
			if initWeather[v.idx] == nil and weather ~= 0 then
				initWeather[v.idx] = weather
				
				effects.weather = 0
			else
				effects.weather = initWeather[v.idx]
				initWeather[v.idx] = nil
			end
		end
	end
end

function pause.onPause(eventObj)
	-- Just in case make sure this event isn't already flagged as cancelled
	if not eventObj.cancelled then
		-- Prevent normal pausing
		eventObj.cancelled = true

		if not pause.disabled then
			Audio.MusicVolume(8)
			
			-- Set your own pause state
			myPauseActive = true
			
			SFX.play 'devkit/pause.ogg'
			
			-- Pause the game via Lua
			Misc.pause()
		end
	end
end

local options = {}

local langs = {}

do
	local count = 1
	
	for k,v in pairs(Languages) do
		langs[count] = k
		
		count = count + 1
	end
end

local icons = _G.Languages
local check = Graphics.loadImageResolved 'devkit/check.png'

local settings = {
	name = 'Settings',
	cursor = 0,
	
	{
		name = 'Return',
		
		action = function()
			local parent = options.parent
			
			options = parent
			options.parent = nil
		end,
	},
	
	{
		name = "Change Language",
		
		action = function()
			local pos = 1
			
			for k,v in ipairs(langs) do
				if v == SaveData.language then
					pos = k
				end
			end
			
			if langs[pos + 1] ~= nil then
				SaveData.language = langs[pos + 1]
			else
				SaveData.language = langs[1]
			end
		end,
		
		icon = function(x, y)
			Graphics.drawBox{
				texture = icons[SaveData.language],
				
				x = x,
				y = y - 6,
				priority = 7,
			}
		end,
	},
	
	{
		name = 'Disable Screenshake',
		icon = function(x, y)
			return (SaveData.disableShake and 1) or 0
		end,
		
		action = function()
			SaveData.disableShake = not SaveData.disableShake
		end,
	},
	
	{
		name = 'Darkness',
		icon = function(x, y)
			return (SaveData.optimizeDarkness and 1) or 0
		end,
					
		action = function()
			for k,v in ipairs(Section.get()) do
				SaveData.optimizeDarkness = not SaveData.optimizeDarkness
				
				local dark = v.darkness
				
				if dark.enabled ~= nil and initDark[v.idx] == nil then
					dark.enabled = not dark.enabled
				end
			end
		end,
	},
	
	{
		name = 'Weather',
		icon = function(x, y)
			return (SaveData.optimizeWeather and 1) or 0
		end,
		
		action = function()
			for k,v in ipairs(Section.get()) do
				SaveData.optimizeWeather = not SaveData.optimizeWeather
				
				local effects = v.effects
				local weather = effects.weather
				
				if initWeather[v.idx] == nil and weather ~= 0 then
					initWeather[v.idx] = weather
					
					effects.weather = 0
				else
					effects.weather = initWeather[v.idx]
					initWeather[v.idx] = nil
				end
			end
		end,
	},
	
	{
		name = 'Other Optimizations',
		icon = function(x, y)
			return (SaveData.optimizeOther and 1) or 0
		end,
		
		action = function()
			SaveData.optimizeOther = not SaveData.optimizeOther
			
			if onOptimize then
				onOptimize(SaveData.optimizeOther)
			end
		end
	},
}

options.cursor = 0
options.name = "Menu"

table.insert(options, {
	name = 'Continue',
	
	action = function()
		Audio.MusicVolume(64)
		Misc.unpause()
	end,
})

if Level.filename() ~= 'worldmap.lvlx' then
	table.insert(options, {
		name = 'Restart',
		
		action = function()
			Level.load(Level.filename())
			Audio.MusicVolume(64)
			
			Misc.unpause()
		end,
	})
end

table.insert(options, {
	name = 'Settings',
	
	action = function()
		local parent = options
		
		options = settings
		options.parent = parent
	end,
})

table.insert(options, {
	name = 'Exit',
	
	action = function()
		if Misc.inEditor() then
			Level.load()
			Misc.unpause()
			return
		end
		
		if Level.filename() == 'worldmap.lvlx' then
			Misc.exitEngine()
		else
			alpha = 0
			SFX.play 'devkit/unpause.ogg'
			
			Misc.unpause()	
			Audio.MusicVolume(64)
			
			Level.load('worldmap.lvlx')
		end
	end,
})

-- local translation = {}

-- translation['rus'] = {
	-- ['Menu'] = 'Меню',
	-- ['Continue'] = 'Продолжить',
	-- ['Restart'] = 'Рестарт',
	-- ['Exit'] = 'Выйти',
	
	-- ['Settings'] = 'Настройки',
	-- ['Return'] = 'Вернуться',
	-- ['Change Language'] = 'Сменить Язык',
	-- ['Disable Screenshake'] = 'Отключить тряску камеры',
	-- ['Darkness'] = 'Темнота',
	-- ['Weather'] = 'Эффекты',
	-- ['Other Optimizations'] = 'Другие оптимизации',
-- }

function pause.onInputUpdate()
	if pauseDebug and Misc.GetKeyState(0x43) and not Misc.isPaused() then
		Misc.openPauseMenu()
	end
	
	if myPauseActive and not Misc.isPausedByLua() then
		Audio.MusicVolume(64)
		
		-- If other code unpaused us, well, clear our pause state I guess
		myPauseActive = false
	end

	-- If our pause state is active, handle input
	if myPauseActive then
		player.keys.dropItem = false
		
		local rk = player.rawKeys
		
		if (rk.run == KEYS_PRESSED) then
			local parent = options.parent
			SFX.play 'devkit/click.ogg'
			
			if parent then
				options = parent
				options.parent = nil
			else
				Audio.MusicVolume(64)
				Misc.unpause()
				return
			end
		end
		
		if (rk.pause == KEYS_PRESSED) then
			Audio.MusicVolume(64)
			Misc.unpause()
			return
		end
		
		if (rk.down == KEYS_PRESSED) then
			SFX.play 'devkit/click.ogg'
			options.cursor = (options.cursor + 1) % #options
		end
		
		if (rk.up == KEYS_PRESSED) then
			SFX.play 'devkit/click.ogg'
			options.cursor = (options.cursor - 1)
			if options.cursor < 0 then
				options.cursor = #options - 1
			end
		end
		
		if (rk.jump == KEYS_PRESSED) then
			SFX.play 'devkit/click.ogg'
			
			local option = options[options.cursor + 1]
			
			if option.action then
				option.action()
			end
			
			player.keys.jump = false
		end
	end
end

local textplus = require 'textplus'
local font =  textplus.loadFont("devkit/font.ini")

local cursor = Graphics.sprites.hardcoded['34-0'].img

function pause.onDraw()
	if myPauseActive and not Misc.isPausedByLua() then
		-- If other code unpaused us, well, clear our pause state I guess
		myPauseActive = false
	end

	-- If our pause state is active, draw accordingly
	if not myPauseActive then 
		local parent = options.parent
		
		if parent then
			options = parent
			options.parent = nil
		end
		
		return 
	end
	
	Graphics.drawScreen{
		color = Color.black .. 0.5,
		priority = 7,
	}
	
	local lang = SaveData.language
	
	local count = 32
	local dy = -(#options * count) * 0.5
	
	do
		local name = options.name
		
		if lang ~= 'usa' and littleDialogue.translation[lang] and littleDialogue.translation[lang][name] then
			name = littleDialogue.translation[lang][name]
		end
		
		Graphics.drawBox{
			x = 0,
			y = (300 + dy) - count * 0.5,
			width = 800,
			height = (#options * count) + count * 0.5,
			
			priority = 7,
			color = {0,0,0,0.5},
		}
		
		textplus.print{
			text = name,
			font = font,
			
			x = 32,
			y = (300 + dy) - count,
			
			xscale = 3,
			yscale = 3,	
			
			priority = 7,
		}
	end
	
	for index, option in ipairs(options) do
		local name = option.name
		
		if lang ~= 'usa' and littleDialogue.translation[lang] and littleDialogue.translation[lang][name] then
			name = littleDialogue.translation[lang][name]
		end
		
		Graphics.drawBox{
			x = 0,
			y = (300 + dy) - 8,
			width = 800,
			height = 28,
			
			priority = 7,
			color = {0,0,0,1},
		}
		
		local col = nil
		
		if index == options.cursor + 1 then
			col = Color.yellow
			
			Graphics.drawBox{
				texture = cursor,
				
				priority = 7,
				x = 16,
				y = (300 + dy),
			}
		end
		
		textplus.print{
			text = name,
			font = font,
			x = 64,
			y = 300 + dy,
			
			xscale = 2,
			yscale = 2,
			
			priority = 7,	
			color = col,
		}
		
		if type(option.icon) == 'boolean' then

		elseif type(option.icon) == 'function' then
			local state = option.icon(800 - 64, 300 + dy)
			local h = check.height * 0.5
			
			if state then
				Graphics.drawBox{
					texture = check,
					
					x = 800 - 64,
					y = 300 + dy,
					
					sourceY = h * state,
					sourceHeight = h,
					priority = 7,
				}
			end
		else
			if option.icon ~= nil then

			end
		end
		
		dy = dy + count
	end
end

function pause.onInitAPI()
	registerEvent(pause, 'onTick')
	registerEvent(pause, 'onInputUpdate')
	registerEvent(pause, 'onDraw')
	registerEvent(pause, 'onPause')
	registerEvent(pause, 'onStart')
end

return pause
