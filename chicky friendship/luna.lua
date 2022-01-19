require 'rooms'

function onStart()
	for k,v in Block.iterate(348) do
		if math.random() > 0.95 then
			v:transform(1)
		end
	end
end