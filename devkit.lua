local path = "devkit/"

--Save stuff
SaveData.language = SaveData.language or 'usa'

require(path .. "hud")
local ld = require('littleDialogue')
ld.registerStyle("rmc",{
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
	useMaxWidthAsBoxWidth = true,
    textMaxWidth = 300,
})
ld.defaultStyleName = "rmc"

require(path .. "pause")

local files = Misc.listFiles(Misc.episodePath() .. 'lang')
for k,v in ipairs(files) do
	local path = Misc.resolveFile('lang/' .. v)
	
	local file = io.open(path)
	loadstring(file:read("*a"))()
	
	file:close()
end