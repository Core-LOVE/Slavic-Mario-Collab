Graphics.activateHud(false);

SaveData._chosenLanguage = SaveData._chosenLanguage or false

local langIsSet = SaveData._chosenLanguage

if langIsSet then
	function onStart()
		player.character = 1
	end
	
	function onInputUpdate()
		player.keys.dropItem = false
	end
	
	local celesteMap = require 'celesteMap'

	celesteMap.starCount = function()
		return SaveData.cloversCount or 0
	end
	celesteMap.starIcon = Graphics.loadImageResolved 'devkit/clover.png'
	
	celesteMap.coinIcon = Graphics.loadImageResolved 'devkit/coin.png'
	celesteMap.coinCount = true
	
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
			{iconName = 'start.png', name = "Prologue", author = 'Core', fileName = 'prologue.lvlx'},	
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
			{name = "Highest Tower", author = 'SonOfAHorde', fileName = nil},
			{name = "Dental Debacle", author = 'h2643', fileName = 'Dental Debacle.lvlx'},
			{name = "Majestic Melody", author = 'Core', fileName = 'majestic melody.lvlx'},
			{name = "Gloomy Heights", author = 'Greenlight', fileName = 'Gloomy Heights.lvlx'},
			{name = "Aurora Garden", author = 'UndeFin', fileName = 'Aurora Garden.lvlx'},
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
			{name = "Twilight Around The Debris", author = 'UndeFin', fileName = nil},
			{name = "Secrets of Egyptian Pyramid", author = 'SkullGamer205', fileName = nil},
			{iconName = "hotie.png", name = "Hotbi's Gasline", author = 'Core', fileName = 'hotbi gasline.lvlx'},
		}
	}
	
	celesteMap.addWorld{
		name = "Anterpole",
		iconName = "anterpole.png",
		musicName = 'world4.ogg',
		
		ambient = Color.fromHexRGB(0x255EB2),
		
		bgName = 'anterpoleBg.png',
		
		mesh = {
			{path = 'world4.obj', material = {color = Color.fromHexRGB(0xE5FAFF)}},
			{path = 'world4_1.obj', material = {color = Color.fromHexRGB(0x8EE547)}},
			{path = 'world4_2.obj', material = {color = Color.fromHexRGB(0x31BCBC)}},
		},
		
		levels = {
			{name = " - ", author = 'George 7up', fileName = nil},
			{name = " - ", author = '1230m 1', fileName = nil},
			{name = "Duality", author = 'Core', fileName = 'duality.lvlx'},
			{name = " - ", author = ' - ', fileName = nil},
			{iconName = "belly.png", name = "Dancing Belly's Opera", author = 'Core', fileName = nil},
		}
	}
	
	celesteMap.addWorld{
		name = "Blockade",
		iconName = "blockade.png",
		musicName = 'world5.ogg',
		
		ambient = Color.fromHexRGB(0xA5846F),
		
		bgName = 'blockadeBg.png',
		
		mesh = {
			y = 420,
			scale = 10,
			
			{path = 'world5.obj', material = {color = Color.fromHexRGB(0x606060)}},
			{path = 'world5_1.obj', material = {color = Color.fromHexRGB(0xC0C0C0)}},
			{path = 'world5_2.obj', material = {color = Color.fromHexRGB(0x00FFFF)}},
		},
		
		levels = {
			{name = " - ", author = ' - ', fileName = nil},	
			{name = "Breaking News", author = 'Core', fileName = nil},
			{name = "Mushroom Cafe", author = 'Core', fileName = nil},
			{name = " - ", author = ' - ', fileName = nil},
			{name = " - ", author = ' - ', fileName = nil},
			{name = " - ", author = ' - ', fileName = nil},
			{name = " - ", author = ' - ', fileName = nil},
			{name = "Aerial Apotheosis", author = 'Greenlight', fileName = nil},
			{iconName = "confident.png", name = "Confident Tanks", author = 'Core', fileName = nil},
			{iconName = "last.png", name = "Epilogue", author = 'Core', fileName = nil},
		}
	}
	
	return
end

Pauser.disabled = true
local textplus = require 'textplus'
local font =  textplus.loadFont("devkit/font.ini")

function onStart()
	player.forcedState = 8
	SFX.play(47)
end

-- local text = {
	-- ['usa'] = 'Choose language!',
	-- ['rus'] = 'Выберите язык!',
-- }

local langs = {}
	
do
	local count = 1
	
	for k,v in pairs(LanguagesName) do
		langs[count] = {img = Languages[k], name = v, index = k}
		
		count = count + 1
	end
end

table.sort(langs, function(a,b)
	return (a.index == 'usa')
end)

local currentLang = 0

local y = 100
local cursor = Graphics.sprites.hardcoded['34-0'].img

function onInputUpdate()
	local keys = player.rawKeys
	
	if keys.down == KEYS_PRESSED then
		SFX.play 'devkit/click.ogg'
		currentLang = (currentLang + 1) % #langs
		
		local lang = langs[currentLang + 1]
		SaveData.language = lang.index
	elseif keys.up == KEYS_PRESSED then
		SFX.play 'devkit/click.ogg'
		currentLang = (currentLang - 1)
		
		if currentLang < 0 then
			currentLang = #langs - 1
		end
		
		local lang = langs[currentLang + 1]
		SaveData.language = lang.index
	elseif keys.jump then
		SaveData._chosenLanguage = true
		return Level.load()
	end
	
	player.keys.dropItem = false
end

function onCameraDraw()
	local text = 'Choose language!'
	local lang = SaveData.language

	if lang ~= 'usa' and littleDialogue.translation[lang] and littleDialogue.translation[lang][text] then
		text = littleDialogue.translation[lang][text]
	end
	
	textplus.print{
		text = text,
		
		x = 232,
		y = 32,
		
		font = font,
		xscale = 3,
		yscale = 3,
		
		color = Color.yellow,
	}
	
	local dy = 0
	local dx = 0
	local countW = 256
	
	for i = 0, currentLang do
		if (i % 21) == 0 and i > 20 then
			dx = dx - countW * 3
		end
	end
	
	for key = 1, #langs do
		local lang = langs[key]
		
		if dx > countW * 3 then break end
		
		Graphics.drawBox{
			texture = lang.img,
			
			x = 48 + dx,
			y = y + dy,
			width = 48,
			height = 48,
			
			color = (currentLang ~= (key - 1) and {0.5, 0.5, 0.5, 0.5}) or nil,
		}
		
		local c
		
		if (key - 1) == currentLang then
			c = Color.yellow
			
			Graphics.drawBox{
				texture = cursor,
				
				x = 16 + dx,
				y = y + dy + 8,
				width = 32,
				height = 32,
			}
		end

		textplus.print{
			text = lang.name,
			
			x = 104 + dx,
			y = y + dy,
			
			font = font,
			xscale = 2,
			yscale = 2,		
			
			color = c,
		}
		
		dy = dy + 64
		
		if (key % 7) == 0 then
			dx = dx + countW
			dy = 0
		end
	end
end