package reve.ecs.components;

import reve.input.ActionController;

@:build(reve.ecs.ComponentBuilder.build())
class Controller extends Component {

    public var controller: ActionController<Entity> = new ActionController();

}