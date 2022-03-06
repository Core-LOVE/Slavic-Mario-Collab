-- local warpTransition = require("warpTransition")
a = 0

function onTick()
    local currentWarp = player:mem(0x15E,FIELD_WORD)
    if currentWarp < 3 then -- If the player is using a certain warp
        warpTransition.sameSectionTransition = warpTransition.TRANSITION_PAN -- Set the same-section transition to 'none'
    else
        warpTransition.sameSectionTransition = warpTransition.TRANSITION_IRIS -- Set the same-section transition to 'pan'
    end
    if currentWarp == 2 then
        triggerEvent("SectionShift2")
    end
end