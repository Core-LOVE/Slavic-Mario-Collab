--[[

	Written by MrDoubleA
	Please give credit!

    Part of MrDoubleA's NPC Pack

]]

local npcManager = require("npcManager")
local npcutils = require("npcs/npcutils")

local playerManager = require("playerManager")

local cannonPipe = {}


cannonPipe.sharedSettings = {
	frames = 3,
	framestyle = 0,
	framespeed = 8,
	
	speed = 1,
	
	npcblock = true,
	npcblocktop = false, --Misnomer, affects whether thrown NPCs bounce off the NPC.
	playerblock = true,
	playerblocktop = true, --Also handles other NPCs walking atop this NPC.

	nohurt = true,
	nogravity = true,
	noblockcollision = true,
	nofireball = true,
	noiceball = true,
	noyoshi = true,
	nowaterphysics = true,
	
	jumphurt = false,
	spinjumpsafe = false,
	harmlessgrab = true,
	harmlessthrown = true,

	staticdirection = true,


	rotationStartDistance = 96,

	shootAnimHeightChange = 8,
	shootAnimHeight = 32,
	shootAnimWidth = 12,
	shootAnimOffset = 52,

	aimDuration = 48,
	preShootDuration = 32,
	postShootDuration = 64,
	returnDuration = 32,

	enterVerticalWidth = 32,

	trailSmokeID = 250,
	trailSmokeCount = 8,
	trailSmokeDelay = 5,

	launchSmokeID = 249,
}


cannonPipe.idList = {}
cannonPipe.idMap  = {}


function cannonPipe.register(npcID)
	npcManager.registerEvent(npcID, cannonPipe, "onTickEndNPC")
	npcManager.registerEvent(npcID, cannonPipe, "onDrawNPC")

    table.insert(cannonPipe.idList,npcID)
    cannonPipe.idMap[npcID] = true
end


local SHELL_HORIZONTAL_SPEED = 0x00B2C860

local OWED_MOUNT_ADDR = mem(0x00B25180,FIELD_DWORD)
local OWED_MOUNT_COLOR_ADDR = mem(0x00B2519C,FIELD_DWORD)


local BASE_STEP_SIZE = 6

local pipeBaseRotations = {
	[false] = {[DIR_LEFT] = 0,[DIR_RIGHT] = 180},
	[true] = {[DIR_LEFT] = 270,[DIR_RIGHT] = 90},
}


local holdOverHeadCharacters = table.map{CHARACTER_PEACH,CHARACTER_TOAD}


local STATE_NEUTRAL = 0
local STATE_ENTERED = 1
local STATE_AIMING  = 2
local STATE_AIMED   = 3
local STATE_SHOOT   = 4
local STATE_RETURN  = 5

local playerInStates = table.map{STATE_ENTERED,STATE_AIMING,STATE_AIMED}



local playerData = {}
function cannonPipe.getPlayerData(p)
	local pData = playerData[p.idx]

	if pData == nil then
		pData = {}

		-- Initialise player data
		pData.usingPipe = nil

		pData.launcherNPCID = 0
		pData.trailSmokeTimer = 0

		playerData[p.idx] = pData
	end

	return pData
end


local function getPipeInfo(v,data,config)
	local settings = v.data._settings

	local info = {}

	info.baseRotation = pipeBaseRotations[config.horizontal][v.direction]
	info.totalRotation = info.baseRotation + data.rotationOffset

	if config.horizontal then
		info.totalLength = config.width*settings.length + data.lengthOffset

		info.baseX = v.x + v.width*0.5*(1 - v.direction)
		info.baseY = v.y + v.height*0.5
	else
		info.totalLength = config.height*settings.length + data.lengthOffset

		info.baseX = v.x + v.width*0.5
		info.baseY = v.y + v.height*0.5*(1 - v.direction)
	end

	info.totalLength = info.totalLength - data.shootAnimValue*config.shootAnimHeightChange

	info.baseLength = info.totalLength - config.gfxheight

	info.postRotationDistance = math.min(config.rotationStartDistance,info.baseLength)
	info.preRotationDistance = info.baseLength - info.postRotationDistance

	-- TODO: Find better way of finding this? good enough though.
	info.topPosition = vector(info.baseX,info.baseY) + vector(0,-info.preRotationDistance):rotate(info.baseRotation) + vector(0,-config.gfxheight):rotate(info.totalRotation)

	local totalLength = info.postRotationDistance
	local distance = 0
	
	while (true) do
		local height = math.min(BASE_STEP_SIZE,totalLength - distance)

		if height <= 0 then
			break
		end

		local rotation = math.lerp(info.baseRotation,info.totalRotation,distance/info.postRotationDistance)

		info.topPosition = info.topPosition + vector(0,-height):rotate(rotation)
		distance = distance + height
	end


	-- Find place for the player to sit
	local p = data.enteringPlayer
	
	if p ~= nil and p.isValid then
		--[[
                    o
			\\     \|/    //
			 \\_____|____//

			yarrr har har, it is me, the pirate of code that's not great but not terrible
			it be a bit of a mess and a wee bit janky, but it shall do the job for me time
		]]

		local r = math.rad(info.totalRotation) % (math.pi*2)
		local cos = math.cos(r)
		local sin = math.sin(r)

		info.playerPosition = info.topPosition + 0 -- +0 to get a clone of the vector
		info.playerPosition.x = info.playerPosition.x - p.width*0.5 + math.lerp(0,-p.width*0.5,sin)
		info.playerPosition.y = info.playerPosition.y + math.max(config.width,config.height)*0.5 - p.height - 2*math.abs(sin)

		if r < math.pi*0.5 or r > math.pi*1.5 then
			info.playerPosition.y = info.playerPosition.y + p.height*cos*0.5
		else
			info.playerPosition.y = info.playerPosition.y + p.height*cos
		end

		--Text.print(info.totalRotation%360,32,32)
		--Text.print(cos - 1,32,64)
		--Text.print(sin - 1,32,96)
	end


	return info
end


local function setPipeHitboxSize(v,data,config,length,changeSpawn)
	if config.horizontal then
		if v.direction == DIR_LEFT then
			if changeSpawn then
				v.spawnX = v.spawnX + v.spawnWidth - length
			end

			v.x = v.x + v.width - length
		end

		if changeSpawn then
			v.spawnWidth = length
		end
		v.width = length
	else
		-- Move any players standing on top
		for _,p in ipairs(Player.get()) do
			if p.standingNPC == v and p.forcedState == FORCEDSTATE_NONE and p.deathTimer == 0 and not p:mem(0x13C,FIELD_BOOL) then
				p.y = p.y + v.height - length
			end
		end

		if v.direction == DIR_LEFT then
			if changeSpawn then
				v.spawnY = v.spawnY + v.spawnHeight - length
			end
			v.y = v.y + v.height - length
		end

		if changeSpawn then
			v.spawnHeight = length
		end
		v.height = length
	end
end


local function initialisePreSpawn(v,data)
	local config = NPC.config[v.id]
	local settings = v.data._settings

	local length

	if config.horizontal then
		length = config.width*settings.length
	else
		length = config.height*settings.length
	end

	setPipeHitboxSize(v,data,config,length,true)

	-- Make sure it's in the section
	if v.section == 0 then
		v.section = Section.getIdxFromCoords(v)
	end

	data.initializedPreSpawn = true
end


local function playerCanEnter(v,data,config,p)
	if p.forcedState ~= FORCEDSTATE_NONE or p.deathTimer ~= 0 or p:mem(0x13C,FIELD_BOOL) then -- forced state/dead check
		return false
	end

	if p:mem(0x15C,FIELD_WORD) > 0 -- warp cooldown
	or p:mem(0x5C,FIELD_BOOL) or p:mem(0x5E,FIELD_BOOL) -- groundpound bounce
	or p.isMega or p.mount == MOUNT_CLOWNCAR
	then
		return false
	end


	if config.horizontal then
		if math.abs((p.y + p.height) - (v.y + v.height)) > 2 then
			return false
		end

		if v.direction == DIR_LEFT then
			if math.abs((p.x + p.width) - v.x) > 2 or not p.keys.right then
				return false
			end
		elseif v.direction == DIR_RIGHT then
			if math.abs(p.x - (v.x + v.width)) > 2 or not p.keys.left then
				return false
			end
		end
	else
		local x1 = v.x + v.width*0.5 - config.enterVerticalWidth*0.5
		local x2 = x1 + config.enterVerticalWidth

		if p.x+p.width < x1 or p.x > x2 then
			return false
		end

		if v.direction == DIR_LEFT then
			if math.abs((p.y + p.height) - v.y) > 2 or p.standingNPC ~= v or not p.keys.down then
				return false
			end
		else
			if math.abs(p.y - (v.y + v.height)) > 2 or not p.keys.up then
				return false
			end
		end
	end

	return true
end

local function canContinueLaunchStuff(p)
	if p.forcedState ~= FORCEDSTATE_NONE or p.deathTimer ~= 0 or p:mem(0x13C,FIELD_BOOL) then -- forced state/dead check
		return false
	end

	if p:mem(0x5C,FIELD_BOOL) -- purple yoshi groundpound
	then
		return false
	end

	return true
end


local function setAimingValues(v,data,config,settings,t)
	t = -(math.cos(t*math.pi) - 1)*0.5

	data.lengthOffset = settings.shootLengthChange*t
	data.rotationOffset = settings.shootRotation*t

	if config.horizontal then
		data.lengthOffset = data.lengthOffset*config.width
	else
		data.lengthOffset = data.lengthOffset*config.height
	end
end


local function getPlayerSettings(p)
	return PlayerSettings.get(playerManager.getBaseID(p.character),p.powerup)
end


local function dropHeldNPC(p)
	if p.mount == MOUNT_YOSHI then
		if p:mem(0xB8,FIELD_WORD) > 0 then
			-- Spit out NPC in yoshi's mouth
			-- Based on: https://github.com/smbx/smbx-legacy-source/blob/master/modPlayer.bas#L5362
			local spitNPC = NPC(p:mem(0xB8,FIELD_WORD) - 1)
			local spitConfig = NPC.config[spitNPC.id]

			if (spitConfig.isshell or spitConfig.isbot or spitNPC.id == 194) and spitNPC.id ~= 24 and p:mem(0x68,FIELD_BOOL) then
				-- Spit out fire
				spitNPC:kill(HARM_TYPE_VANISH)
				SFX.play(42)

				for _,speed in ipairs(yoshiFireSpeeds) do
					local fireNPC = NPC.spawn(108,p.x + p:mem(0x6E,FIELD_WORD) + 32*p.direction,p.y + p:mem(0x70,FIELD_WORD),p.section,false,false)

					fireNPC.direction = p.direction
					fireNPC.speedX = speed.x*p.direction
					fireNPC.speedY = speed.y
				end
			else
				spitNPC.x = p.x + p:mem(0x6E,FIELD_WORD) + 32*p.direction
				spitNPC.y = p.y + p:mem(0x70,FIELD_WORD)
				spitNPC.direction = p.direction

				spitNPC.speedX = 0
				spitNPC.speedY = 0

				spitNPC:mem(0x124,FIELD_BOOL,true) -- set active
				spitNPC:mem(0x134,FIELD_WORD,5) -- set wall crush timer
				spitNPC:mem(0x18,FIELD_FLOAT,0) -- "real" speed x

				-- Reset forced state
				spitNPC:mem(0x138,FIELD_WORD,0)
				spitNPC:mem(0x13C,FIELD_DFLOAT,0)


				if p:mem(0x12E,FIELD_BOOL) then -- if ducking, move it up a little
					spitNPC.y = spitNPC.y - 8
				end

				if spitNPC.id == 45 then -- put blue brick into thrown state
					spitNPC.ai1 = 1
				end

				if not p:isOnGround() or not p.keys.down then
					-- Non-duck spit
					if spitConfig.isshell or spitNPC.id == 45 then
						spitNPC.speedX = mem(SHELL_HORIZONTAL_SPEED,FIELD_FLOAT)*p.direction
					else
						spitNPC:mem(0x136,FIELD_BOOL,true)
						spitNPC.speedX = 7*p.direction
						spitNPC.speedY = -1.3
					end
				end

				if spitNPC.id == 237 then -- yoshi ice block
					spitNPC.speedX = mem(SHELL_HORIZONTAL_SPEED,FIELD_FLOAT)*p.direction*0.6 + p.speedX*0.4
					spitNPC:mem(0x120,FIELD_BOOL,false)
					spitNPC:mem(0x136,FIELD_BOOL,true)
				end

				SFX.play(38)
			end

			p:mem(0xB8,FIELD_WORD,0) -- reset yoshi NPC
		elseif p:mem(0xBA,FIELD_WORD) > 0 then
			-- Spit out player in yoshi's mouth
			-- Based on: https://github.com/smbx/smbx-legacy-source/blob/master/modPlayer.bas#L5330
			local spitPlayer = Player(p:mem(0xBA,FIELD_WORD))

			spitPlayer.forcedState = FORCEDSTATE_NONE
			spitPlayer.forcedTimer = 0

			spitPlayer.section = p.section

			spitPlayer:mem(0x136,FIELD_BOOL,true)

			spitPlayer.x = p.x + p:mem(0x6E,FIELD_WORD) + spitPlayer.width*p.direction + 5
			spitPlayer.direction = -p.direction

			if p.keys.down then
				spitPlayer.y = p.y + p:mem(0x70,FIELD_WORD)
				spitPlayer.speedX = p.speedX*0.3
				spitPlayer.speedY = p.speedY*0.3 + 1
			else
				spitPlayer.y = p.y + 1
				spitPlayer.speedX = p.speedX*0.3 + 7*p.direction
				spitPlayer.speedY = p.speedY*0.3 - 3
			end

			p:mem(0xBA,FIELD_WORD,0) -- reset yoshi player

			-- Make sure the player isn't in a block
			for _,block in Block.iterateIntersecting(spitPlayer.x,spitPlayer.y,spitPlayer.x+spitPlayer.width,spitPlayer.y+spitPlayer.height-1) do
				if not block.isHidden and not block:mem(0x5A,FIELD_BOOL) and (Block.SOLID_MAP[block.id] or Block.PLAYERSOLID_MAP[block.id]) and not Block.SLOPE_MAP[block.id] then
					if p.direction == DIR_RIGHT then
						spitPlayer.x = block.x - spitPlayer.width - 0.01
					else
						spitPlayer.x = block.x + block.width + 0.01
					end
				end
			end

			SFX.play(38)
		end

		p:mem(0x64,FIELD_BOOL,false) -- reset earthquake
		p:mem(0x68,FIELD_BOOL,false) -- reset fire

		if p:mem(0x66,FIELD_BOOL) then
			p:mem(0x66,FIELD_BOOL,false) -- reset flight
			p:mem(0x16C,FIELD_BOOL,false)
			p:mem(0x16E,FIELD_BOOL,false)
		end
		
		return
	end

	p:mem(0x154,FIELD_WORD,0) -- let go of the held NPC
end


local yoshiFireSpeeds = {vector(5,-0.8),vector(5.5,0),vector(5,0.8)}

local function enterPipe(v,data,config,settings,p)
	local pData = cannonPipe.getPlayerData(p)
	
	data.enteringPlayer = p
	pData.usingPipe = v

	data.state = STATE_ENTERED
	data.timer = 0

	p.forcedState = FORCEDSTATE_INVISIBLE
	p.forcedTimer = -p.idx -- just 0 will make player 2 teleport to player 1

	pData.animationName = ""
	pData.animationTimer = 0

	pData.isInvisible = false

	p:mem(0x50,FIELD_BOOL,false) -- stop spin jump
	p:mem(0x164,FIELD_WORD,0) -- stop tail spin
	p:mem(0x10C,FIELD_WORD,0) -- stop yoshi tongue
	p:mem(0xB4, FIELD_WORD,0) -- stop yoshi tongue^2

	-- Unduck the player
	if p:mem(0x12E,FIELD_BOOL) then
		local pSettings = getPlayerSettings(p)

		p.y = p.y + p.height - pSettings.hitboxHeight
		p.height = pSettings.hitboxHeight

		p.frame = 1

		p:mem(0x12E,FIELD_BOOL,false)
	end

	if config.horizontal then
		pData.playerDirection = -v.direction
		p.direction = pData.playerDirection
	else
		pData.playerDirection = p.direction
	end
	
	if settings.noHeldNPCs or (settings.noMounts and player.mount == MOUNT_YOSHI) then
		dropHeldNPC(p)
	end

	SFX.play(17)
end


local function finishPipeEnter(v,p)
	local pData = cannonPipe.getPlayerData(p)
	local data = v.data
	
	if v ~= nil and v.isValid and data.enteringPlayer == p then
		if playerInStates[data.state] then
			data.state = STATE_RETURN
			data.timer = 0
		end

		data.enteringPlayer = nil
	end

	if p ~= nil and p.isValid and pData.usingPipe == v then
		p.forcedState = FORCEDSTATE_NONE
		p.forcedTimer = 0

		pData.usingPipe = nil
	end
end


local function updatePlayer(p)
	local pData = cannonPipe.getPlayerData(p)
	local v = pData.usingPipe

	if v == nil then
		-- Not inside of a pipe, handle being launched
		if not canContinueLaunchStuff(p) then
			pData.launchSpeedActive = false
			pData.trailSmokeTimer = 0

			pData.preventRunActions = false
		end

		local actuallyHoldingRun = p.keys.run

		if pData.launchSpeedActive then
			-- The run speed cap can be bypassed in a multiplayer friendly way using the fact that it's only applied if holding run
			p.keys.run = false

			if actuallyHoldingRun then
				-- Force the player to keep hold of the NPC
				p:mem(0x62,FIELD_WORD,2)
			end

			-- Stop gravity
			if p.speedY > -0.01 then
				if p:mem(0x34,FIELD_WORD) > 0 and p:mem(0x06,FIELD_WORD) == 0 then
					p.speedY = p.speedY - Defines.player_grav*0.1 + 0.001
				elseif playerManager.getBaseID(p.character) == CHARACTER_LUIGI then
					p.speedY = p.speedY - Defines.player_grav*0.9 + 0.001
				else
					p.speedY = p.speedY - Defines.player_grav + 0.001
				end
			end

			p.speedX = p.speedX*0.97

			if math.abs(p.speedX) < Defines.player_runspeed then
				pData.launchSpeedActive = false
			end
		end

		-- Stop various run button actions happening after launching
		if pData.preventRunActions then
			if actuallyHoldingRun then
				p:mem(0x172,FIELD_BOOL,false)
			else
				pData.preventRunActions = false
			end
		end

		if pData.trailSmokeTimer > 0 then
			local pipeConfig = NPC.config[pData.launcherNPCID]

			if pData.trailSmokeTimer%pipeConfig.trailSmokeDelay == 0 then
				local e = Effect.spawn(pipeConfig.trailSmokeID,p.x + p.width*0.5,p.y + p.height*0.5)

				e.x = e.x - e.width *0.5
				e.y = e.y - e.height*0.5
			end

			pData.trailSmokeTimer = pData.trailSmokeTimer - 1
		end

		return
	end

	if not v.isValid then
		finishPipeEnter(nil,p)
		return
	end

	local pipeData = v.data

	if not pipeData.initialized or pipeData.enteringPlayer ~= p or not playerInStates[pipeData.state] then
		finishPipeEnter(v,p)
		return
	end


	local pipeConfig = NPC.config[v.id]
	local pipeSettings = v.data._settings

	local pSettings = getPlayerSettings(p)
	local holdingNPC = p.holdingNPC

	-- Remove the player's mount if necessary
	-- (Has to be done before getting pipe info)
	if pipeData.state ~= STATE_ENTERED and pipeSettings.noMounts and p.mount ~= MOUNT_NONE then
		-- Put the mount into the "owed mount" array
		local owedMountAddr = OWED_MOUNT_ADDR + p.idx*2

		if mem(owedMountAddr,FIELD_WORD) == 0 and p.mount ~= MOUNT_CLOWNCAR then
			mem(owedMountAddr,FIELD_WORD,p.mount)
			mem(OWED_MOUNT_COLOR_ADDR + p.idx*2,FIELD_WORD,p.mountColor)
		end

		-- Remove the player's mount
		p.mount = MOUNT_NONE
		p.mountColor = 0
		p:mem(0x10E,FIELD_WORD,0)

		-- Set size properly
		p.width = pSettings.hitboxWidth
		p.height = pSettings.hitboxHeight

		p.frame = 1
	end


	local pipeInfo = getPipeInfo(v,pipeData,pipeConfig)

	if pipeData.state == STATE_ENTERED then
		-- Enter pipe
		if pipeConfig.horizontal then
			p.y = pipeInfo.playerPosition.y

			if v.direction == DIR_LEFT then
				p.x = math.min(pipeInfo.playerPosition.x,p.x + 0.5)
			else
				p.x = math.max(pipeInfo.playerPosition.x,p.x - 0.5)
			end
		else
			p.x = pipeInfo.playerPosition.x

			if v.direction == DIR_LEFT then
				p.y = math.min(pipeInfo.playerPosition.y,p.y + 1)
			else
				p.y = math.max(pipeInfo.playerPosition.y,p.y - 1)
			end
		end

		if p.x == pipeInfo.playerPosition.x and p.y == pipeInfo.playerPosition.y then
			pipeData.state = STATE_AIMING
			pipeData.timer = 0

			pData.isInvisible = true
		end

		-- Update player animation
		if p.mount == MOUNT_NONE then
			local newAnimName

			if pipeConfig.horizontal then
				if p.holdingNPC ~= nil then
					newAnimName = "walkHolding"
				else
					newAnimName = "walk"
				end
			else
				newAnimName = "front"
			end
		
			local animationSet = cannonPipe.characterAnims[p:getCostume()] or cannonPipe.characterAnims[p.character] or cannonPipe.characterAnims[playerManager.getBaseID(p.character)]
            animationSet = animationSet[p.powerup] or animationSet[PLAYER_BIG] or animationSet

            local animationData = animationSet[newAnimName]

            if newAnimName ~= pData.animationName then
                pData.animationName = newAnimName
                pData.animationTimer = 0
            end

            p:setFrame(animationData[math.floor(pData.animationTimer/(animationData.frameDelay or 1))%#animationData + 1])
            pData.animationTimer = pData.animationTimer + 1
		elseif p.mount == MOUNT_YOSHI then
			-- it functions!
			if pipeConfig.horizontal then
				pData.animationTimer = pData.animationTimer + 1
				p:mem(0x7C,FIELD_WORD,pData.animationTimer%32)

				p.speedX = 0.5*pData.playerDirection
			else
				p.speedX = 0
			end

			p.speedY = 0
		end
	else
		p.x = pipeInfo.playerPosition.x
		p.y = pipeInfo.playerPosition.y
	end

	-- Update held NPC's
	if holdingNPC ~= nil then
		local baseChar = playerManager.getBaseID(p.character)

		if (holdOverHeadCharacters[baseChar] or p:mem(0x12E,FIELD_BOOL)) and pipeConfig.horizontal then
			-- Hold over head
			holdingNPC.x = p.x + p.width*0.5 - holdingNPC.width*0.5
			holdingNPC.y = p.y - holdingNPC.height

			-- Some hardcoded nonsense...
			if baseChar == CHARACTER_PEACH then
				if p.powerup ~= PLAYER_SMALL then
					holdingNPC.y = holdingNPC.y + 6
				end
			elseif p.powerup == PLAYER_SMALL then
				holdingNPC.y = holdingNPC.y + 6
			elseif holdingNPC.id == 13 or holdingNPC.id == 265 then -- holding fire/iceball
				holdingNPC.x = holdingNPC.x + RNG.random(-2,2)
				holdingNPC.y = holdingNPC.y - 4 + RNG.random(-2,2)
			else
				holdingNPC.y = holdingNPC.y + 10
			end
		else
			if not pipeConfig.horizontal then
				holdingNPC.x = p.x + p.width*0.5 - holdingNPC.width*0.5
			elseif p.direction == DIR_RIGHT then
				holdingNPC.x = p.x + pSettings.grabOffsetX
			else
				holdingNPC.x = p.x + p.width - pSettings.grabOffsetX - holdingNPC.width
			end

			holdingNPC.y = p.y + pSettings.grabOffsetY + 32 - holdingNPC.height
		end
	end

	-- Stop direction changing
	if p.mount == MOUNT_YOSHI then
		-- so you can turn around in a forced state with yoshi because sure
		p.keys.left = false
		p.keys.right = false
	end

	p.direction = pData.playerDirection
end


local playerBuffer = Graphics.CaptureBuffer(200,200)

local function drawHeldNPC(p,priority)
	local holdingNPC = p.holdingNPC
	if holdingNPC == nil then
		return
	end

	local image = Graphics.sprites.npc[holdingNPC.id].img
	if image == nil then
		return
	end

	if holdingNPC.animationFrame < 0 then
		return
	end

	local config = NPC.config[holdingNPC.id]

	local width = npcutils.gfxwidth(holdingNPC)
	local height = npcutils.gfxheight(holdingNPC)

	local sourceX = 0
	local sourceY = holdingNPC.animationFrame*height

	local x = playerBuffer.width*0.5 + ((holdingNPC.x + holdingNPC.width*0.5) - (p.x + p.width*0.5)) - width*0.5 + config.gfxoffsetx
	local y = playerBuffer.height*0.5 + ((holdingNPC.y + holdingNPC.height) - (p.y + p.height*0.5)) - height + config.gfxoffsety

	Graphics.drawBox{
		texture = image,target = playerBuffer,priority = priority,
		x = x,y = y,width = width,height = height,
		sourceX = sourceX,sourceY = sourceY,sourceWidth = width,sourceHeight = height,
	}
end

local function drawPlayer(p)
	local pData = cannonPipe.getPlayerData(p)
	local v = pData.usingPipe

	if v == nil or not v.isValid then
		return
	end

	local holdingNPC = p.holdingNPC

	if not pData.isInvisible then
		local pipeConfig = NPC.config[v.id]
		local priority = -75

		local heldNPCHasPriority = ((not pipeConfig.horizontal) or holdOverHeadCharacters[playerManager.getBaseID(p.character)])

		playerBuffer:clear(priority)
		--Graphics.drawBox{target = playerBuffer,priority = priority,color = Color.red.. 0.2,x = 0,y = 0,width = playerBuffer.width,height = playerBuffer.height}

		if not heldNPCHasPriority then
			drawHeldNPC(p,priority)
		end

		p:render{
			target = playerBuffer,priority = priority,
			sceneCoords = false,ignorestate = true,
			x = playerBuffer.width*0.5 - p.width*0.5,
			y = playerBuffer.height*0.5 - p.height*0.5,
		}

		if heldNPCHasPriority then
			drawHeldNPC(p,priority)
		end

		-- Draw the buffer to the screen
		local x = p.x + p.width*0.5 - playerBuffer.width*0.5
		local y = p.y + p.height*0.5 - playerBuffer.height*0.5

		local width = playerBuffer.width
		local height = playerBuffer.height

		local sourceX = 0
		local sourceY = 0

		if pipeConfig.horizontal then
			if v.direction == DIR_LEFT then
				width = width - math.max(0,(x + width) - v.x)
			else
				local cutoff = math.max(0,(v.x + v.width) - x)

				width = width - cutoff
				sourceX = sourceX + cutoff
				x = x + cutoff
			end
		else
			if v.direction == DIR_LEFT then
				height = height - math.max(0,(y + height) - v.y)
			else
				local cutoff = math.max(0,(v.y + v.height) - y)

				height = height - cutoff
				sourceY = sourceY + cutoff
				y = y + cutoff
			end
		end

		Graphics.drawBox{
			texture = playerBuffer,priority = priority,sceneCoords = true,
			x = x,y = y,sourceWidth = width,sourceHeight = height,
			sourceX = sourceX,sourceY = sourceY,
		}

		--Graphics.drawBox{texture = playerBuffer,x = 0,y = 0,priority = priority}
	end

	if holdingNPC ~= nil then
		npcutils.hideNPC(holdingNPC)
	end

	--p:render{ignorestate = true,priority = -1,color = Color.white.. 0.5}
end


local function initialise(v,data,config,settings)
	if not data.initializedPreSpawn then
		initialisePreSpawn(v,data)
	end

	data.state = STATE_NEUTRAL
	data.timer = 0

	data.lengthOffset = 0
	data.rotationOffset = 0
	data.shootAnimValue = 0

	data.enteringPlayer = nil

	data.initialized = true
end


function cannonPipe.onTickEndNPC(v)
	if Defines.levelFreeze then return end
	
	local data = v.data

	if not data.initializedPreSpawn then
		initialisePreSpawn(v,data)
	end
	
	if v.despawnTimer <= 0 then
		data.initialized = false
		return
	end

	local config = NPC.config[v.id]
	local settings = v.data._settings

	if not data.initialized then
		initialise(v,data,config,settings)
	end

	local p = data.enteringPlayer

	if data.state == STATE_NEUTRAL then
		for _,p in ipairs(Player.get()) do
			if playerCanEnter(v,data,config,p) then
				enterPipe(v,data,config,settings,p)
				break
			end
		end
	elseif p ~= nil and (not p.isValid or not playerInStates[data.state]) then
		finishPipeEnter(v,p)
	end


	if data.state == STATE_AIMING then
		data.timer = data.timer + 1

		setAimingValues(v,data,config,settings,data.timer/config.aimDuration)

		if data.timer >= config.aimDuration then
			data.state = STATE_AIMED
			data.timer = 0
		end
	elseif data.state == STATE_AIMED then
		data.timer = data.timer + 1
		data.shootAnimValue = math.clamp(data.timer/config.preShootDuration*2 - 1)

		if data.timer >= config.preShootDuration then
			data.state = STATE_SHOOT
			data.timer = 0

			local pData = cannonPipe.getPlayerData(p)
			local info = getPipeInfo(v,data,config)

			local pos = info.playerPosition + vector(0,-1):rotate(info.totalRotation)*math.max(p.width,p.height)
			local speed = vector(0,-settings.force):rotate(info.totalRotation)

			p.x = pos.x
			p.y = pos.y

			p.speedX = speed.x
			p.speedY = speed.y + 0.001

			p:mem(0x176,FIELD_WORD,0) -- NPC stood on
			p:mem(0x48,FIELD_WORD,0) -- slope stood on

			pData.launcherNPCID = v.id

			pData.launchSpeedActive = (math.abs(p.speedX) > Defines.player_runspeed)

			pData.trailSmokeTimer = config.trailSmokeDelay*config.trailSmokeCount
			pData.preventRunActions = true

			-- Spawn launch effect
			local e = Effect.spawn(config.launchSmokeID,info.topPosition.x,info.topPosition.y)

			e.x = e.x - e.width *0.5
			e.y = e.y - e.height*0.5


			SFX.play(22)

			finishPipeEnter(v,p)
		end
	elseif data.state == STATE_SHOOT then
		data.timer = data.timer + 1

		local t = math.max(0,1 - data.timer/10)
		data.shootAnimValue = -math.cos(t*math.pi*2)*t*2

		if data.timer >= config.postShootDuration then
			data.state = STATE_RETURN
			data.timer = 0
		end
	elseif data.state == STATE_RETURN then
		data.timer = data.timer + 1

		setAimingValues(v,data,config,settings,1 - data.timer/config.returnDuration)

		if data.timer >= config.returnDuration then
			data.state = STATE_NEUTRAL
			data.timer = 0

			data.rotationOffset = 0
			data.lengthOffset = 0
		end
	end


	local info = getPipeInfo(v,data,config)
	--[[local length = 0

	if config.horizontal then
		if v.direction == DIR_LEFT then
			length = (v.x + v.width) - info.topPosition.x
		else
			length = info.topPosition.x - v.x
		end
	else
		if v.direction == DIR_LEFT then
			length = (v.y + v.height) - info.topPosition.y
		else
			length = info.topPosition.y - v.y
		end
	end

	setPipeHitboxSize(v,data,config,math.max(1,length),false)]]
	setPipeHitboxSize(v,data,config,info.totalLength,false)
	--Colliders.getHitbox(v):Draw()
end


local baseGlDrawArgs = {vertexCoords = {},textureCoords = {}}
local baseOldVertexCount = 0

local drawDebug = false

local function drawBase(v,data,config,info,texture,priority,frames)
	local totalLength = info.baseLength

	if totalLength <= 0 then
		return
	end

	local vc = baseGlDrawArgs.vertexCoords
	local tc = baseGlDrawArgs.textureCoords

	local vertexCount = 0
	local colorCount = 0

	baseGlDrawArgs.texture = texture
	baseGlDrawArgs.priority = priority
	baseGlDrawArgs.sceneCoords = true

	if drawDebug then
		baseGlDrawArgs.vertexColors = {}
	else
		baseGlDrawArgs.vertexColors = nil
	end


	local frameHeight = 1/frames

	local segX = v.x + v.width*0.5
	local segY = v.y + v.height*0.5*(1 - v.direction)

	if config.horizontal then
		segX = v.x + v.width*0.5*(1 - v.direction)
		segY = v.y + v.height*0.5
	end

	local distance = 0

	while (true) do
		local distToEnd = totalLength - distance
		local segHeight = math.min(distToEnd,BASE_STEP_SIZE)

		if segHeight <= 0 then
			break
		end

		local segWidth = texture.width


		local shootAnimEffect = ((info.totalLength - config.shootAnimOffset) - distance)/config.shootAnimHeight*2

		if shootAnimEffect > -1 and shootAnimEffect < 1 then
			segWidth = segWidth + math.abs(math.cos(shootAnimEffect*math.pi*0.5))*config.shootAnimWidth*data.shootAnimValue
		end

		local segRotation = math.rad(math.lerp(info.baseRotation,info.totalRotation,math.max(0,1 - distToEnd/info.postRotationDistance)))

		local sinRotation = math.sin(segRotation)
		local cosRotation = math.cos(segRotation)

		local w1 = cosRotation*segWidth*0.5
		local w2 = sinRotation*segWidth*0.5
		local h1 = -sinRotation*segHeight
		local h2 = -cosRotation*segHeight


		-- Insert vertex coords
		local topLeftX,topLeftY,topRightX,topRightY

		if vertexCount > 0 then
			topLeftX  = vc[vertexCount - 11] -- previous one's bottom left
			topLeftY  = vc[vertexCount - 10]
			topRightX = vc[vertexCount - 9]  -- previous one's bottom right
			topRightY = vc[vertexCount - 8]
		else
			topLeftX  = math.floor(segX - w1 + 0.5)
			topLeftY  = math.floor(segY - w2 + 0.5)
			topRightX = math.floor(segX + w1 + 0.5)
			topRightY = math.floor(segY + w2 + 0.5)
		end

		vc[vertexCount+1]  = math.floor(segX - h1 - w1 + 0.5) -- bottom left
		vc[vertexCount+2]  = math.floor(segY + h2 - w2 + 0.5)
		vc[vertexCount+3]  = math.floor(segX - h1 + w1 + 0.5) -- bottom right
		vc[vertexCount+4]  = math.floor(segY + h2 + w2 + 0.5)
		vc[vertexCount+5]  = topLeftX                         -- top left
		vc[vertexCount+6]  = topLeftY

		vc[vertexCount+7]  = math.floor(segX - h1 + w1 + 0.5) -- bottom right
		vc[vertexCount+8]  = math.floor(segY + h2 + w2 + 0.5)
		vc[vertexCount+9]  = topRightX                        -- top right
		vc[vertexCount+10] = topRightY
		vc[vertexCount+11] = topLeftX                         -- top left
		vc[vertexCount+12] = topLeftY

		
		-- Insert texture coords
		local x1 = 0
		local x2 = 1
		local y1 = ((-distance/texture.height) % frameHeight) + frameHeight*2
		local y2 = (y1 - segHeight/texture.height)

		tc[vertexCount+1]  = x1 -- bottom left
		tc[vertexCount+2]  = y2
		tc[vertexCount+3]  = x2 -- bottom right
		tc[vertexCount+4]  = y2
		tc[vertexCount+5]  = x1 -- top left
		tc[vertexCount+6]  = y1

		tc[vertexCount+7]  = x2 -- bottom right
		tc[vertexCount+8]  = y2
		tc[vertexCount+9]  = x2 -- top right
		tc[vertexCount+10] = y1
		tc[vertexCount+11] = x1 -- top left
		tc[vertexCount+12] = y1


		-- Insert vertex colors (if debug is active)
		if drawDebug then
			local b = distance/totalLength

			local vColors = baseGlDrawArgs.vertexColors
			local color = Color(b,b,b,1)

			for i = 1,6 do
				for j = 1,4 do
					colorCount = colorCount + 1
					vColors[colorCount] = color[j]
				end
			end
		end


		vertexCount = vertexCount + 12


		segX = segX + sinRotation*segHeight
		segY = segY - cosRotation*segHeight

		distance = distance + segHeight
	end

	-- Clear out old vertices
	for i = vertexCount+1,baseOldVertexCount do
		vc[i] = nil
		tc[i] = nil
	end

	baseOldVertexCount = vertexCount

	Graphics.glDraw(baseGlDrawArgs)
end

function cannonPipe.onDrawNPC(v)
	if v.despawnTimer <= 0 or v.isHidden then return end

	local config = NPC.config[v.id]
	local data = v.data

	local settings = v.data._settings

	if not data.initialized then
		initialise(v,data,config,settings)
	end


	local texture = Graphics.sprites.npc[v.id].img
	local frames = npcutils.getTotalFramesByFramestyle(v)

	local info = getPipeInfo(v,data,config)

	local priority = -66
	if config.foreground then
		priority = -16
	end

	if data.topSprite == nil then
		data.topSprite = Sprite{texture = texture,frames = frames,pivot = Sprite.align.TOP}
	end


	-- Draw the base
	drawBase(v,data,config,info,texture,priority,frames)


	local color
	if drawDebug then
		color = Color.white.. 0.25
	end


	data.topSprite.position = info.topPosition
	data.topSprite.rotation = info.totalRotation

	data.topSprite:draw{priority = priority,color = color,sceneCoords = true}


	npcutils.hideNPC(v)
end


function cannonPipe.onTick()
	for _,p in ipairs(Player.get()) do
		updatePlayer(p)
	end
end

function cannonPipe.onDraw()
	for _,p in ipairs(Player.get()) do
		drawPlayer(p)
	end
end


function cannonPipe.onInitAPI()
	registerEvent(cannonPipe,"onTick")
	registerEvent(cannonPipe,"onDraw")
end


-- The animations used by each character/costume when entering a pipe
cannonPipe.characterAnims = {}

cannonPipe.characterAnims[CHARACTER_MARIO] = {
    [PLAYER_SMALL] = {walk = {1,2, frameDelay = 10},walkHolding = {5,6, frameDelay = 10},front = {15}},
    [PLAYER_BIG] = {walk = {1,2,3,2, frameDelay = 5},walkHolding = {8,9,10,9, frameDelay = 5},front = {15}},
}
cannonPipe.characterAnims[CHARACTER_PEACH] = {
    [PLAYER_BIG] = {walk = {1,2,3,2, frameDelay = 5},walkHolding = {8,9,10,9, frameDelay = 5},front = {15}},
}
cannonPipe.characterAnims[CHARACTER_LINK] = {
    [PLAYER_BIG] = {walk = {1,4,3,2, frameDelay = 8},walkHolding = {1,4,3,2, frameDelay = 5},front = {1}},
}

cannonPipe.characterAnims["SMW-MARIO"] = {
    [PLAYER_SMALL] = {walk = {2,1, frameDelay = 12},walkHolding = {6,5, frameDelay = 12},front = {15}},
    [PLAYER_BIG] = {walk = {3,2,1, frameDelay = 12},walkHolding = {10,9,8, frameDelay = 12},front = {15}},
}
cannonPipe.characterAnims["SMW-TOAD"] = {
    [PLAYER_SMALL] = {walk = {2,1, frameDelay = 12},walkHolding = {9,8, frameDelay = 12},front = {15}},
    [PLAYER_BIG] = {walk = {3,2,1, frameDelay = 12},walkHolding = {10,9,8, frameDelay = 12},front = {15}},
}

cannonPipe.characterAnims[CHARACTER_LUIGI] = cannonPipe.characterAnims[CHARACTER_MARIO]
cannonPipe.characterAnims[CHARACTER_TOAD] = cannonPipe.characterAnims[CHARACTER_PEACH]

cannonPipe.characterAnims["SMW-LUIGI"] = cannonPipe.characterAnims["SMW-MARIO"]


return cannonPipe