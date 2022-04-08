local notAllowed = table.map{6, 7, 9, 10}

local function noBlock(x, y)
	for k,b in Block.iterateIntersecting(x - 1, y - 1, x + 33, y + 33) do
		if notAllowed[b.id] then
			return false
		end	
	end
	
	return true
end

function onStart()
	local cellSize = 32
	
	for k,b in Block.iterate(26) do
		for i = 0, 16 do
			local x = b.x + math.random(b.width - cellSize)
			local y =  b.y + math.random(b.height - cellSize)
			x = math.floor(x / cellSize + .5) * cellSize
			y = math.floor(y / cellSize + .5) * cellSize
			
			if noBlock(x, y) then
				local id = math.random(6, 7)
				
				if math.random() > 0.9 then
					id = math.random(9, 10)
				end
				
				Block.spawn(id, x, y)
			end
		end
	end
	
	for k,b in Block.iterate(1) do
		if math.random() > 0.75 then
			local id = 3
			
			if math.random() > 0.75 then
				id = 11
			end
			
			b:transform(id)
		end
	end
end

function onTick()
	for k,b in Block.iterate{9, 10} do
		if (b.id == 9 and math.random() > 0.95) or (b.id == 10 and math.random() > 0.99) then
			Effect.spawn(78, b.x + math.random(8, 24), b.y + math.random(8, 24))
		end
	end
end

local lights = Particles.Emitter(0, 0, "p_snowy.ini")
lights:AttachToCamera(camera)

function onCameraDraw()
	lights:Draw()
end

