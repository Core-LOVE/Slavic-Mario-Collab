local Actor = {}
Actor.npcID = 998

local function defineTrue(args, name) if args[name] == nil then args[name] = true end end

function Actor.spawn(args)
	local args = (args or {})
	assert((args.x ~= nil and args.y ~= nil), 'No position set for actor!')
	
	defineTrue(args, 'friendly')

	local actor = {}
	
	actor.texture = args.texture
	
	actor.xframes = args.xframes
	actor.yframes = args.yframes or args.frames
	actor.xframe = args.xframe
	actor.yframe = args.yframe or args.frame
	
	actor.npc = NPC.spawn(Actor.npcID, args.x, args.y)
	local npc = actor.npc
	
	npc.friendly = args.friendly
	
	setmetatable(actor, {__index = Actor})
	Actor[#Actor + 1] = actor
	return actor
end

function Actor:render(args)
	local v = self
	local npc = v.npc
	local args = args or {}
	
	local texture = args.texture or self.texture
	
	if texture == nil then return end
	
	local xframes = args.xframes or self.xframes or 1
	local yframes = args.yframes or self.yframes or 1
	local xframe = args.xframe or self.xframe or 0
	local yframe = args.yframe or self.yframe or 0
	
	local sW = texture.width / xframes
	local sH = texture.height / yframes
	
	local priority = args.priority or self.priority or -75
	
	Graphics.drawBox{
		texture = texture,
		
		x = npc.x,
		y = npc.y,
		
		sourceWidth = sW,
		sourceHeight = sH,
		sourceX = sW * xframe,
		sourceY = sH * yframe,
		
		sceneCoords = true,
		priority = priority,
	}
end

function Actor.onDraw()
	for k,v in ipairs(Actor) do
		v:render()
	end
end

function Actor.onInitAPI()
	local function registerEvent(...)
		return _G.registerEvent(Actor, ...)
	end
	
	registerEvent('onDraw')
end

return Actor