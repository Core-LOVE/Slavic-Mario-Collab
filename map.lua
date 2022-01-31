local lib3d = require("lib3d")

local m = lib3d.loadMesh('world1.obj', {
	scale = 128,
})

local l = lib3d.Light{brightness=5, rotation=vector.quat(vector.forward3, vector(0,0.2,1))}

function onDraw()
    lib3d.camera.transform.position = vector(camera.x + 400, camera.y + 300, -lib3d.camera.flength)
	lib3d.onCameraDraw(1)
end