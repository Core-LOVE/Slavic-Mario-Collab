local celesteMap = {}

local textplus = require("textplus")
local lib3d = require("lib3d")

celesteMap.worlds = {}

SaveData.celesteMap = SaveData.celesteMap or {}

celesteMap.saveData = SaveData.celesteMap
celesteMap.saveData.openedWorlds = celesteMap.saveData.openedWorlds or 1
celesteMap.saveData.openedLevels = celesteMap.saveData.openedLevels or {}
celesteMap.saveData.maxLevels = celesteMap.saveData.maxLevels or {}

celesteMap.saveData = SaveData.celesteMap

celesteMap.world = (celesteMap.saveData.world or 0)

celesteMap.SFX = {
	select = 1,
	choose = 2,
}

function celesteMap.playSFX(name)
	if celesteMap.SFX[name] ~= nil then
		SFX.play(celesteMap.SFX[name])
	end
end

celesteMap.light = lib3d.Light({rotation = vector.quaternion(-45, 45, 0)})

local levelName = Level.filename()
local font =  textplus.loadFont("font.ini")

function celesteMap.progress()
	local currentWorld = celesteMap.saveData.openedWorlds - 1
	-- local maxWorlds = #celesteMap.saveData.openedLevels

	local currentLevelCount = celesteMap.saveData.openedLevels
	local maxLevels = celesteMap.saveData.maxLevels[currentWorld + 1]
	
	currentLevelCount[currentWorld + 1] = (currentLevelCount[currentWorld + 1] + 1)
	if currentLevelCount[currentWorld + 1] > maxLevels then
		-- open new world
		local newCurrentWorld = (celesteMap.saveData.openedWorlds + 1)
		
		celesteMap.saveData.openedWorlds = (celesteMap.saveData.openedWorlds + 1)
		if celesteMap.saveData.openedWorlds >= #currentLevelCount then
			celesteMap.saveData.openedWorlds = (#currentLevelCount - 1)
		end
		
		-- level
		currentLevelCount[currentWorld + 1] = (maxLevels)
	end
end

function celesteMap.addWorld(args)
	local args = args or {}
	
	args.idx = (#celesteMap.worlds + 1)
	
	if args.iconName then
		args.icon = Graphics.loadImageResolved(args.iconName)
	end
	
	if args.bgName then
		args.bg = Graphics.loadImageResolved(args.bgName)
	end
	
	args.currentLevel = (args.currentLevel or 0)
	args.levels = args.levels or {}
	
	for count, level in ipairs(args.levels) do
		level.icon = Graphics.loadImageResolved(level.iconName or "defaultLevel.png")
	end
	
	args.mesh = args.mesh or {}
	
	for k, mesh in ipairs(args.mesh) do
		local material 
		
		if mesh.material then
			material = lib3d.Material(nil, mesh.material)
		end
		
		args.mesh[k] = lib3d.Mesh({
							material = material,
                            meshdata = lib3d.loadMesh(mesh.path), 
                            position = vector(400,args.mesh.y or 400,0), 
                            rotation = vector.quatid,
                            scale = 20
                        })
	end
	
	celesteMap.saveData.openedLevels[args.idx] = (celesteMap.saveData.openedLevels[args.idx] or 1)
	celesteMap.saveData.maxLevels[args.idx] = #args.levels
	
	celesteMap.worlds[#celesteMap.worlds + 1] = args
	return args
end

function celesteMap.onCameraDraw()
	local currentWorld = (celesteMap.world + 1)
	local worlds = (celesteMap.worlds)
	
	if #worlds == 0 then return end
	
	local world = worlds[currentWorld]
	
	local levels = world.levels
	local currentLevel = (world.currentLevel + 1)
	local currentLevelObj = levels[currentLevel]
	
	-- hud
	Graphics.drawBox{x = 0, y = 0, width = 800, height = 96, color = Color.black .. 0.5}
	
	if world.icon then
		Graphics.drawBox{texture = world.icon, x = 32, y = 16}
	end
	
	if world.name then
		textplus.print{
			text = 'World ' .. currentWorld .. ' - ' .. world.name,
			
			x = 128,
			y = 24,
			
			font = font,
			xscale = 2,
			yscale = 2,
		}
	end
	
	if currentLevelObj.name then
		textplus.print{
			text = currentLevelObj.name,
			
			x = 128,
			y = 52,
				
			font = font,
			xscale = 2,
			yscale = 2,
		}
	end
	
	if currentLevelObj.author then
		local str = 'by '
		
		textplus.print{
			text = str .. currentLevelObj.author,
			
			x = 128,
			y = 72,
			
			color = Color.yellow,
			
			font = font,
			xscale = 1.5,
			yscale = 1.5,
		}
	end
	
	local openedLevels = celesteMap.saveData.openedLevels[world.idx]
	local dx = 0
	
	local x = 400
	local sx = (44 * #levels) * 0.5
	x = x - sx
	
	for count, level in ipairs(levels) do
		if currentLevel == count then
			Graphics.drawBox{
				texture = Graphics.sprites.hardcoded['50-12'].img,
				
				x = (x + dx) + 8,
				y = 136,
			}
		end
		
		Graphics.drawBox{x = (x + dx) - 4, y = 96, width = 40, height = 36, color = Color.black .. 0.5}
		
		local iconCol
		
		if openedLevels < count then
			iconCol = {0.5, 0.5, 0.5, 0.5}
		end
		
		Graphics.drawBox{
			texture = level.icon,
			
			x = x + dx,
			y = 96,
			
			color = iconCol,
		}
	
		dx = dx + 48
	end
	
	-- lib3d - camera
    lib3d.camera.transform.position = vector(camera.x + camera.width*0.5 - Section(0).boundary.left, camera.y + camera.height*0.5 - Section(0).boundary.top, -lib3d.camera.flength)	

	-- other...
	if world.bg then
		Graphics.drawBox{
			texture = world.bg,
			
			x = 0,
			y = 0,

			priority = -100,
		}
	end
	
	if world.bgColor then
		Graphics.drawScreen{
			color = world.bgColor,
			priority = -101,
		}
	end
end

local function playMusic(oldWorld)
	local world = celesteMap.worlds[celesteMap.world + 1]
	
	if oldWorld and world.musicName and oldWorld.musicName then
		if world.musicName == oldWorld.musicName then
			return
		end
	end
	
	Audio.SeizeStream(player.section)
	Audio.MusicStop()
	
	if world.musicName then
		Audio.MusicOpen(world.musicName)
		Audio.MusicPlay()
	end
end

local defaultAmbient = lib3d.ambientLight

local function toggleMeshes(world)
	if world.ambient then
		lib3d.ambientLight = world.ambient
	else
		lib3d.ambientLight = defaultAmbient
	end
	
	for k,mesh in ipairs(world.mesh) do
		mesh.active = (not mesh.active)
	end
end

function celesteMap.onInputUpdate()
	for k in pairs(player.keys) do
		player.keys[k] = false
	end
	
	local rawKeys = player.rawKeys
	
	local left = rawKeys.left
	local right = rawKeys.right
	local jump = rawKeys.jump
	
	local worldCount = celesteMap.saveData.openedWorlds
	
	if worldCount > #celesteMap.worlds then
		worldCount = #celesteMap.worlds
	end
	
	if left == KEYS_PRESSED then
		celesteMap.playSFX('select')
		
		local world = celesteMap.worlds[celesteMap.world + 1]
		
		world.currentLevel = (world.currentLevel - 1)
		if world.currentLevel < 0 then
			world.currentLevel = 0
			
			toggleMeshes(world)		
			celesteMap.world = (celesteMap.world - 1)
			if celesteMap.world < 0 then
				celesteMap.world = (worldCount - 1)
			end
			
			local nextWorld = celesteMap.worlds[celesteMap.world + 1]
			nextWorld.currentLevel = (celesteMap.saveData.openedLevels[nextWorld.idx] - 1)
				
			toggleMeshes(celesteMap.worlds[celesteMap.world + 1])
		
			playMusic(world)
		end
	end
	
	if right == KEYS_PRESSED then
		celesteMap.playSFX('select')
		
		local world = celesteMap.worlds[celesteMap.world + 1]
		local openedLevels = celesteMap.saveData.openedLevels[world.idx]
		
		world.currentLevel = (world.currentLevel + 1)
		
		if world.currentLevel >= openedLevels then
			world.currentLevel = 0
			
			toggleMeshes(world)
			celesteMap.world = (celesteMap.world + 1) % worldCount
			toggleMeshes(celesteMap.worlds[celesteMap.world + 1])
		
			playMusic(world)
		end
	end
	
	if jump == KEYS_PRESSED then
		celesteMap.playSFX('choose')
			
		local world = celesteMap.worlds[celesteMap.world + 1]
		local level = world.levels[world.currentLevel + 1]
		
		if level.fileName then
			Level.load(level.fileName)
		end
	end
end

function celesteMap.onStart()
	player.forcedState = 8
	
	for k,world in ipairs(celesteMap.worlds) do
		if k ~= (celesteMap.world + 1) then
			for _, mesh in ipairs(world.mesh) do
				mesh.active = false
			end
		end
	end
	
	playMusic()
end

function celesteMap.onTick()
	-- rotate world map
	local world = celesteMap.worlds[celesteMap.world + 1]
	
	for k,mesh in ipairs(world.mesh) do
		mesh.transform:rotate(0, 0.5, 0)
	end
	
	celesteMap.saveData.world = celesteMap.world
end

function celesteMap.onInitAPI()
	registerEvent(celesteMap, 'onCameraDraw')
	registerEvent(celesteMap, 'onInputUpdate')
	registerEvent(celesteMap, 'onStart')
	registerEvent(celesteMap, 'onTick')
end

return celesteMap