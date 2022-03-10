local function bossMeet()
	Routine.wait(2)
	
	Text.showMessageBox("<portrait sherif>HEY YOU! In the name of the law I demand you to stop RIGHT where you are!<page>Do you realize, that by clearing <wave 2>Sources</wave> you're making our lifes worse?<page>HA, like you'd listen anyways!<page>Let me showcase you what happens to ANYBODY who clears 'em.")
	
	Routine.waitFrames(2)
	
	Audio.SeizeStream(player.section)
	Audio.MusicOpen("regularBoss.ogg")
	Audio.MusicPlay()
	
	for k,v in NPC.iterate(404) do
		v:kill(9)
		
		local n = NPC.spawn(753, v.x, v.y)
		n.direction = -1
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
	player.direction = 1
	Pauser.disabled = true
	
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
	Level.load 'credits.lvlx'
end

function onEvent(n)
    if n == "meet" then
		Routine.run(bossMeet)
	elseif n == "cutscene" then
		Graphics.activateHud(false)
		
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
