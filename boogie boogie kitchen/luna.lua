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
	end
end

