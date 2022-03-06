Graphics.activateHud(false);

SaveData._chosenLanguage = SaveData._chosenLanguage or false

local langIsSet = SaveData._chosenLanguage

if langIsSet then
	local celesteMap = require 'celesteMap'

	celesteMap.SFX = {
		select = 'devkit/click.ogg',
		choose = 'devkit/unpause.ogg',
	}

	celesteMap.addWorld{
		name = "Caucazeus",
		iconName = "caucazeus.png",
		musicName = 'world1.ogg',
		
		bgName = 'caucazeusBg.png',
		
		mesh = {
			{path = 'world1.obj', material = {color = Color.fromHexRGB(0x4D7F42)}},
			{path = 'world1_1.obj', material = {color = Color.fromHexRGB(0xBFFFE8)}},
		},
		
		levels = {
			{name = "Prologue", author = 'Core', fileName = 'prologue.lvlx'},	
			{name = "Cobble Canyon", author = 'UndeFin', fileName = 'Cobble Canyon.lvlx'},
			{name = "Deciduous Forest", author = 'Retro_games428', fileName = 'deciduous forest.lvlx'},
			{name = "Chicky Friendship", author = 'Core', fileName = 'chicky friendship.lvlx'},
			{name = "Shapeshifter", author = 'Alex1479', fileName = 'shapeshifter.lvlx'},
			{iconName = "boogie.png", name = "Boogie Boogie's Kitchen", author = 'Core', fileName = 'boogie boogie kitchen.lvlx'},
		}
	}
	
	celesteMap.addWorld{
		name = "Asgarden",
		iconName = "asgarden.png",
		musicName = 'world2.ogg',
				
		bgName = 'asgardenBg.png',
		
		ambient = Color.fromHexRGB(0xE4B9EA),
		
		mesh = {
			y = 500,
			
			{path = 'world2.obj', material = {color = Color.fromHexRGB(0xEFC6FF)}},
			{path = 'world2_1.obj', material = {color = Color.fromHexRGB(0x6D40A0)}},
			{path = 'world2_2.obj', material = {color = Color.fromHexRGB(0xFFD800), LIGHTING = "lighting_cel"}},
			{path = 'world2_ground.obj', material = {color = Color.fromHexRGB(0xACBFB9)}},	
			{path = 'world2_ground2.obj', material = {color = Color.fromHexRGB(0x20AD46)}},	
		},
		
		levels = {
			{name = "Celestial islands", author = 'Retro_games428', fileName = 'Celestial islands.lvlx'},
			{name = "Gloomy Heights", author = 'Greenlight', fileName = nil},
			{name = "Highest Tower", author = 'SonOfAHorde', fileName = nil},
			{name = "Majestic Melody", author = 'Core', fileName = 'majestic melody.lvlx'},
			{name = " - ", author = 'h2643', fileName = nil},
			{name = "Aurora Garden", author = 'UndeFin', fileName = nil},
			{iconName = "sherif.png", name = "Sherif Bun's Fortress", author = 'Core', fileName = 'sherif bun fortress.lvlx'},
		}
	}
	
	celesteMap.addWorld{
		name = "Zahara",
		iconName = "zahara.png",
		musicName = "world3.ogg",
		
		bgName = "zaharaBg.png",

		ambient = Color.fromHexRGB(0xFF8300),
		
		mesh = {
			y = 420,
			
			{path = 'world3.obj', material = {color = Color.fromHexRGB(0xFFE566)}},
			{path = 'world3_1.obj', material = {color = Color.fromHexRGB(0xC0C0C0)}},
			{path = 'world3_2.obj', material = {color = Color.fromHexRGB(0x7F3300)}},	
		},
		
		levels = {
			{name = "Sand Dunes", author = 'Lookich', fileName = 'Sand Dunes.lvlx'},
			{name = "El Norado", author = 'Core', fileName = 'el norado.lvlx'},
			{name = "The Purple", author = 'Doki', fileName = nil},
			{name = "Sandy Scrapyard", author = 'Greenlight', fileName = nil},
			{name = " - ", author = 'UndeFin', fileName = nil},
			{iconName = "hotie.png", name = "Hotbi's Gasline Temple", author = 'Core', fileName = nil},
		}
	}
	
	return
end

local textplus = require 'textplus'
local font =  textplus.loadFont("devkit/font.ini")

function onStart()
	player.forcedState = 8
	SFX.play(47)
end

local text = {
	['usa'] = 'Choose language!',
	['rus'] = 'Выберите язык!',
}

local langs = {
	{'usa', name = 'English'},
	{'rus', name = 'Русский'},
}

local currentLang = (SaveData.language == 'usa' and 0) or 1

local y = 160
local cursor = Graphics.sprites.hardcoded['34-0'].img

function onInputUpdate()
	local keys = player.rawKeys
	
	if keys.down == KEYS_PRESSED then
		SFX.play 'devkit/click.ogg'
		currentLang = (currentLang + 1) % #langs
		
		local lang = langs[currentLang + 1]
		SaveData.language = lang[1]
	elseif keys.up == KEYS_PRESSED then
		SFX.play 'devkit/click.ogg'
		currentLang = (currentLang - 1)
		
		if currentLang < 0 then
			currentLang = #langs - 1
		end
		
		local lang = langs[currentLang + 1]
		SaveData.language = lang[1]		
	elseif keys.jump then
		SaveData._chosenLanguage = true
		return Level.load()
	end
end

function onCameraDraw()
	textplus.print{
		text = text[SaveData.language],
		
		x = 232,
		y = 32,
		
		font = font,
		xscale = 3,
		yscale = 3,
		
		color = Color.yellow,
	}
	
	local dy = 0
	
	for key = 1, #langs do
		local lang = langs[key]
		
		if lang.img == nil then
			lang.img = Graphics.loadImageResolved('devkit/' .. lang[1] .. '.png')
		end
		
		Graphics.drawBox{
			texture = lang.img,
			
			x = 64,
			y = y + dy,
			width = 48,
			height = 48,
			
			color = (currentLang ~= (key - 1) and {0.5, 0.5, 0.5, 0.5}) or nil,
		}
		
		if (key - 1) == currentLang then
			Graphics.drawBox{
				texture = cursor,
				
				x = 16,
				y = y + dy + 8,
				width = 32,
				height = 32,
			}
		end
		
		textplus.print{
			text = lang.name,
			
			x = 128,
			y = y + dy,
			
			font = font,
			xscale = 2,
			yscale = 2,		
		}
		
		dy = dy + 64
	end
end