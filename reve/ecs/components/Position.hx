package reve.ecs.components;

import reve.math.Vector;

@:build(reve.ecs.ComponentBuilder.build())
class Position extends Component {

    public var position: Vector = Vector.zero;

}