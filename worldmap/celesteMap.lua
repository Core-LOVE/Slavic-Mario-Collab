local celesteMap = {}

local lib3d = require("lib3d")
local tween = require("tween")

celesteMap.light = lib3d.Light({rotation = vector.quaternion(-45, 45, 0)})
celesteMap.obj = nil

celesteMap.levels = {}
celesteMap.level = 0

celesteMap.camPosition = {0, 0, 0, tween = nil}
celesteMap.camRotation = {0, 0, 0, tween = nil}

local cam = lib3d.camera

function celesteMap.load(path, points)
	celesteMap.obj = lib3d.Mesh({
                            meshdata = lib3d.loadMesh(path), 
                            position = vector(400,400,0), 
                            rotation = vector.quatid,
                            scale = 20,
                        })
						
	celesteMap.levels = points
	for k,v in ipairs(celesteMap.levels) do
		lib3d.Mesh({
			meshdata = lib3d.loadMesh(v[1]), 
			position = v.position, 
			rotation = vector.quatid,
			scale = 10
		})
		
		-- celesteMap.levels[k].camRotation = celesteMap.levels[k].camRotation
	end
end

function celesteMap.onCameraDraw()
	local lvl = celesteMap.levels[celesteMap.level + 1]
	
	if celesteMap.camPosition.tween then
		celesteMap.camPosition.tween:update(0.1)
	end
	
	if celesteMap.camRotation.tween then
		celesteMap.camRotation.tween:update(0.1)
	end
	
	if lvl.camRotation then
		local x = celesteMap.camRotation[1]
		local y = celesteMap.camRotation[2]
		local z = celesteMap.camRotation[3]
			
		cam.transform.rotation = vector.quat(x, y, z)
	else
		cam.transform.rotation = vector.quatid
	end
	
    cam.transform.position = vector(camera.x + camera.width*0.5 - Section(0).boundary.left, camera.y + camera.height*0.5 - Section(0).boundary.top, -lib3d.camera.flength)
	
	local x = celesteMap.camPosition[1]
	local y = celesteMap.camPosition[2]
	local z = celesteMap.camPosition[3]	
	
	cam.transform.position = cam.transform.position - vector(x, y, z)

	-- local dir = pos:normalise()
	
	-- cam.transform.position = cam.transform.position + pos
end

function celesteMap.onInputUpdate()
	local keys = player.keys
	
	if keys.right == KEYS_PRESSED then
		celesteMap.level = (celesteMap.level + 1) % #celesteMap.levels
		
		local lvl = celesteMap.levels[celesteMap.level + 1]
	
		celesteMap.camPosition.tween = tween.new(1, celesteMap.camPosition, {lvl.camPosition[1], lvl.camPosition[2], lvl.camPosition[3]}, 'outSine')
		if lvl.camRotation then
			celesteMap.camRotation.tween = tween.new(1, celesteMap.camRotation, {lvl.camRotation[1], lvl.camRotation[2], lvl.camRotation[3]}, 'outSine')
		end	
	end
end

function celesteMap.onInitAPI()
	registerEvent(celesteMap, 'onInputUpdate')
	registerEvent(celesteMap, 'onCameraDraw')
end

return celesteMap