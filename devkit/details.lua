local Details = {}
Details.name = nil

function Details.add(name, f)
	local oldF = Details[name]

	if oldF then
		Details[name] = function()
			oldF()
			f()
		end	
		
		return
	end
	
	Details[name] = f
end

function Details.set(name)
	-- if Details[name] then
		-- Details[name]()
	-- end
end

Details.add('desert', function()
	local t = {}

	function t.onTickEnd()
		local p = player
		local spawn = false
		
        if p:isGroundTouching() then
            for k,v in Block.iterateIntersecting(p.x, p.y + p.height, p.x + p.width, p.y + p.height + 1) do
                if v.y >= p.y + p.height then
					spawn = true
					break
                end
            end
        end
		
		if p.speedX == 0 or not spawn then return end
		
		Effect.spawn(12, p.x, p.y)
	end
	
	registerEvent(t, 'onTickEnd')
end)

return Details