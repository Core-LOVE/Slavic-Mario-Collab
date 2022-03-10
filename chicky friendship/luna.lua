warpTransition.sameSectionTransition = warpTransition.TRANSITION_NONE
local rooms = require 'rooms'

function onCameraUpdate()
	local roomstable = table.map{2}
	local roomstable2 = table.map{3}
	if roomstable2[rooms.currentRoomIndex] then
		triggerEvent("3room")
	elseif roomstable[rooms.currentRoomIndex] and player.x >= -193216 then
		triggerEvent("warp3room")
	else
		triggerEvent("1room")
	end
end