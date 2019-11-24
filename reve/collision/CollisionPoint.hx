package reve.collision;

import reve.math.Vector;
import reve.math.Rectangle;

class CollisionPoint implements ICollisionShape {

    public final vector: Vector;
	public final ownerID: CollisionShapeOwnerID;

	public var collisionLayers = 1;
	public var collisionMask = 1;

    public var bounds(get, never): Rectangle;
    public var shapeType(get, never): ShapeType;

    public function new(vec: Vector, ?ownerID: CollisionShapeOwnerID) {
        vector = vec;
        this.ownerID = ownerID == null
            ? CollisionShapeOwnerID.iota()
            : ownerID;
    }

    public static inline function from(x: Float, y: Float, ?ownerID: CollisionShapeOwnerID): CollisionPoint {
        return new CollisionPoint(new Vector(x, y), ownerID);
    }

    public inline function getPenetration(other: ICollisionShape): Vector {
        return PenetrationAlgorithms.getPenetration(this, other);
    }

    public function collidesWith(other: ICollisionShape): Bool {
        switch (other.shapeType) {
            case point(p):
                return vector == p.vector;
            case rectangle(r):
                return r.rectangle.contains(vector);
            case circle(c):
                return c.circle.contains(vector);
        }
    }

    private inline function get_bounds(): Rectangle {
        return new Rectangle(vector, Vector.zero);
    }

    private inline function get_shapeType(): ShapeType {
        return ShapeType.point(this);
    }
}