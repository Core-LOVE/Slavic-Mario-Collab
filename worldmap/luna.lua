local celesteMap = require 'celesteMap'

celesteMap.load('world.obj',
	{
		{'level1.obj', position = vector(400,100,0), camPosition = vector(200, 100, 0), camRotation = {0, 90, 0}},
	}
)