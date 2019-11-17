package reve.collision.shapes;

import reve.math.Circle;
import reve.math.Rectangle;
import reve.math.Vector;

class CollisionCircle implements CollisionShape {

    public final circle: Circle;
    public final ownerID: CollisionShapeOwnerID;

    public var bounds(get, never): Rectangle;
    public var shapeType(get, never): ShapeType;

    public function new(circ: Circle, ownerID: CollisionShapeOwnerID) {
        circle = circ;
        this.ownerID = ownerID;
    }

    // TODO
    public function getPenetration(other: CollisionShape): Vector {
        return Vector.zero;
    }

    private inline function get_bounds(): Rectangle {
        return circle.bounds;
    }

    private inline function get_shapeType(): ShapeType {
        return ShapeType.circle(this);
    }
}