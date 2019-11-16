package reve.collision.shapes;

import reve.math.Rectangle;
import reve.math.Vector;

class CollisionRectangle implements CollisionShape {

    public var bounds(get, never): Rectangle;
    public var shapeType(get, never): ShapeType;

    public final rectangle: Rectangle;

    public function new(rect: Rectangle) {
        rectangle = rect;
    }

    public function getPenetration(other: CollisionShape): Vector {
        return Vector.zero;
    }

    private inline function get_bounds(): Rectangle {
        return rectangle.copy;
    }

    private inline function get_shapeType(): ShapeType {
        return ShapeType.rectangle(this);
    }
}