require 'extraNPCProperties'
local autoscroll = require("autoscroll") 

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

function onEvent(n)
	if n == 'wall' then
		autoscroll.scrollRight(1.5)
	elseif n == 'section' then
		Routine.run(bossMeet)
	end
end