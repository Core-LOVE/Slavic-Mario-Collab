local npcManager = require("npcManager")

local npc = {}
local npcID = NPC_ID

local npcSettings = {
	id = npcID,
	gfxheight = 32,
	gfxwidth = 128,
	width = 128,
	height = 32,
	gfxoffsetx = 0,
	gfxoffsety = 0,
	frames = 1,
	framestyle = 1,
	framespeed = 8,
	speed = 1,
	npcblock = false,
	npcblocktop = true,
	playerblock = false,
	playerblocktop = true,

	nohurt=true,
	nogravity = true,
	noblockcollision = true,
	nofireball = true,	
    noiceball = true,
	noyoshi= true,
	nowaterphysics = false,
	jumphurt = true, 
	
	lightcolor = Color.purple,
	lightradius = 96,
	lightbrightness=1, 	
}

npcManager.setNpcSettings(npcSettings)
npcManager.registerDefines(npcID, {NPC.HITTABLE})

function npc.onInitAPI()
	npcManager.registerEvent(npcID, npc, "onTickEndNPC")
end

function npc.onTickEndNPC(v)
	if Defines.levelFreeze then return end
	
	local data = v.data
	
	if v:mem(0x12A, FIELD_WORD) <= 0 then
		data.initialized = false
		return
	end

	if not data.initialized then
		data.initialized = true
	end
	for _, p in ipairs(Player.get()) do
		if p.standingNPC and p.standingNPC.idx == v.idx and p.deathTimer <= 0 and p.forcedState == 0 then
			v.speedY=v.speedY+0.05*v.direction
		else
		    v.speedY=0
		end
	end
    -- if v.speedY > 2 then
        -- v.speedY=2
    -- elseif v.speedY < -2 then
        -- v.speedY=-2
    -- end
	
	v.speedX = v.speedY
end

--Gotta return the library table!
return npc