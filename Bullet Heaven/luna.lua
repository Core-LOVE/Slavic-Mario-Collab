local tileRandomizer = require("tileRandomizer")
tileRandomizer.register(19, {3, 15, 16, 17})

local autoscroll = require("autoscroll")

local spawnzones = require("local_spawnzones")

function onEvent(eventName)
	if player.section == 0 then
		if eventName == "cutscene over" then
                    autoscroll.scrollRight(1)
		end
               	if eventName == "autoscroll" then
                    autoscroll.scrollRight(1.49)
		end
               	if eventName == "second cutscene start" then
                    autoscroll.scrollRight(0)
		end
	end
end

function onOptimize()
	for k,v in ipairs(Section.get()) do
		if v.backgroundID == 11 then
			local layer = v.background:get("clouds")
			layer.hidden = not layer.hidden
		end
	end
end
