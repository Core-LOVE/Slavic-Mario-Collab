local timer = -99
local invert = 1

function onTick()
    if (player.keys.jump == KEYS_PRESSED or player.keys.altJump == KEYS_PRESSED) and player:isOnGround() and timer <= 0 and player.forcedState == 0 then
        timer = 64
    end

    if timer > 0 then
        local up = Layer.get('Class A')
        local down = Layer.get('Class B')
		local left = Layer.get('Class C')
        local right = Layer.get('Class D')

        if player.forcedState == 0 then
            up.speedY = -2 * invert
            down.speedY = 2 * invert
			left.speedX = 2 * invert
            right.speedX = -2 * invert

            timer = timer - 0.5
        else
            up.speedY = 0
            down.speedY = 0
			left.speedX = 0
            right.speedX = 0
        end
    else
        if timer ~= -99 then
            local up = Layer.get('Class A')
			local down = Layer.get('Class B')
			local left = Layer.get('Class C')
			local right = Layer.get('Class D')

            up.speedY = 0
            down.speedY = 0
			left.speedX = 0
            right.speedX = 0
            invert = -invert
            timer = -99
        end
    end
end