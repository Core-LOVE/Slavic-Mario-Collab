local path = "devkit/"
_G.PowerDown = require(path .. 'powerdown')
_G.warpTransition = require(path .. 'warpTransition')
_G.Details = require(path .. 'details')
--Save stuff
SaveData.language = SaveData.language or 'usa'

require(path .. 'death')
_G.HUDER = require(path .. "hud")
local ld = require('littleDialogue')
ld.registerStyle("rmc",{
    textColor = Color.black,

    typewriterEnabled = true,
    typewriterDelayNormal = 1, -- The usual delay between each character.
    typewriterDelayLong = 4,  -- The extended delay after any of the special delaying characters, listed below.
    typewriterSoundDelay = 5,  -- How long there must between each sound.
	
    borderSize = 12,
    showTextWhileOpening = true,

    openStartScaleX = 0,
    openStartScaleY = 0,
    openStartOpacity = 0.5,

    speakerNameOnTop = true,
    speakerNameOffsetX = 24,
    speakerNameOffsetY = 4,
    speakerNamePivot = 0,
    speakerNameXScale = 2,
    speakerNameYScale = 2,

    openSpeed = 0.09,
    pageScrollSpeed = 0.09,
	
    forcedPosEnabled = true,
    forcedPosX = 400,
    forcedPosY = 200,
    forcedPosHorizontalPivot = 0.5,
    forcedPosVerticalPivot = 0,
	
	minBoxMainHeight = 104,
})
ld.defaultStyleName = "rmc"

_G.littleDialogue = ld

_G.Languages = {
	['usa'] = Graphics.loadImageResolved('lang/usa.png')
}

_G.LanguagesName = {
	['usa'] = 'English',
}

local files = Misc.listFiles(Misc.episodePath() .. 'lang')
for k,v in ipairs(files) do
	if v:find('.lua') then
		local path = Misc.resolveFile('lang/' .. v)
		
		local file = io.open(path)
		local code = loadstring(file:read("*a"))
		code()
		
		assert(code, 'Found error in ' .. v)
		
		file:close()
		
		local name = v:gsub('.lua', '')
		Languages[name] = Graphics.loadImageResolved('lang/' .. name .. '.png')
	end
end

_G.cutscene = require(path .. "cutscene")

_G.Pauser = require(path .. "pauser")

local devkit = {}

function devkit.onExitLevel(win)
	if win <= 0 then return end
	
	local status = pcall(function() 
		require('worldmap/celesteMap')
	end)
	
	if status then
		local celesteMap = require('worldmap/celesteMap')
		celesteMap.progress()
	end
end

function devkit.onInitAPI()
	registerEvent(devkit, 'onExitLevel')
end

return devkit