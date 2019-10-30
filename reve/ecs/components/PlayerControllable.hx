package reve.ecs.components;

@:build(reve.ecs.ComponentBuilder.build())
class PlayerControllable extends Component {

    @:event public var requestsControl: Bool = false;
 
}