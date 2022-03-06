Graphics.activateHud(false);

local function dialog()
	Routine.wait(1)
	
	Text.showMessageBox("<portrait boogie>Bun!! Guess what?")
	
	Routine.waitFrames(2)
	Text.showMessageBox("<portrait sherif>What?")
	Routine.waitFrames(2)
	
	Text.showMessageBox("<portrait boogie>Players can now kick our asses!")
	
	Routine.waitFrames(2)
	Text.showMessageBox("<portrait sherif>WHAT?!")
	
	Routine.waitFrames(2)
	Text.showMessageBox("<portrait boogie>Slavic Mario Collab is out-")
	Routine.waitFrames(2)
	
	Text.showMessageBox("<portrait sherif><tremble 2>WHY ARE YOU BEING HAPPY ABOUT THIS?!</tremble>")
	Routine.waitFrames(2)
	
	Text.showMessageBox("<portrait boogie>Sounds fun!")
	
	Routine.waitFrames(2)
	Text.showMessageBox("<portrait sherif><tremble 2>THAT'S NOT FUN AT ALL, LIKE- WHAT?!</tremble><page>That's it, Boogie Boogie...")
	Routine.wait(0.5)
	
	SFX.play 'bossGunPrepare.ogg'
	Defines.earthquake=10
	
	Graphics.sprites.npc[404].img = Graphics.loadImageResolved 'boog.png'
	Graphics.sprites.npc[489].img = Graphics.loadImageResolved 'bun.png'
	
	Routine.wait(0.5)
	Text.showMessageBox([[<portrait sherif>I'm TIRED of your "Jokes"!]])
	Routine.waitFrames(2)
	Text.showMessageBox("<portrait boogie>Uh-oh")
end

function onStart()
	player.forcedState = 8
	
	Routine.run(dialog)
end