function onStart()
	for k,b in Block.iterate(1017) do
		local t = Block.getIntersecting(b.x - 1, b.y - 1, b.x + b.width + 1, b.y + b.height + 1)
		local place = true
		
		for k,v in ipairs(t) do
			if v.id ~= 1017 then
				place = false
			end
		end
		
		if math.random() > 0.90 and place then
			local id = 16
			
			if math.random() > 0.5 then
				id = 19
			end
			
			b.id = id
		end
	end
end

local effect = Particles.Emitter(0, 0, "p_fallingleaf.ini");
effect:AttachToCamera(camera);

function onCameraDraw()
    effect:Draw();
end