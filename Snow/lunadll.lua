function onStart()
	player:mem(0xF0, FIELD_WORD, 4)
	triggerEvent("gerak naik")
end

function onEvent(calledEvent)
	if calledEvent == "daun" then 
		player.powerup = PLAYER_LEAF
	end
end
