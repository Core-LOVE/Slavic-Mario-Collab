local death = {}

local deathTexture = Graphics.loadImageResolved('devkit/death.png')

local priority = 5.5
local buffer = Graphics.CaptureBuffer(800,600)
local irisOutShader

function death.onStart()
	Graphics.sprites.effect[3].img = Graphics.sprites.hardcoded['30-1'].img
end

function death.onDraw()
	if player.deathTimer <= 0 then return end
	
	if irisOutShader == nil then
		irisOutShader = Shader()
		irisOutShader:compileFromFile(nil,Misc.resolveFile("warpTransition_irisOut.frag"))	
	end
	
	if player.deathTimer == 1 then
		Defines.earthquake = 8
	end
	
    buffer:captureAt(priority)
	
	local center = vector(player.x+(player.width/2)-camera.x,player.y+(player.height/2)-camera.y)
	local radius = 800 - (player.deathTimer * 6)
	
	if radius < 0 then
		radius = 0
	end
	
    Graphics.drawScreen{texture = buffer,priority = priority,shader = irisOutShader,uniforms = 
		{
			center = center,
			radius = radius,
		}
	}
	
	Graphics.drawScreen{priority = priority, color = Color.black .. (player.deathTimer / 200) * 0.5}
end

function death.onPostPlayerKill()
	if player.character ~= 1 then return end
	
	local e = Effect.spawn(995, player)
	e.speedX = 1.5 * player.direction
end

function death.onInitAPI()
	registerEvent(death, 'onPostPlayerKill')
	registerEvent(death, 'onStart')
	registerEvent(death, 'onDraw')
end

return death