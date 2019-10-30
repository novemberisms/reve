package reve.ecs.components;

import h2d.Object;
import reve.util.Maybe;
import reve.math.Vector;

@:build(reve.ecs.ComponentBuilder.build())
class Drawable extends Component {

    @:event public var sprite: Maybe<Object> = null;
    @:event public var drawLayer: Int = 0;
    public var drawOffset: Vector = Vector.zero;
    public var drawScale: Vector = Vector.one;

}
