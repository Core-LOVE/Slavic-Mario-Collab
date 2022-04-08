--[[

	Written by MrDoubleA
	Please give credit!

	Part of MrDoubleA's NPC Pack

]]

local npcManager = require("npcManager")
local npcutils = require("npcs/npcutils")



spike = {}

spike.spikeIDs = {}
spike.ballIDs  = {}



function spike.registerSpike(selfID)
	npcManager.registerEvent(selfID,spike,"onTickEndNPC","onTickEndSpike")
	npcManager.registerEvent(selfID,spike,"onDrawNPC","onDrawSpike")
	spike.spikeIDs[selfID] = true
end

function spike.registerBall(selfID)
	npcManager.registerEvent(selfID,spike,"onTickNPC","onTickBall")
	npcManager.registerEvent(selfID,spike,"onDrawNPC","onDrawBall")
	spike.ballIDs[selfID] = true
end

function spike.onInitAPI()
	registerEvent(spike,"onTick")
	registerEvent(spike,"onDraw")
	registerEvent(spike,"onNPCHarm")
	registerEvent(spike,"onPostNPCKill")
end


local STATE_STANDING = 0
local STATE_THROWING = 1



local colBox = Colliders.Box(0,0,0,0)

-- This function is just to fix   r e d i g i t   issues lol
local function gfxSize(config)
	local gfxwidth  = config.gfxwidth
	if gfxwidth  == 0 then gfxwidth  = config.width  end
	local gfxheight = config.gfxheight
	if gfxheight == 0 then gfxheight = config.height end

	return gfxwidth, gfxheight
end

local function drawBall(data,id,x,y,frame,priority,rotation)
	local config = NPC.config[id]
	local gfxwidth,gfxheight = gfxSize(config)

	if data.ballSprite == nil then
		local texture = Graphics.sprites.npc[id].img

		data.ballSprite = Sprite{texture = texture,frames = texture.height/gfxheight,pivot = Sprite.align.CENTRE}
	end

	data.ballSprite.x = x
	data.ballSprite.y = y
	data.ballSprite.rotation = rotation or 0

	data.ballSprite:draw{frame = frame+1,priority = priority,sceneCoords = true}
end
spike.drawBall = drawBall

local function getSlopeAngle(v)
	for _,b in ipairs(Block.getIntersecting(v.x,v.y + v.height,v.x + v.width,v.y + v.height + 0.2)) do
		if Block.SLOPE_LR_FLOOR_MAP[b.id] then
			return math.deg(math.atan2(
				(b.y) - (b.y + b.height),
				(b.x + b.width) - (b.x)
			))
		elseif Block.SLOPE_RL_FLOOR_MAP[b.id] then
			return math.deg(math.atan2(
				(b.y + b.height) - (b.y),
				(b.x + b.width) - (b.x)
			))
		end
	end
end



-- Stuff related to spike balls' fragments below



spike.fragments = {}

local function createFragments(id,x,y,rotation)
	local config = NPC.config[id]
	local gfxwidth,gfxheight = gfxSize(config)

	for i=1,4 do
		local nX,nY
		local frameX,frameY

		if i == 1 or i == 3 then
			nX = -(gfxwidth / 4)
			frameX = 1
		else 
			nX = (gfxwidth / 4)
			frameX = 2
		end
		if i == 1 or i == 2 then
			nY = -(gfxheight / 4)
			frameY = 1
		else
			nY = (gfxheight / 4)
			frameY = 2
		end

		local position = vector(x,y) + vector(nX,nY):rotate(rotation)

		table.insert(
			spike.fragments,
			{
				id = id,groupIdx = i,
				x = position.x,y = position.y,
				rotation = rotation,
				speedX = RNG.random(-3,3),
				speedY = RNG.random(0,-7),
				frameX = frameX,
				frameY = frameY,
			}
		)
	end
end


function spike.onPostNPCKill(v,killReason)
	if not spike.spikeIDs[v.id] and not spike.ballIDs[v.id] then return end

	local config = NPC.config[v.id]
	local data = v.data

	if (killReason ~= HARM_TYPE_OFFSCREEN and killReason ~= HARM_TYPE_LAVA) and spike.ballIDs[v.id] then
		createFragments(
			v.id,
			v.x + (v.width / 2) + config.gfxoffsetx,
			v.y + (v.height / 2) + config.gfxoffsety,
			data.rotation or 0
		)
	elseif (killReason ~= HARM_TYPE_OFFSCREEN and killReason ~= HARM_TYPE_LAVA) and spike.spikeIDs[v.id] and data.animationBall then
		if spike.ballIDs[data.throwID] then
			createFragments(
				data.throwID,
				v.x + (v.width / 2) + config.gfxoffsetx,
				(v.y + v.height) + config.gfxoffsety + data.animationBall.yOffset - (NPC.config[data.throwID].gfxheight / 2),
				0
			)
		else
			Effect.spawn(10,v.x + (v.width / 2) - 16,v.y + (v.height / 2) - 16)
		end
	end
end



function spike.onTick()
	if Defines.levelFreeze then return end

	for i = #spike.fragments, 1, -1 do
		local v = spike.fragments[i]

		v.speedY = v.speedY + Defines.npc_grav
		if v.speedY > 12 then
			v.speedY = 12
		end

		v.x = v.x + v.speedX
		v.y = v.y + v.speedY

		v.rotation = ((v.rotation + (v.speedX * 6)) % 360)
		
		local gfxwidth,gfxheight = gfxSize(NPC.config[v.id])

		if (v.y - gfxheight*0.25) > camera.y+camera.height then
			table.remove(spike.fragments,i)
		end
	end
end

function spike.onDraw()
	for _,v in ipairs(spike.fragments) do
		local config = NPC.config[v.id]
		local gfxwidth,gfxheight = gfxSize(config)

		if v.sprite == nil then
			local texture = Graphics.sprites.npc[v.id].img

			v.sprite = Sprite{texture = texture,frames = vector(2,(texture.height/gfxheight) * 2),pivot = Sprite.align.CENTRE}
		end

		local frame

		v.sprite.x,v.sprite.y = v.x,v.y
		v.sprite.rotation = v.rotation

		v.sprite:draw{frame = vector(v.frameX,v.frameY),priority = -5,sceneCoords = true}
	end
end



-- Stuff related to the actual NPCs below



function spike.onTickEndSpike(v)
	if Defines.levelFreeze then return end
	
	local data = v.data
	
	if v:mem(0x12A, FIELD_WORD) <= 0 then
		data.state = nil
		data.timer = nil
		data.animationBall = nil
		return
	end

	local config = NPC.config[v.id]
	local frames = (config.idleFrames + 3)
	if not data.state then
		data.state = STATE_STANDING
		data.timer = 0
		data.animationBall = nil

		data.throwID = v.ai1
		if data.throwID == 0 then
			data.throwID = config.throwID
		end
	end

	-- Animation
	if data.state == STATE_STANDING	then
		v.animationFrame = math.floor(data.timer / config.idleFramespeed) % config.idleFrames
	elseif data.state == STATE_THROWING then
		local b = data.animationBall
		if b and b.speedY >= 0 and b.yOffset >= -v.height then
			v.animationFrame = frames - 1
		elseif b and b.speedY < 0 then
			v.animationFrame = frames - 2
		else
			v.animationFrame = frames - 3
		end
	end
	if config.framestyle >= 1 and v.direction == DIR_RIGHT then
		v.animationFrame = v.animationFrame + frames
	end
	if config.framestyle >= 2 and (v:mem(0x12C, FIELD_WORD) > 0 or v:mem(0x136, FIELD_BOOL)) then
		v.animationFrame = v.animationFrame + frames
		if v.direction == DIR_RIGHT then
			v.animationFrame = v.animationFrame + frames
		end
	end

	if v:mem(0x12C, FIELD_WORD) > 0    --Grabbed
	or v:mem(0x136, FIELD_BOOL)        --Thrown
	or v:mem(0x138, FIELD_WORD) > 0    --Contained within
	then
		data.state = STATE_STANDING
		data.timer = 0
		data.animationBall = nil
		return
	end

	if data.state == STATE_STANDING then
		data.timer = data.timer + 1

		if data.timer > config.idleTime then
			data.state = STATE_THROWING
			data.timer = 0
		end
	elseif data.state == STATE_THROWING then
		if not data.animationBall then
			local goalY = -v.height - 16
			local t = 24

			local speedY = (goalY / t) - (Defines.npc_grav * t) / 2

			data.animationBall = {yOffset = 0,speedY = speedY}
		end


		local b = data.animationBall

		b.speedY = b.speedY + Defines.npc_grav
		if b.speedY > 8 then
			b.speedY = 8
		end
		b.yOffset = b.yOffset + b.speedY

		if b.speedY >= 0 and b.yOffset >= -v.height then
			b.yOffset = -v.height
			b.speedY = 0
			data.timer = data.timer + 1
			if data.timer >= config.holdTime then
				data.state = STATE_STANDING
				data.timer = 0
				local s = NPC.spawn(
					data.throwID,
					v.x + (v.width  / 2),
					v.y - (NPC.config[data.throwID].height / 2) + v.speedY,
					v:mem(0x146,FIELD_WORD),
					false,true
				)
				
				s.direction = v.direction
				s.speedX = (config.throwXSpeed) * v.direction
				s.speedY = -(config.throwYSpeed)
				s.data.rotation = 0
				s.data.bounced = false
				s.friendly = v.friendly
				s:mem(0x136, FIELD_BOOL,true)
				data.animationBall = nil -- Remove animation version of ball

				-- Play throw sound effect
				if config.throwSFX then
					SFX.play(config.throwSFX)
				end
			end
		end
	end
end

function spike.onDrawSpike(v)
	if v:mem(0x12A, FIELD_WORD) <= 0 then return end

	local data = v.data
	local b = data.animationBall

	if not b then return end

	local config = NPC.config[v.id]
	local bconfig = NPC.config[data.throwID]

	local gfxwidth,gfxheight = gfxSize(bconfig)

	local priority
	if bconfig.priority then
		priority = -16
	else
		priority = -46
	end

	local frame = 0
	if v.direction == DIR_RIGHT and bconfig.framestyle >= 1 then
		frame = bconfig.frames
	end

	drawBall(
		data,
		data.throwID,
		(v.x + (v.width / 2)) + bconfig.gfxoffsetx,
		(v.y + v.height) - (gfxheight/2) + b.yOffset + bconfig.gfxoffsety,
		frame,priority,0
	)
end

function spike.onTickBall(v)
	if Defines.levelFreeze then return end
	
	local data = v.data

	if v:mem(0x12A, FIELD_WORD) <= 0 then
		data.rotation = nil
		data.bounced = nil
		return
	end
	
	local config = NPC.config[v.id]

	if not data.rotation then
		data.rotation = 0
		data.bounced = v.collidesBlockBottom
		v.speedX = (config.startingSpeed or 2.5) * v.direction
	end

	if v:mem(0x12C, FIELD_WORD) > 0
	or v:mem(0x138, FIELD_WORD) > 0
	then
		data.rotation = 0
		return
	end

	-- Kill enemies
	if not config.issnowball then
		colBox.x,colBox.y          = v.x+v.speedX,v.y+v.speedY
		colBox.width,colBox.height = v.width,v.height

		local collisions = Colliders.getColliding{
			a = colBox,
			b = NPC.HITTABLE,
			btype = Colliders.NPC,
		}
		local collided = false

		for _,w in ipairs(collisions) do
			if v.idx ~= w.idx and (not spike.ballIDs[w.id] or config.islarge or not NPC.config[w.id].islarge) then
				w:harm(HARM_TYPE_NPC)
				collided = true
			end
		end

		if collided and config.islarge then
			v:mem(0x120,FIELD_BOOL,false)
		elseif collided then
			v:harm(HARM_TYPE_NPC)
		end
	end

	-- Destroy blocks
	if config.ishot then
		for _,b in ipairs(Block.getIntersecting((v.x + v.speedX) - 4, (v.y + v.speedY) - 4, (v.x + v.width + v.speedX) + 4, (v.y + v.height + v.speedY) + 4)) do
			if b.id == 669 and b.isValid and not b.isHidden then
				Effect.spawn(131, b.x, b.y).speedY = -1
				b:remove()
			end
		end
	end
	
	if not config.noblockcollision and v:mem(0x120,FIELD_BOOL) then
		local destroyedBlock = false
		for _,b in ipairs(Block.getIntersecting(v.x + v.speedX,v.y + v.speedY,v.x + v.width + v.speedX,v.y + v.height + v.speedY)) do
			if Block.SOLID_MAP[b.id] and not b.isHidden and not b.layerObj.isHidden then
				if Block.MEGA_SMASH_MAP[b.id] and not config.issnowball then
					b:remove(true)
					destroyedBlock = true
				else
					b:hit()
				end
			end
		end
		
		if not config.islarge or config.issnowball or not destroyedBlock then
			v:kill()
		elseif destroyedBlock then
			v:mem(0x120,FIELD_BOOL,false)
		end
	end

	if config.issnowball then
		for _,p in ipairs(Player.get()) do
			if p.forcedState == 0 and p.deathTimer == 0 and Colliders.collide(v,p) then
				v:kill()
				if (v.x + (v.width / 2)) > (p.x + (p.width / 2)) then
					p.speedX = -2.5
				elseif (v.x + (v.width / 2)) < (p.x + (p.width / 2)) then
					p.speedX = 2.5
				end
				if (v.y + (v.height / 2)) > (p.y + (p.height / 2)) then
					p.speedY = -2.5
				elseif (v.y + (v.height / 2)) < (p.y + (p.height / 2)) then
					p.speedY = 2.5
				end
			end
		end
	end

	v:mem(0x136,FIELD_BOOL,false)
	
	if v.collidesBlockBottom and not data.bounced and v.speedY > -(config.bounceHeight or 4) then
		data.bounced = true
		if not config.bounceHeight or config.bounceHeight > 0 then
			v.speedY = -(config.bounceHeight or 4)
		end
	end

	v.speedX = v.speedX + ((getSlopeAngle(v) or 0) / 896)
	
	if not v.dontMove then
		data.rotation = ((data.rotation or 0) + math.deg((v.speedX*config.speed)/((v.width+v.height)/4)))
	end
end

function spike.onDrawBall(v)
	if v:mem(0x12A, FIELD_WORD) <= 0
	or v:mem(0x12C, FIELD_WORD) > 0
	or v:mem(0x138, FIELD_WORD) > 0
	then return end

	local data = v.data
	local bconfig = NPC.config[v.id]
	local priority
	if bconfig.priority then
		priority = -15
	else
		priority = -45
	end
	
	drawBall(
		data,
		v.id,
		(v.x + (v.width / 2)) + bconfig.gfxoffsetx,
		(v.y + v.height - (bconfig.gfxheight / 2)) + bconfig.gfxoffsety,
		v.animationFrame,priority,data.rotation,bconfig
	)

	npcutils.hideNPC(v)
end


function spike.onNPCHarm(eventObj,v,reason,culprit)
	if not spike.ballIDs[v.id] then return end

	local config = NPC.config[v.id]
	local data = v.data

	if reason == HARM_TYPE_TAIL and not config.issnowball then
		if type(culprit) == "Player" then
			v.speedX = math.abs(v.speedX) * math.sign((v.x + v.width*0.5) - (culprit.x + culprit.width*0.5))
		else
			v.speedX = -v.speedX
		end

		v.speedY = -6.5
		data.bounced = false

		SFX.play(2)

		eventObj.cancelled = true
	end
end


return spike