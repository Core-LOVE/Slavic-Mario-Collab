local npc = {}
local id = NPC_ID

local npcManager = require 'npcManager'

npcManager.setNpcSettings{
	id = id,
	
	width = 64,
	height = 64,
	gfxwidth = 64,
	gfxheight = 64,
	
	frames = 1,

	nogravity = true,
	noblockcollision = true,
}

local redirectors = {
	[191] = {speedY = -1},
	[192] = {speedY = 1},
	[193] = {speedX = -1},
	[194] = {speedX = 1},
	
	[195] = {speedX = -1, speedY = -1},
	[196] = {speedX = 1, speedY = -1},
	[197] = {speedX = 1, speedY = 1},
	[198] = {speedX = -1, speedY = 1},
	
	[199] = {},
}

local speed = 3

local function doFlip(v, data)
	if data.flipState ~= 0 then return end
	
	SFX.create{
		parent = v,
		sound = 'flip.ogg',
		type = SFX.SOURCE_CIRCLE,
		falloffRadius = 256,
		sourceRadius = 64,
		loops = 1,
	}
	
	if data.width > 0 then
		data.flipState = -1
		return
	end
	
	data.flipState = 1
end

local function flipping(v, data)
	local side = data.flipState
	local width = v.width
	
	if side == 0 then return end
	
	local speed = (speed * side)
	
	data.width = data.width + speed
	if data.width > width or data.width < -width then
		data.width = width * math.sign(data.width)
		data.flipState = 0
	end
end

function npc.onTickEndNPC(v)
	local data = v.data

	if v.despawnTimer <= 0 then
		data.init = nil
		
		return 
	end
	
	if not data.init then
		local settings = data._settings
		
		v.speedX = speed * settings.speedX
		v.speedY = speed * settings.speedY
		
		data.init = true
	end
	
	data.width = data.width or v.width
	data.flipState = data.flipState or 0
	
	for k,bgo in ipairs(BGO.getIntersecting(v.x, v.y, v.x + v.width, v.y + v.height)) do
		local redirector = redirectors[bgo.id]
		
		if redirector then
			doFlip(v, data)
			
			if redirector.speedX then
				v.speedX = speed * redirector.speedX
			else
				v.speedX = 0
			end
			
			if redirector.speedY then
				v.speedY = speed * redirector.speedY
			else
				v.speedY = 0
			end
		end
	end
	
	flipping(v, data)
	v.animationFrame = -99
end

local img

local function drawFlipped(v, data)
	-- Graphics.drawBox{
		-- texture = img,
		
		-- x = v.x + v.width * 0.5,
		-- y = v.y + v.height * 0.5,
		-- width = -data.width,

		-- centered = true,
		-- sceneCoords = true,
	-- }
end

function npc.onCameraDrawNPC(v)
	if v.despawnTimer <= 0 then return end
	
	img = img or Graphics.sprites.npc[id].img

	local data = v.data
	
	if data.width == nil then return end
	
	drawFlipped(v, data)
	
	local absWidth = math.abs(data.width)
	local difference = ((v.width - absWidth) * math.sign(data.width)) * 0.25

	local opacity = (absWidth / v.width) + 0.1
	local col = {opacity, opacity, opacity, 1}
	
	Graphics.drawBox{
		texture = img,
		
		x = v.x + v.width * 0.5,
		y = v.y + v.height * 0.5,
		width = data.width + difference,
		
		color = col,
		centered = true,
		sceneCoords = true,
	}
	
	-- if data.flipState == 0 then return end
	
	-- local absWidth = math.abs(data.width)
	-- local opacity = (v.width - absWidth) / v.width
	
	-- Graphics.drawBox{
		-- texture = img,
		
		-- x = v.x + v.width * 0.5,
		-- y = v.y + v.height * 0.5,
		-- width = data.width,
		
		-- centered = true,
		-- sceneCoords = true,
		
		-- color = Color.black .. opacity * 0.5,
	-- }
end

function npc.onInitAPI()
	npcManager.registerEvent(id, npc, 'onCameraDrawNPC')
	npcManager.registerEvent(id, npc, 'onTickEndNPC')
end

return npc