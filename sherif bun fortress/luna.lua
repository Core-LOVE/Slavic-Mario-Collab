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

function onEvent(n)
    if n == "meet" then
		Routine.run(bossMeet)
	end
end

