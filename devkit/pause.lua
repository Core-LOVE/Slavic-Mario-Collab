local pause = {}

local myPauseActive = false

local alpha = 0

local lang = (SaveData.language == 'usa' and 1) or 0

local langsSet = {
	'rus',
	'usa',
}

local names = {
	['rus'] = {
		'Продолжить',
		'Рестарт',
		'Язык',
		'Выйти',
	},
	
	['usa'] = {
		'Continue',
		'Restart',
		'Language',
		'Exit',
	},
}

local langs = {
	Graphics.loadImageResolved("devkit/rus.png"),
	Graphics.loadImageResolved("devkit/usa.png"),
}

local function restart()
	Misc.unpause()
	alpha = 0
	SFX.play 'devkit/unpause.ogg'
	
	Level.load()
end

local options = {
	{name = "Continue", action = function()
		alpha = 0
		SFX.play 'devkit/unpause.ogg'
		
		Misc.unpause()	
	end},
	
	{name = "Restart", action = restart},
	
	{name = "Language", drawIcon = true},
	
	{name = "Exit", action = function()
		if Misc.inEditor() then
			return restart()
		end
		
		Misc.exitEngine()
	end},
}

options[3].action = function()
	lang = (lang + 1) % #langs
	SaveData.language = langsSet[lang + 1]
	
	local n = langsSet[lang + 1]
	
	for k,v in ipairs(options) do
		v.name = names[n][k]
	end
end

local n = langsSet[lang + 1]

for k,v in ipairs(options) do
	v.name = names[n][k]
end
	
local option = 0

function pause.onPause(eventObj)
	-- Just in case make sure this event isn't already flagged as cancelled
	if not eventObj.cancelled then
		-- Prevent normal pausing
		eventObj.cancelled = true

		-- Set your own pause state
		myPauseActive = true
		
		SFX.play 'devkit/pause.ogg'
		
		-- Pause the game via Lua
		Misc.pause()
	end
end

local textplus = require 'textplus'
local font =  textplus.loadFont("devkit/font.ini")

function pause.onDraw()
	if myPauseActive and not Misc.isPausedByLua() then
		-- If other code unpaused us, well, clear our pause state I guess
		myPauseActive = false
	end

	-- If our pause state is active, draw accordingly
	if not myPauseActive then return end
	
	if alpha < 0.5 then
		alpha = alpha + 0.05
	end
	
	Graphics.drawScreen{color={0,0,0,alpha}, priority = 5}
	
	local x = 250
	local y = 200
	local w = 300
	local h = 150
	
	Graphics.drawBox{
		x = x,
		y = y,
		width = w,
		height = h,
		
		color={0,0,0,alpha + 0.5},
		priority = 5
	}
	
	
	for k,v in ipairs(options) do	
		local dy = 32 * k
		dy = dy - 16
		
		textplus.print{
			text = v.name, 
			x = x + 64, 
			y = y + dy, 
			priority = 5,
			font = font,
			
			xscale = 2,
			yscale = 2,
		}
		
		if v.drawIcon then
			Graphics.drawBox{texture = langs[lang + 1], x = (x + w) - 48, y = y + dy, priority = 5}
		end
		
		if option + 1 == k then
			Graphics.drawBox{texture = Graphics.sprites.hardcoded['34-0'].img, x = x + 16, y = y + dy, priority = 5}
		end
	end
end

local pauseDebug = true

function pause.onInputUpdate()
	if pauseDebug and Misc.GetKeyState(0x43) and not Misc.isPaused() then -- C button
		Misc.openPauseMenu()
	end
	
	if myPauseActive and not Misc.isPausedByLua() then
		-- If other code unpaused us, well, clear our pause state I guess
		myPauseActive = false
	end

	-- If our pause state is active, handle input
	if myPauseActive then
		local rk = player.rawKeys
		
		if rk.down == KEYS_PRESSED then
			SFX.play 'devkit/click.ogg'
			option = (option + 1) % #options
		end
		
		if rk.up == KEYS_PRESSED then
			SFX.play 'devkit/click.ogg'
			option = (option - 1)
			
			if option < 0 then
				option = #options - 1
			end
		end
		
		local o = options[option + 1]
		
		if rk.jump == KEYS_PRESSED and o.action then
			SFX.play 'devkit/click.ogg'
			o.action()
		end
	end
end

function pause.onInitAPI()
	registerEvent(pause, 'onInputUpdate')
	registerEvent(pause, 'onDraw')
	registerEvent(pause, 'onPause')
end

return pause