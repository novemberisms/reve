package reve.collision.shapes;

import reve.math.Rectangle;
import reve.math.Vector;

interface ICollisionShape {
    public final ownerID: CollisionShapeOwnerID;

    public var bounds(get, never): Rectangle;
    public var shapeType(get, never): ShapeType;

    public function collidesWith(other: ICollisionShape): Bool;
    public function getPenetration(other: ICollisionShape): Vector;
    // public function getClosestPointTo(other: ICollisionShape): Vector;
}