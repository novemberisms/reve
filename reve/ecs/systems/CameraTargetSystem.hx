package reve.ecs.systems;

import reve.ecs.SystemPhase.DisplayPhase;
import reve.camera.PointOfInterest;
import reve.camera.CameraDirector;
import reve.ecs.System;

using reve.ecs.components.Position;
using reve.ecs.components.CameraTarget;

class CameraTargetSystem extends System {

    private final _director: CameraDirector;

    public function new(world: World, cameraDirector: CameraDirector) {
        super(world);
        _director = cameraDirector;
    }

    private override function getRequiredComponents() return [
        Position.id,
        CameraTarget.id,
    ];

    private override function getOrderingLabels(): Array<String> return [
        SystemPhase.display,
        DisplayPhase.camera,
    ];

    private override function getOrderingConstraints() return [
        after(SystemPhase.physics),
    ];

    private override function onEntityAdded(e: Entity) {
        e.getRequestsFocusEvent().add(v -> {
            if (v == true) {
                onEntityRequestsFocus(e); 
            } else {
                onEntityRequestsBlur(e);
            } 
        });
    }

    private override function onEntityRemoved(e: Entity) {
        _director.popTarget(e.getCameraTarget());
    }

    public override function update(dt: Float) {
        // update camera targets to follow position
        for (e in getEntities()) {
            e.getCameraTarget().position = e.getPosition().copy;
        }

        _director.update(dt);
    }

    public inline function addPointOfInterest(p: PointOfInterest) {
        _director.addPointOfInterest(p);
    }

    public inline function removePointOfInterest(p: PointOfInterest) {
        _director.removePointOfInterest(p);
    }

    public inline function getDirector(): CameraDirector {
        return _director;
    }

    private inline function onEntityRequestsFocus(e: Entity) {
        _director.pushTarget(e.getCameraTarget());
    }

    private inline function onEntityRequestsBlur(e: Entity) {
        _director.popTarget(e.getCameraTarget());
    }
}