local function cs(c)
	Pauser.disabled = true
	local handycam = require 'handycam'

	local cam = handycam[1]

	local npc
	local him
	
	for k,v in NPC.iterate(403) do
		npc = v
		break
	end
	
	for k,v in NPC.iterate(404) do
		him = v
		break
	end
	
	cam:transition{
		time = 2,
		zoom = 1.25,
		
		targets = {npc},
	}
	
	Audio.SeizeStream(player.section)
	Audio.MusicStop()

	Routine.wait(2)
	littleDialogue.create{text = "<speakerName ???>So... Here's the deal, Bowser.<page>You'll help me creating <wave 2>Sources</wave> around the Mushroom Kingdom.<page>They are used to extract needed resources, and I can share those resources with you afterwards.<page>A deal?"}
	
	Routine.waitFrames(2)
	
	cam:transition{
		time = 1,
		
		targets = {vector(npc.x, npc.y)},
	}
	
	Routine.wait(1)
	Defines.earthquake=8
	
	npc.direction = -1
	Routine.wait(0.5)
	littleDialogue.create{text = "<speakerName ???>H-huh?!<page>Mario??!!"}
	Routine.wait(0.25)
	SFX.play 'slidewhist.wav'
	
	npc.speedY = -8
	Routine.wait(0.75)
	littleDialogue.create{text = "<speakerName ???>Bowser?! H-hey! Don't leave me here!"}
	Routine.waitFrames(2)
	npc:kill(9)
	
	him.direction = 1
	
	Routine.wait(1.5)
	
	him.direction = -1
	
	Routine.wait(1.5)
	littleDialogue.create{text = "<speakerName ???>Ghahaha...<page>A pawn of Mushroom Kingdom I see.<page>Once your Kingdom took everything away from me and my people, now it's time for Mushroom Kingdom to repent.<page>And you shall not stand in my way, Mario.<page>See you soon."}
	
	Routine.wait(0.5)
	
	him.direction = 1
	
	Routine.wait(0.5)
	him.direction = -1
	
	Routine.wait(1)
	Defines.earthquake = 8

	SFX.play 'gone.ogg'
	
	for y = 0, him.height do
		local e = Effect.spawn(265, him.x + math.random(him.width), him.y + y)
		e.speedX = math.random(0, 2)
		e.speedY = math.random(-1, 1)	
	end
	him:kill(9)
	
	Routine.wait(2)
	cam:transition{
		time = 1,
		zoom = 1,
		
		targets = {player},
	}
	c:stop(48)
	Pauser.disabled = false
	Graphics.activateHud(true)
end

function onEvent(name)
	if name == "cutscene" then
		Graphics.activateHud(false)
		
		local c = cutscene.new{
			lockInput = true,
			runWhilePaused = true,
			border = true,	
		}
		
		player.speedX = 0
		c:run()
		
		Routine.run(cs, c)
	end
end