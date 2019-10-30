package reve.ecs.systems;

import reve.ecs.SystemPhase;
import haxe.ds.GenericStack;
import reve.input.Input;
import reve.console.DebugConsole;

using reve.ecs.components.Controller;
using reve.ecs.components.PlayerControllable;
using Lambda;

class PlayerInputSystem extends System {

    private final _input: Input;
    private final _controlStack = new GenericStack<Entity>();

    private inline override function getOrderingLabels(): Array<String> {
        return [SystemPhase.input, InputPhase.playerInput];
    }

    private inline override function getRequiredComponents() {
        return [ Controller.id, PlayerControllable.id ];
    }

    public function new(world: World, input: Input) {
        super(world);
        _input = input;
    }

    private override function onEntityAdded(e: Entity) {
        e.getRequestsControlEvent().add(function (v) {
            if (v) {
                if (!_controlStack.has(e)) _controlStack.add(e);
            } else {
                _controlStack.remove(e);
            }
        });
    }

    public override function update(dt: Float) {
        
        if (_controlStack.first() == null) return;

        if (DebugConsole.instance.focused) return;

        final controller = _controlStack.first().getController();

        for (action in controller.actionsListenedTo) {
            if (_input.isActionDown(action)) controller.queueAction(action);
        }
    }
}