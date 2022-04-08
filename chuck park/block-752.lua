local block = {}

local blockManager = require 'blockManager'
local id = BLOCK_ID

blockManager.setBlockSettings{
	id = id,
	frames=4,
	passthrough=true,
}

function block.onTickEndBlock(v)
	local data = v.data
	
	if data.touched then
		data.touched = nil
	end
	
	data.timer = data.timer or 0
	data.timer = data.timer + 1
	if data.timer > 64 then
		data.timer = nil
		v:transform(751)
		return
	end
end

function block.onInitAPI()
	blockManager.registerEvent(id, block, 'onTickEndBlock')
end

return block