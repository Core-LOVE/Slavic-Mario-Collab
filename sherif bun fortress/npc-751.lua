local npc = {}

local id = NPC_ID
local npcManager = require 'npcManager'

npcManager.setNpcSettings{
	id = id,
	
	width = 86,
	height = 48,
	gfxwidth = 86,
	gfxheight = 48,
	
	nohurt = true,
	jumphurt = true,
	
	nogravity = true,
}

npcManager.registerHarmTypes(id, {9}, {})

local tween = require 'devkit/tween'
local cam = {x = 0}

local startScroll = false
local plane
local endScroll = false

local handycam = require("handycam")
local c = handycam[1]
c.targets = {}

function npc.onTickNPC(v)
	local data = v.data
	data.hp = data.hp or 3
	
	if not startScroll then
		for k,p in ipairs(Player.getIntersecting(v.x, v.y, v.x + v.width, v.y + v.height)) do
			startScroll = true
			p.forcedState = 8
			plane = v
			v.speedX = 5
			NPC.config[13].nogravity = true
			cam.tween = tween.new(0.75, cam, {x = 256}, 'outCirc')
			
			break
		end
	end
	
	if not startScroll then return end
	
	local bound = Section(player.section).boundary
	
	if v.y + v.height * 0.5 < bound.top then
		v.data.hp = 0
		v:kill(9)
	end
	
	local p = player
	
	if p.keys.down then
		v.speedY = 6
	elseif p.keys.up then
		v.speedY = -6
	else
		v.speedY = 0
	end
end

local function explode(v)
	endScroll = true
	
	SFX.play(43)
	
	for k,b in Block.iterate(751) do
		b:remove()
		Effect.spawn(69, b.x, b.y)
	end
	
	v.data.hp = 0
	v:kill(9)
end

function npc.onTickEndNPC(v)
	if not startScroll then return end
	
	if player.keys.run then
		local time = lunatime.tick() 
		
		if time % 10 == 0 then
			SFX.play 'shoot.ogg'
			
			local bullet = NPC.spawn(13, v.x + 76, v.y + 20)
			bullet.despawnTimer = 100
			bullet.speedX = 16
			bullet.ai1 = 4
		end
	end
	
	c.targets[1] = vector(v.x, v.y)
	
	for k,b in Block.iterateIntersecting(v.x, v.y, v.x + v.width + 1, v.y + v.height) do
		if b.id == 751 then
			return explode(v)
		end
	end
	
	if v.ai2 > 0 then
		v.ai2 = v.ai2 - 1
		
		if math.random() > 0.5 then
			v.animationFrame = -1
			v.animationTimer = 7
		end
		
		return
	end
	
	for k,n in NPC.iterateIntersecting(v.x, v.y, v.x + v.width, v.y + v.height) do
		local cfg = NPC.config[n.id]
		
		if not n.friendly and n.id ~= 13 and not cfg.nohurt then
			SFX.play(1)
			v:kill(9)
			break
		end
	end
end

local icon = Graphics.loadImageResolved 'icon.png'
local mario = Graphics.loadImageResolved 'mario.png'
local x = 28
local y = -16

local heart = Graphics.loadImageResolved 'devkit/heart.png'

function npc.onCameraDraw()
	if not startScroll then return end
	
	if plane.animationFrame >= 0 then
		Graphics.drawBox{
			texture = mario,
			
			x = plane.x + x,
			y = plane.y + y,
			
			sceneCoords = true,
			priority = -75,
		}
	end
	
	Graphics.drawBox{
		texture = icon,
		
		x = 32,
		y = 128,
	}

	local dx = 0
	local data = plane.data
	
	for i = 1, 3 do
		local col
		
		if i > data.hp then
			col = {0.5, 0.5, 0.5, 0.5}
		end
		
		Graphics.drawBox{
			texture = heart,
			
			x = 32 + icon.width + dx,
			y = 128,
			
			color = col,
		}
		
		dx = dx + heart.width + 2
	end
end

function npc.onCameraUpdate()
	if cam.tween then
		local done = cam.tween:update(0.01)
		
		if done then
			cam.tween = nil
		end
	end
	
	camera.x = camera.x + cam.x
end

function npc.onNPCKill(e, v, r)
	if v.id ~= id then return end
	
	local data = v.data
	
	if data.hp > 1 then
		Defines.earthquake = 10
		SFX.play('planeHurt.ogg')
		v.ai2 = 75
		
		data.hp = data.hp - 1
		
		Effect.spawn(73, v.x + math.random(v.width - 32), v.y + math.random(v.height - 32))
		
		e.cancelled = true
	else
		NPC.config[13].nogravity = false
		SFX.play('planeHurt.ogg')
		
		local e = Effect.spawn(751, v.x, v.y)
		e.speedX = -2
		e.speedY = -6
		
		Effect.spawn(69, v.x + v.width / 2, v.y + v.height / 2)
		SFX.play(43)
		
		plane = nil
		startScroll = nil
		player.x = v.x + v.width / 2
		player.y = v.y + v.height / 2
		player.forcedState = 0
		
		if not endScroll then
			player:kill()
		else
			cam.tween = tween.new(0.75, cam, {x = 0}, 'outCirc')
			player.forcedTimer = 0
			player.BlinkTimer = 75
			player.speedX = 9
			player.speedY = -6
			c.targets = nil
			
			endScroll = false
		end
	end
end

function npc.onInitAPI()
	npcManager.registerEvent(id, npc, 'onTickNPC')
	npcManager.registerEvent(id, npc, 'onTickEndNPC')
	registerEvent(npc, 'onCameraUpdate')
	registerEvent(npc, 'onCameraDraw')
	registerEvent(npc, 'onNPCKill')
end

return npc