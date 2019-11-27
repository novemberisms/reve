package reve.collision;

import reve.math.Rectangle;
import reve.math.Polygon;
import reve.math.Vector;

class CollisionPolygon implements ICollisionShape {

    public final polygon: Polygon;
    public final ownerID: CollisionShapeOwnerID;

    public var collisionLayers = 0x1;
    public var collisionMask = 0x1;

    public var bounds(get, never): Rectangle;
    public var shapeType(get, never): ShapeType;

    public function new(polygon: Polygon, ?ownerID: CollisionShapeOwnerID) {
        this.polygon = polygon;
        this.ownerID = ownerID == null
            ? CollisionShapeOwnerID.iota()
            : ownerID;
    }

    public static inline function from(
        points: Array<Vector>,
        ?ownerID: CollisionShapeOwnerID
    ): CollisionPolygon {
        final polygon = new Polygon(points);
        return new CollisionPolygon(polygon, ownerID);
    }

    public inline function getPenetration(other: ICollisionShape): Vector {
        return PenetrationAlgorithms.getPenetration(this, other);
    }

    public function collidesWith(other: ICollisionShape): Bool {
        return false;
    }

    private inline function get_bounds(): Rectangle {
        return polygon.bounds;
    }

    private inline function get_shapeType(): ShapeType {
        return null;
    }
}