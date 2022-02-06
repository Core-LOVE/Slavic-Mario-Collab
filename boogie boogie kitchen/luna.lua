local autoscroll = require("autoscroll") 

local s = 1
local hurt = {}

function onTick()
	for k,v in ipairs(hurt) do
		if v.y < -181920 - 8 then
			v.speedY = 0
			hurt[k] = nil
		else
			v:translate(0, -s)
			v.speedY = -s
		end
	end
end

local function bossMeet()
	Routine.wait(2)
	
	Text.showMessageBox("<portrait boogie>Hey-hey-hey!!<page>Plumber, do you want anything?<page>You probably want to get that delicious <wave 1>Source</wave>, isn't it?<page>Well, you won't get it!!<delay 14>This thingy is very important for us!!<page>You wanna fight? Well, i'll fight too!!")
	
	Routine.waitFrames(2)
	
	Audio.SeizeStream(player.section)
	Audio.MusicOpen("regularBoss.ogg")
	Audio.MusicPlay()
		
	for k,v in NPC.iterate(404) do
		v:kill(9)
		
		NPC.spawn(753, v.x, v.y)
	end
end

local screenAlpha = 0
local dark = 0

local function playerWalk()
	player.speedX = 1
	screenAlpha = screenAlpha + 0.005
end

local function darkness()
	dark = dark + 0.01
end

local function ct()
	Routine.wait(1.5)
	player.speedX = 1
	
	Routine.wait(1.5)
	player.speedX = 1
	
	Routine.wait(1.5)
	Routine.loop(192, playerWalk)
	
	Routine.wait(3)
	Audio.MusicFadeOut(player.section, 3500)
	Routine.loop(192, darkness)
	
	Routine.wait(2)
	Level.exit(0)
end

function onEvent(n)
	if n == "switch" then
		Defines.earthquake = 10
		
		autoscroll.scrollUp(s)
		
		for k,b in Block.iterate(672) do
			if b.layerName == "hurt" then
				hurt[#hurt + 1] = b
			end
		end
	elseif n == "section" then
		Routine.run(bossMeet)
	elseif n == "cutscene" then
		local c = cutscene.new{
			lockInput = true,
			runWhilePaused = true,
			border = true,
			canSkip = false,
		}
		
		c:run()
		Routine.run(ct)
	end
end

local s = Shader()
s:compileFromFile(nil, Misc.resolveFile("source.frag"))

local img = Graphics.loadImageResolved 'overlay.png'

function onCameraDraw()
	if player.section ~= 3 then return end
	
	for k,v in ipairs(BGO.get(1)) do
		Graphics.drawBox{
			texture = img,
			
			x = v.x,
			y = v.y,
			
			shader = s,
			uniforms = {
				time = lunatime.tick() * 0.025,
				intensity = 1,
			},
			
			sceneCoords = true,
		}
		
		Graphics.drawBox{
			texture = img,
			
			x = v.x,
			y = v.y,
			
			shader = s,
			uniforms = {
				time = lunatime.tick() * 0.01,
				intensity = -1,
			},
			
			sceneCoords = true,
		}
	end
	
	if screenAlpha <= 0 then return end
	
	Graphics.drawScreen{
		color = Color.fromHexRGB(0x5DD3D3) .. screenAlpha,
	}
	
	Graphics.drawScreen{
		color = Color.black .. dark,
		priority = 6,
	}
end
