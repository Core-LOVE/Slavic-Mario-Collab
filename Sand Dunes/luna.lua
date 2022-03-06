local rng = loadSharedAPI("base/rng");

function onLoop()
	for j,w in pairs(NPC.get(245,player.section)) do
		if w.ai2 == 2 and w.ai1 == 49 then
            w.ai3 = 0
			sdeterm = rng.randomInt(1,2)
			if sdeterm == 1 then
			side = 1
			else side = -1
			end
			w.ai1 = 51
			playSFX(18)
            fier = NPC.spawn(202,w.x+0.5*w.width,w.y,player.section,false,true)
			fier.speedX = rng.randomInt(0,6) * 0.3 * side + 0.2 * side
			fier.speedY = rng.randomInt(-75,-55) * 0.15
        end
		if w.ai2 == 2 and w.ai1 > 50 then
            w.ai3 = w.ai3 + 1
			if w.ai3 == 20 then
			w.ai3 = w.ai3 + 1
			playSFX(18)
			fier = NPC.spawn(202,w.x+0.5*w.width,w.y,player.section,false,true)
			fier.speedX = rng.randomInt(0,6) * -0.3 * side + 0.2 * side
			fier.speedY = rng.randomInt(-75,-55) * 0.15
			end
			if w.ai3 == 40 then
			w.ai3 = w.ai3 + 1
			playSFX(18)
			fier = NPC.spawn(202,w.x+0.5*w.width,w.y,player.section,false,true)
			fier.speedX = rng.randomInt(0,6) * 0.3 * side + 0.2 * side
			fier.speedY = rng.randomInt(-75,-55) * 0.15
			end
        end
    end
end

local pipeAPI = require("tweaks/pipecannon")

-- You can set exit speeds for every warp
pipeAPI.exitspeed = {0,20,0,0}
-- Will ignore speeds set for doors/instant warps
-- Sound effect for firing
pipeAPI.SFX = 22 -- default value (bullet bill sfx), set to 0 for silent
-- Visual effect for firing
pipeAPI.effect = 10 -- set to 0 for none

function onLoadSection1()
	if player.section == 1 then
		triggerEvent("bonus")
	end
end

function onLoadSection2()
	if player.section == 2 then
		triggerEvent("eight mice show")
	end
end

function onTick()
	if player.section == 1 and not player.hasStarman then
		Audio.MusicVolume(15)
	elseif not player.hasStarman then
		Audio.MusicVolume(40)
	else
		Audio.MusicPause() 
	end
	if player.x >= -193248 then
		triggerEvent("king bill 1 hide")
	end
	if player.section == 0 and player.x >= -185184 then
		triggerEvent("king bill 2 hide")
	end
	if (player.x >= -156832) or (player.x >= -157248 and player.y <= -160704) then
		triggerEvent("king bill 3 hide")
	end
	if player.x >= -153024 then
		triggerEvent("king bill 4 hide")
	end
end

function onCameraUpdate()
	if player.x >= -155520 and player.x <= -154848 and player.y <= -160642 and player.section == 2 then
		triggerEvent("sc3")
	end
	if player.x <= -159552 and player.y <= -160642 and player.section == 2 then
		triggerEvent("hammer pos")
	end
	if player.y >= -160320 and player.section == 2 then
		triggerEvent("sc3 pos hide")
	end
end