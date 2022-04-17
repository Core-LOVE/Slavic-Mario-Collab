local effect = Particles.Emitter(0, 0, Misc.resolveFile("cyber.ini"))
effect:AttachToCamera(camera);

function onCameraUpdate()
    effect:Draw();
end
