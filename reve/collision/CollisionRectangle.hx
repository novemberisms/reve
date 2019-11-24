package reve.collision;

import reve.math.Rectangle;
import reve.math.Vector;

class CollisionRectangle implements ICollisionShape {

    public final rectangle: Rectangle;
	public final ownerID: CollisionShapeOwnerID;

	public var collisionLayers = 1;
	public var collisionMask = 1;

    public var bounds(get, never): Rectangle;
    public var shapeType(get, never): ShapeType;

    public function new(rect: Rectangle, ?ownerID: CollisionShapeOwnerID) {
        rectangle = rect;
        this.ownerID = ownerID == null
            ? CollisionShapeOwnerID.iota()
            : ownerID;
    }

    public static inline function from(
        x: Float, 
        y: Float, 
        width: Float, 
        height: Float, 
        ?ownerID: CollisionShapeOwnerID
    ): CollisionRectangle {
        final rect = Rectangle.from(x, y, width, height);
        return new CollisionRectangle(rect, ownerID);
    }

    public static inline function withCenter(center: Vector, size: Vector, ?ownerID: CollisionShapeOwnerID): CollisionRectangle {
        final rect = Rectangle.withCenter(center, size);
        return new CollisionRectangle(rect, ownerID);
    }

    public inline function getPenetration(other: ICollisionShape): Vector {
        return PenetrationAlgorithms.getPenetration(this, other);
    }

    public function collidesWith(other: ICollisionShape): Bool {
        switch (other.shapeType) {
            case ShapeType.point(p):
                return rectangle.contains(p.vector);
            case ShapeType.rectangle(r):
                return rectangle.intersects(r.rectangle);
            case ShapeType.circle(c):
                return c.circle.collideBounds(rectangle);
        }
    }

    private inline function get_bounds(): Rectangle {
        return rectangle.copy;
    }

    private inline function get_shapeType(): ShapeType {
        return ShapeType.rectangle(this);
    }
}