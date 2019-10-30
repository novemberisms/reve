package reve.ecs.systems;

import reve.ecs.System;
import reve.ecs.SystemPhase;

using reve.ecs.components.Controller;

class ControllerSystem extends System {

    private inline override function getOrderingLabels(): Array<String> {
        return [ SystemPhase.control, ControlPhase.dispatchActions ];
    }

    private inline override function getOrderingConstraints() return [
        after(SystemPhase.input), // input phases are what queue up the actions
        before(SystemPhase.physics), // because control phases modify physical values 
    ];

    private inline override function getRequiredComponents() {
        return [Controller.id];
    }

    public override function update(dt: Float) {
        final entities = getEntities();

        for (e in entities) {
            e.getController().update(e);
        }
    } 
}