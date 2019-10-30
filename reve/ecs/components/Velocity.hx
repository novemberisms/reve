package reve.ecs.components;

import reve.math.Vector;

@:build(reve.ecs.ComponentBuilder.build())
class Velocity extends Component {
    
    public var velocity: Vector = Vector.zero;
    public var previousPosition: Vector = Vector.zero;

}