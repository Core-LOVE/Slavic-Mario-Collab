local bossAPI = require 'devkit/bosser'

local id = NPC_ID
local boss = {}

boss.config = {
	id = id,
	frames =1,
	jumphurt = false,
	nohurt = false,
}

boss.phases = {}

boss.phases[1] = {(function(v, t)
	if t == 32 then
		v.speedY = -9
	end
end), maxTimer = 180}

boss = bossAPI.new(boss)
return boss