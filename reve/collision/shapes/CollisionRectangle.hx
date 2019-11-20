package reve.collision.shapes;

import reve.math.Rectangle;
import reve.math.Vector;

class CollisionRectangle implements ICollisionShape {

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

    // TODO
    public function getPenetration(other: ICollisionShape): Vector {
        return Vector.zero;
    }

    private inline function get_bounds(): Rectangle {
        return rectangle.copy;
    }

    private inline function get_shapeType(): ShapeType {
        return ShapeType.rectangle(this);
    }
}