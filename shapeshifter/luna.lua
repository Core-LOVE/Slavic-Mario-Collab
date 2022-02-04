local effect = Particles.Emitter(0, 0, "p_fallingleaf.ini");
effect:AttachToCamera(camera);

function onCameraDraw()
    effect:Draw();
end

function onOptimize(state)
	effect.enabled = not effect.enabled
	effect:KillParticles()
end