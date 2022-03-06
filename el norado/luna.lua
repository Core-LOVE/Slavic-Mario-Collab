local effect = Particles.Emitter(0, 0, "p_dust.ini");
effect:AttachToCamera(camera);

function onCameraDraw()
    effect:Draw();
end