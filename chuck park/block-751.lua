local block = {}

local blockManager = require 'blockManager'
local id = BLOCK_ID

blockManager.setBlockSettings{
	id = id,
	semisolid = true,
}

local function transform(v)
	Routine.waitFrames(16)
	v:transform(id + 1)
end

function block.onCollideBlock(v, n)
	if type(n) ~= "Player" then return end

	local data = v.data
	
	if n:isOnGround() and not data.touched then
		data.touched = true
		
		Routine.run(transform, v)
		SFX.play 'wood.ogg'
	end
end

function block.onInitAPI()
	blockManager.registerEvent(id, block, 'onCollideBlock')
end

return block