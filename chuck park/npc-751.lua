--[[

	Written by MrDoubleA
	Please give credit!

	Concept and sprites by NegativeBread

    Part of MrDoubleA's NPC Pack

]]

local npcManager = require("npcManager")
local npcutils = require("npcs/npcutils")

local chucks = require("npcs/ai/chucks")


local battinChuck = {}
local npcID = NPC_ID

local battinChuckSettings = {
	id = npcID,
	
	gfxwidth = 96,
	gfxheight = 64,

	gfxoffsetx = 0,
	gfxoffsety = 2,
	
	width = 32,
	height = 48,
	
	frames = 5,
	framestyle = 1,
	framespeed = 12,
	
	speed = 1,
	score = 0,
	
	npcblock = false,
	npcblocktop = false, --Misnomer, affects whether thrown NPCs bounce off the NPC.
	playerblock = false,
	playerblocktop = false, --Also handles other NPCs walking atop this NPC.

	nohurt = false,
	nogravity = false,
	noblockcollision = false,
	nofireball = false,
	noiceball = false,
	noyoshi = false,
	nowaterphysics = false,
	
	jumphurt = false,
	spinjumpsafe = true,
	harmlessgrab = false,
	harmlessthrown = false,

	luahandlesspeed = true,

	npconhit = 311,


	hitFrames = 4,
	hitFramespeed = 3,

	hitAnimationLength = 48,

	hittableWidth = 16,
	hittableHeight = 64,

	hitSFX = 36,
	hitAnimationCanReverse = true,

	prepareDetectionWidth = 96,
	prepareDetectionHeight = 80,
}

npcManager.setNpcSettings(battinChuckSettings)
npcManager.registerHarmTypes(npcID, 	
	{
		HARM_TYPE_JUMP,
		HARM_TYPE_FROMBELOW,
		HARM_TYPE_NPC,
		HARM_TYPE_HELD,
		HARM_TYPE_TAIL,
		HARM_TYPE_SPINJUMP,
		HARM_TYPE_SWORD,
		HARM_TYPE_LAVA
	}, 
	{
		[HARM_TYPE_JUMP] = 73,
		[HARM_TYPE_FROMBELOW] = 172,
		[HARM_TYPE_NPC] = 172,
		[HARM_TYPE_HELD] = 172,
		[HARM_TYPE_TAIL] = 172,
		[HARM_TYPE_LAVA] = {id=13, xoffset=0.5, xoffsetBack = 0, yoffset=1, yoffsetBack = 1.5}
	}
)


local function hurtFunction(v)
	data.hitTimer = 0
	data.preparing = false
end

local function hurtEndFunction(v)
	
end


function battinChuck.onInitAPI()
	npcManager.registerEvent(npcID, battinChuck, "onTickEndNPC")
	
	chucks.register(npcID, hurtFunction, hurtEndFunction)
end



local alwaysHittableIDs = table.map{40,85,87,246,319,390,615,617}

local function deflect(batter,projectile)
	projectile.speedX = math.clamp(math.abs(projectile.speedX)*1.5,1.5,16)*batter.direction
	if not NPC.config[projectile.id].nogravity then
		projectile.speedY = -1.5
	else
		projectile.speedY = 0
	end

	projectile:mem(0x12E,FIELD_WORD,0)
	projectile:mem(0x130,FIELD_WORD,0)
end

local function transformAndDeflect(batter,projectile,transformID)
	projectile:transform(transformID)
	deflect(batter,projectile)

	projectile:mem(0x12E,FIELD_WORD,0)
	projectile:mem(0x130,FIELD_WORD,0)
end


local npcHandlers = {}

local function defaultNPCHandler(batter,projectile)
	if projectile:mem(0x136,FIELD_BOOL) or alwaysHittableIDs[projectile.id] or (batter:mem(0x12C,FIELD_WORD) > 0 and NPC.HITTABLE_MAP[projectile.id]) then
		deflect(batter,projectile)

		if not alwaysHittableIDs[projectile.id] then
			projectile:mem(0x136,FIELD_BOOL,true)
		end

		if NPC.MULTIHIT_MAP[projectile.id] then
			projectile:harm(HARM_TYPE_NPC,0.5)
		end

		return true
	end

	return false
end

-- Fireball
npcHandlers[13] = (function(batter,projectile)
	transformAndDeflect(batter,projectile,390)
	projectile.speedX = math.abs(projectile.speedX)*NPC.config[projectile.id].speed*batter.direction

	return true
end)

-- Iceball
npcHandlers[265] = npcHandlers[13]

-- Hammer
npcHandlers[171] = (function(batter,projectile)
	transformAndDeflect(batter,projectile,617)

	return true
end)

-- Peach bomb
npcHandlers[291] = (function(batter,projectile)
	transformAndDeflect(batter,projectile,134)
	projectile.speedX = batter.direction*8

	return true
end)

-- Toad boomerang
npcHandlers[292] = (function(batter,projectile)
	transformAndDeflect(batter,projectile,615)
	projectile.y = batter.y + batter.height*0.5 - projectile.height*0.5
	projectile.speedX = batter.direction*8
	projectile.data._basegame.ownerBro = batter

	return true
end)

-- Link's beam
npcHandlers[266] = (function(batter,projectile)
	transformAndDeflect(batter,projectile,133)
	projectile.speedX = batter.direction*8
	projectile.speedY = 0
	projectile:mem(0x136,FIELD_BOOL,false)

	return true
end)

-- Birdo egg
npcHandlers[40] = (function(batter,projectile)
	deflect(batter,projectile)
	projectile:mem(0x136,FIELD_BOOL,true)
	projectile.speedX = projectile.speedX*1.25
	projectile.speedY = -1.5

	return true
end)


local function handleAnimation(v,data,config)
	local idleFrames = (config.frames-config.hitFrames)
	local frame = 0

	if data.hitTimer > 0 then
		if not data.hitAnimationReversed then
			frame = math.min(config.hitFrames-1,math.floor(data.hitTimer/config.hitFramespeed))
		else
			frame = math.max(0,config.hitFrames-math.floor(data.hitTimer/config.hitFramespeed)-1)
		end
		frame = frame + idleFrames

		data.animationTimer = 0
	elseif data.preparing then
		frame = idleFrames
	else
		frame = math.floor(data.animationTimer/config.framespeed)%idleFrames
		data.animationTimer = data.animationTimer + 1
	end

	v.animationFrame = npcutils.getFrameByFramestyle(v,{frame = frame})
end


local colBox = Colliders.Box(0,0,0,0)

function battinChuck.onTickEndNPC(v)
	if Defines.levelFreeze then return end
	
	local data = v.data
	
	if v.despawnTimer <= 0 then
		data.initialized = false
		return
	end


	local config = NPC.config[v.id]

	if not data.initialized then
		data.initialized = true

		data.hitTimer = 0
		data.hitAnimationReversed = false
		data.preparing = false

		data.animationTimer = 0

		data._basegame.exists = true
	end


	if data._basegame.hurt then
		return
	end


	if v:mem(0x136, FIELD_BOOL)        --Thrown
	or v:mem(0x138, FIELD_WORD) > 0    --Contained within
	then
		handleAnimation(v,data,config)
		return
	end


	if v.collidesBlockBottom then
		v.speedX = 0
	end


	if data.hitTimer > 0 then
		data.hitTimer = data.hitTimer + 1

		if data.hitTimer >= config.hitAnimationLength then
			data.hitTimer = 0
		end
	end

	if data.hitTimer == 0 then
		data.preparing = false

		colBox.width = config.prepareDetectionWidth
		colBox.height = config.prepareDetectionHeight
	
		colBox.y = v.y + v.height - colBox.height
	
		if v.direction == DIR_LEFT then
			colBox.x = v.x - colBox.width
		else
			colBox.x = v.x + v.width
		end
	
	
		local npcs = Colliders.getColliding{a = colBox,btype = Colliders.NPC}

		for _,npc in ipairs(npcs) do
			if npc ~= v and (npc:mem(0x136,FIELD_BOOL) or npc:mem(0x12C,FIELD_WORD) > 0 or alwaysHittableIDs[npc.id] or (v:mem(0x12C,FIELD_WORD) > 0 and NPC.HITTABLE_MAP[npc.id])) then
				data.preparing = true
				break
			end
		end
	end
	

	colBox.width = config.hittableWidth
	colBox.height = config.hittableHeight

	colBox.y = v.y + v.height - colBox.height

	if v.direction == DIR_LEFT then
		colBox.x = v.x - colBox.width
	else
		colBox.x = v.x + v.width
	end


	local npcs = Colliders.getColliding{a = colBox,btype = Colliders.NPC}

	for _,npc in ipairs(npcs) do
		if npc ~= v then
			local handler = npcHandlers[npc.id] or defaultNPCHandler

			local gotHit = handler(v,npc)

			if gotHit then
				local e = Effect.spawn(75,npc.x + npc.width*0.5 + npc.width*0.5*math.sign(npc.direction),v.y + v.height*0.5)

				e.x = e.x - e.width *0.5
				e.y = e.y - e.height*0.5

				SFX.play(config.hitSFX)

				data.hitAnimationReversed = (data.hitTimer > 0 and not data.hitAnimationReversed and config.hitAnimationCanReverse)
				data.hitTimer = 1
			end
		end
	end

	
	handleAnimation(v,data,config)
end

return battinChuck