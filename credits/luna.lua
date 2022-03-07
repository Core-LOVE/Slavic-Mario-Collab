Pauser.disabled = true
Graphics.activateHud(false)

local textplus = require 'textplus'
local font =  textplus.loadFont("devkit/font.ini")

local credits = [[

	      (Demo 1.0)
	
	
	
	
	
<size 2><color yellow>Host:</color></size>
Core






<size 2><color yellow>Testers:</color></size>
Core
Lookich






<size 2><color yellow>Participants:</color></size>
Core
Lookich
Greenlight
h2643
Alex1479
SonOfAHorde
Retro_games428
UndeFin
Doki
1230m 1
SkullGamer205






<size 2><color yellow>Credits (!!!):</color></size>
Redigit
SMBX2 Devs (This amazing engine 
and help)
Deniz Akbulut (Music)

SEGA (Music)
Toby Fox (Music)
Mista Jub (Music)
Nintendo (Music, SFX, GFX)
OpenGameArt (SFX)
Sempai-MrDoubleA (Scripts, NPCs, 
Help)
Enjl (Scripts)
Zephyr (GFX)
Shikaternia (GFX)
aamatniekss (GFX)
Valtteri (GFX)
Witchking666 (GFX)
The Trasher
Super Mario Flashback (Music)
and etc...






<size 2><color yellow>Special Thanks:</color></size>
<size 0.5>(Most of them didn't contribute to this 
project, but I just feel thankful to 
them and stuff -w-)</size>

Novarender
Hoeloe
litchh
mr.Braineat
P-Tux7
FireSeraphim
KiwisOn
Sempai-MrDoubleA (AGAIN :3)
4matsy
Eulous
SetaYoshi
FyreNova
BabyPinkSnail
LGL
YoshiSuperstar
Stargate Community
Rednaxela
WerewolfGD
GD Community
Slash-18
Waddle
DuckJohnn
Idunn
Wohlstand
Dawn
NeriAkami
Rotten Strawberry
Andontus
Russian UT/DT Chat
MegaloInTheHorrorBox
Диванный Игродел
And to you!!!
]]

local imgs = {}

local function newImage(name)
	local v = {}
	
	if not Misc.resolveFile('img' .. name .. '.png') then return end
	
	v.texture = Graphics.loadImageResolved('img' .. name .. '.png')
	v.width = 850
	v.height = 650
	v.rot = 0
	v.alpha = 0
	v.timer = 0
	
	imgs[#imgs + 1] = v
	return v
end

local function music()
	SFX.open 'credits.ogg'
	Routine.wait(3.6)
	
	local img = newImage(1)
	img.next = 2

	SFX.play 'credits.ogg'
end

function onStart()
	player.forcedState = 8
	
	if player.section >= 1 then return end
	Routine.run(music)
end

local x = 192
local y = 800
local logo = Graphics.loadImageResolved 'devkit/logo.png'

local thing = Graphics.loadImageResolved 'thing.png'
local form = -1

local function creating()
	for k,reb in NPC.iterate(404) do
		local e = Effect.spawn(12, reb.x - 16, reb.y + 2)
		e.speedX = math.random(-9, 9)
		e.speedY = math.random(-9, 9)	
		
		local e = Effect.spawn(751, reb.x - 16, reb.y + 2)
		e.speedX = math.random(-9, 9)
		e.speedY = math.random(-9, 9)	
		
		local e = Effect.spawn(752, reb.x - 16, reb.y + 2)
		e.speedX = math.random(-12, 12)
		e.speedY = math.random(-12, 12)	
	end
	
	Defines.earthquake = 8
end

local blackScreen = false

local function cutscene()
	Routine.waitFrames(4)
	
	if player.section ~= 1 then
		Routine.wait(48)
		
		player.section = 1
	end
	
	for k,reb in NPC.iterate(404) do
		player.x = reb.x
		player.y = reb.y
	end
	
	Routine.wait(4)
	
	Graphics.sprites.npc[404].img = Graphics.loadImageResolved 'reb1.png'
	
	SFX.play 'grab.ogg'
	Defines.earthquake = 15
	
	local img = Graphics.sprites.npc[404].img
	local oldWidth = NPC.config[404].gfxwidth
	
	NPC.config[404].gfxwidth = img.width
	
	for k,reb in NPC.iterate(404) do
		reb.x = reb.x - (img.width - oldWidth) / 2
	end
	
	Routine.wait(2)
	
	local sfx = SFX.play('turning.ogg', 1, 0)
	form = 0
	Routine.loop(320, creating)
	
	form = -1
	sfx:stop()
	blackScreen = true
	
	Audio.SeizeStream(player.section)
	Audio.MusicStop()
	
	Routine.wait(2)
	Level.exit()
end

Routine.run(cutscene)

function onTickEnd()
	if player.section >= 1 then return end
	
	y = y - 1
end

local capture = Graphics.CaptureBuffer(800, 600)

local wave = Shader()
wave:compileFromFile(nil, Misc.resolveFile("waven.frag"))

local function cutsceneDraw()
	if blackScreen then
		Graphics.drawScreen{
			color = Color.black,
		}
	end
	
	if form >= 0 then
		for k,reb in NPC.iterate(404) do
			Graphics.drawBox{
				texture = thing,
				
				x = reb.x - 16,
				y = reb.y + 2,
				width = form,
				height = form,
				
				centred = true,
				sceneCoords = true,
			}
		end
		
		capture:captureAt(-4)
		
		Graphics.drawBox{
			texture = capture,
			
			x = 0,
			y = 0,
			
			shader = wave,
			uniforms = {
				time = form,
				intensity = form / 16,
			},
			
			color = Color.white .. 0.5,
		}
		
		form = form + 1.5
	end
end

function onCameraDraw()
	if player.section >= 1 then 
		cutsceneDraw()
		return 
	end
	
	for k,v in ipairs(imgs) do
		v.timer = v.timer + 1
		
		if v.timer > 640 then
			if v.alpha > -0.5 then
				v.alpha = v.alpha - 0.01
			end
			
			if v.alpha < 0 then
				local next = v.next
				
				imgs[k] = nil
				
				if next then
					local i = newImage(next)
					
					if i then
						i.next = next + 1
					end
				end
			end
		else
			if v.alpha < 0.25 then
				v.alpha = v.alpha + 0.001
			end
			
			v.width = v.width + 0.25
			v.height = v.height + 0.25
			v.rot = v.rot + 0.01	
		end
		
		if v then
			Graphics.drawBox{
				texture = v.texture,
				
				x = 400,
				y = 300,
				width = v.width,
				height = v.height,
				
				centred = true,
				rotation = v.rot,
				color = Color.white .. v.alpha,
			}
		end
	end
	
	Graphics.drawBox{
		texture = logo,
		
		x = x,
		y = y - logo.height,
	}
	
	textplus.print{
		text = credits,
		
		x = x,
		y = y,
		
		font = font,
		xscale = 2,
		yscale = 2,
	}
end