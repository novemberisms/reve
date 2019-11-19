package reve.collision.shapes;

import reve.math.Vector;
import reve.math.Rectangle;

class CollisionPoint implements CollisionShape {

    public final vector: Vector;
    public final ownerID: CollisionShapeOwnerID;

    public var bounds(get, never): Rectangle;
    public var shapeType(get, never): ShapeType;

    public function new(vec: Vector, ?ownerID: CollisionShapeOwnerID) {
        vector = vec;
        this.ownerID = ownerID == null
            ? CollisionShapeOwnerID.iota()
            : ownerID;
    }

    // TODO
    public function getPenetration(other: CollisionShape): Vector {
        return Vector.zero;
    }

    private inline function get_bounds(): Rectangle {
        return new Rectangle(vector, Vector.zero);
    }

    private inline function get_shapeType(): ShapeType {
        return ShapeType.point(this);
    }
}