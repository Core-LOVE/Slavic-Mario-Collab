require 'extraNPCProperties'
local autoscroll = require("autoscroll") 

local camlock = require("camlock")
camlock.addZone(-139200, -140608, 800, 600, 0.075)

local particles = require("particles")

local lights = particles.Emitter(0, 0, "p_lights.ini")
lights:AttachToCamera(camera)

local firep = particles.Emitter(0, 0, "p_fire.ini")
firep:AttachToCamera(camera)

local firewall = Graphics.loadImageResolved 'firewall.png'
local fire = Shader()
fire:compileFromFile(nil, Misc.resolveFile("firewall.frag"))

local function drawFirewall(time, intensity, x)
	local x = x or 0
	
	Graphics.drawBox{
		texture = firewall,
		
		x = camera.x + x,
		y = camera.y,
		
		shader = fire,
		uniforms = {
			time = time,
			intensity = intensity,
		},
		
		sceneCoords = true,
		priority = 2,
	}
end

local function isColliding(a,b)
   if ((b.x >= a.x + a.width) or
	   (b.x + b.width <= a.x) or
	   (b.y >= a.y + a.height) or
	   (b.y + b.height <= a.y)) then
		  return false 
   else return true
	   end
end
	
function onTickEnd()
	if player.section ~= 1 then return end
	
	local zone = {
		x = camera.x,
		y = camera.y,
		width = 145,
		height = 600,
	}
	
	if isColliding(player, zone) then
		player:harm()
	end
end

local img = Graphics.loadImageResolved 'overlay.png'
local s = Shader()
s:compileFromFile(nil, Misc.resolveFile("source.frag"))

function onCameraDraw()
	if player.section == 3 then
		for k,v in ipairs(BGO.get(21)) do
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
		
		return
	end
	
	
    lights:Draw()
	
	if player.section ~= 1 then return end
	
	firep:Draw()
	
	local time = lunatime.tick()
	local intensity = (8 + (math.sin(time / 16) * 4))
	
	drawFirewall(time, intensity)
	drawFirewall(-time, intensity, -32)
end

local function bossMeet()
	local n=  NPC.spawn(404, -158848 + 16, -160480 + 16)
	Routine.wait(3.6)
	
	Text.showMessageBox("<portrait hotbi>Yo dude!<page>You don't seem to be HOT, aren'tcha?<page>HOT BOYS don't steal stuff! Take that tip, dude!<page>You want to stay COLD? Let me teach ya how to be a HOT BOY!")
	
	Routine.waitFrames(2)
	
	Audio.SeizeStream(player.section)
	Audio.MusicOpen("hardBoss.ogg")
	Audio.MusicPlay()
	
	n:kill(9)
	NPC.spawn(753, n.x, n.y)
end

local playerHold = false

local function himLoop1(n)
	while (true) do
		if n.collidesBlockBottom then
			Defines.earthquake = 15
			Graphics.sprites.npc[405].img = Graphics.loadImageResolved 'rebLands.png'
			
			SFX.play 'lands.ogg'
			Routine.yield()
			break
		end
		
		Routine.skip()	
	end
end

local function himLoop2(v)
	while (true) do
	
	v.speedX = -32
	
	for k,p in ipairs(Player.getIntersecting(v.x, v.y, v.x + v.width, v.y + v.height)) do
		playerHold = true
		
		p.x = v.x + 22
		p.y = v.y + 16
		p:mem(0x3A, FIELD_WORD, 999)
		
		Defines.earthquake = 15
		
		v.speedX = 0
		SFX.play 'holds.ogg'
		
		Routine.yield()
		break
	end
	
	Routine.skip()	
	end
end

local function himLoop3(v)
	while (true) do
		v.speedX = 0.5
		Routine.skip()	
	end
end

local function himChange()
	Routine.waitFrames(32)
	
	Graphics.sprites.npc[405].img = Graphics.loadImageResolved 'rebStands.png'
end

local function himLoop4(n)
	while (true) do
		if n.collidesBlockBottom then
			Defines.earthquake = 15
			Graphics.sprites.npc[405].img = Graphics.loadImageResolved 'rebLands.png'
			
			SFX.play 'lands.ogg'
			Routine.run(himChange)
			Routine.yield()
			break
		end
		
		Routine.skip()	
	end
end

local function him()
	Pauser.disabled = true
	Graphics.activateHud(false)
		
	local c = cutscene.new{
		lockInput = true,
		runWhilePaused = true,
		border = true,
		canSkip = false,
	}
	c:run()
		
	player.direction = 1
	
	local section = Section(player.section)
	local bounds = section.boundary
	
	Graphics.sprites.npc[405].img = Graphics.loadImageResolved 'rebJumps.png'
	local n =  NPC.spawn(405, bounds.right - 400, bounds.top)
	n.speedY = 12
	n.speedX = 1
	
	SFX.play 'jumps.ogg'
	
	Routine.run(himLoop1, n)
	
	Routine.wait(1.5)
	
	Graphics.sprites.npc[405].img = Graphics.loadImageResolved 'rebHolds.png'
	Routine.run(himLoop2, n)
	
	Routine.wait(1)
	-- littleDialogue.create{text = "<speakerName ???>Got you."}
	Routine.waitFrames(2)

	Audio.MusicOpen("t.ogg")
	Audio.MusicPlay()
	
	Routine.wait(0.5)
	-- littleDialogue.create{text = "<speakerName ???>What do you think you're doing here, plumber?<page>I saw how you ruin my plans right in my sight, and you think that i'll just pass by?<page>These <wave 1>Sources</wave>...<page>They are not just for gaining resources.<page>They are our hope. A hope for a completely new world.<page>When everything will be ready, everything will change...<page>And you want to destroy it all, don't you?<page>You want to see so badly what happens to VILLAINS?"}
	Routine.waitFrames(2)
	
	playerHold = false

	Routine.wait(0.5)
	
	Graphics.sprites.npc[405].img = Graphics.loadImageResolved 'rebStands.png'
	
	local route = Routine.run(himLoop3, n)
	Routine.waitFrames(32)
	route:abort()
	
	n.speedX = 0
	Routine.waitFrames(24)
	
	SFX.play 'jumps.ogg'
	Graphics.sprites.npc[405].img = Graphics.loadImageResolved 'rebJumps.png'
	
	n.y = n.y - 1
	n.speedY = -8
	n.speedX = 7
	
	Routine.waitFrames(2)
	Routine.run(himLoop4, n)
	
	Routine.wait(1.75)
	Audio.MusicStop()
	SFX.play 'gone.ogg'
	
	for y = 0, n.height * 2, 8 do
		local e = Effect.spawn(755, n.x + math.random(n.width), n.y + y * 0.5)
		e.speedX = math.random(2, 4)
	end
	
	Graphics.sprites.npc[405].img = Graphics.loadImageResolved 'rebStands2.png'
	Routine.wait(1)
	
	-- littleDialogue.create{text = "<portrait rebel>You will feel the <color red>PAIN</color>."}
	Routine.waitFrames(2)
	c:stop(48)
	
	Pauser.disabled = false
	Graphics.activateHud(true)
	NPC.spawn(756, n.x + 32, n.y)
	n:kill(9)
end

function onTick()
	if not playerHold then return end
	
	player.speedY = -0.4
end

function onEvent(n)
	if n == 'wall' then
		autoscroll.scrollRight(1.5)
	elseif n == 'section' then
		Routine.run(bossMeet)
	elseif n == 'appear' then
		Routine.run(him)
	end
end