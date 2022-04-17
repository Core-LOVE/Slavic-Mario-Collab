function onStart()
	local a = Actor.spawn{
		texture = Graphics.loadImageResolved 'luigi.png',
		
		x = player.x,
		y = player.y,
		
		xframes = 10,
		yframes = 10,
		
		frame = 6,
	}
end