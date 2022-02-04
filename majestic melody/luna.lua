function onOptimize()
	for k,v in ipairs(Section.get()) do
		if v.backgroundID == 58 then
			local layer = v.background:get("music")
			layer.hidden = not layer.hidden
			
			local layer = v.background:get("clouds")
			layer.hidden = not layer.hidden
		end
	end
end