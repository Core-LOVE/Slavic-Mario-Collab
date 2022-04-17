local smwfuzzy = {}

local npcManager = require("npcManager")
-- local pnpc = require("pnpc")

local npcID = NPC_ID

npcManager.registerDefines(npcID, {NPC.UNHITTABLE})

-- settings
local config = {
	id = npcID, 
	gfxoffsetx = 0, 
	gfxoffsety = 0, 
	width = 96, 
    height = 32,
    gfxwidth = 96,
    gfxheight = 32,
    frames = 1,
    framestyle = 1,
    playerblocktop = true,
    npcblocktop = true,
    npcblock = true,
    nofireball = true,
    noiceball = true,
    nohurt = true,
    nogravity = true,
    noyoshi = true,
    noblockcollision = true,
	
	lightcolor = Color.lightblue,
	lightradius = 128,
	lightbrightness=1, 	
}

npcManager.setNpcSettings(config)

function smwfuzzy.onInitAPI()
    npcManager.registerEvent(npcID, smwfuzzy, "onTickEndNPC")
end

function smwfuzzy.onTickEndNPC(v)
    if Defines.levelFreeze then return end
    if v.isHidden or v:mem(0x12A, FIELD_WORD) <= 0 or v:mem(0x138, FIELD_WORD) > 0 or v:mem(0x12C, FIELD_WORD) > 0 then
        v.data.active = nil
        v.data.lastX = v.y
		return
    end

    if v.data.startX == nil then
        v.data.startX = v:mem(0xB0, FIELD_DFLOAT)
        v.data.startDirection = v.direction
        if v.data.startDirection == 0 then
            v.data.startDirection = rng.iRandomEntry{-1, 1}
            v.direction = v.data.startDirection
        end
    end

    for k,p in ipairs(Player.get()) do
        if p.standingNPC and p.standingNPC == v then
            v.data.active = k
            v.direction = v.data.startDirection
			
			if p.forcedState == 0 then
				v.speedY = v.data.startDirection * 2
			else
				v.speedY = 0
			end
        elseif v.data.active == k then
            v.data.active = false
            v.direction = -v.data.startDirection
			
			if p.forcedState == 0 then
				v.speedY = -v.data.startDirection * 2
			end
        end
    end

    if v.data.active == nil then return end

    if v.direction == -v.data.startDirection and (
        (v.data.startDirection == 1 and v.data.lastX > v.data.startX and v.y <= v.data.startX) or
        (v.data.startDirection == -1 and v.data.lastX < v.data.startX and v.y >= v.data.startX)) then
            v.data.active = nil
            v.direction = v.data.startDirection
            v.speedY = 0
            v.y = v.data.startX
    end
    
    v.data.lastX = v.y
end

return smwfuzzy