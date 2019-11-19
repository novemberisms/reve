package reve.collision.shapes;

import reve.math.Rectangle;
import reve.math.Vector;

class CollisionRectangle implements CollisionShape {

    public final rectangle: Rectangle;
    public final ownerID: CollisionShapeOwnerID;

    public var bounds(get, never): Rectangle;
    public var shapeType(get, never): ShapeType;

    public function new(rect: Rectangle, ?ownerID: CollisionShapeOwnerID) {
        rectangle = rect;
        this.ownerID = ownerID == null
            ? CollisionShapeOwnerID.iota()
            : ownerID;
    }

    // TODO
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