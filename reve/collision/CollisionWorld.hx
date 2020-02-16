package reve.collision;

import reve.math.Vector;
import reve.spatialhash.SpatialHash;
import reve.math.Rectangle;
import reve.collision.ICollisionShape;

@:forward(remove, has, query)
abstract CollisionWorld(SpatialHash<ICollisionShape>) {

    public function new(bounds: Rectangle, averageCellSize: Float = 100) {
        final cellsPerDimension = calculateCellsPerDimension(bounds, averageCellSize);
        this = new SpatialHash(bounds, cellsPerDimension);
    }

    /**
     * Adds a shape to the collision world. If the shape has already been added, it will update the location of the shape.
     */
    public inline function add(shape: ICollisionShape) {
        this.add(shape, shape.bounds);
    }

    public inline function remove(shape: ICollisionShape) {
        this.remove(shape);
    }

    public function getCollidingShapes(shape: ICollisionShape): Array<ICollisionShape> {
        final collidingShapes = new Array<ICollisionShape>();

        for (nearbyShape in this.nearby(shape)) {
            if (!shouldCheckCollision(shape, nearbyShape)) continue;
            if (!shape.collidesWith(nearbyShape)) continue;
            collidingShapes.push(nearbyShape);
        }

        return collidingShapes;
    }

    private static function shouldCheckCollision(shapeA: ICollisionShape, shapeB: ICollisionShape): Bool {
        // if both shapes belong to the same owner, then do not check collision
        if (shapeA.ownerID == shapeB.ownerID) return false;
        
        if (!shapeB.collisionLayers.testAny(shapeA.collisionMask)) return false; 

        return true;
    }

    private static function calculateCellsPerDimension(
        bounds: Rectangle, 
        averageCellSize: Float
    ): Vector {
        final cellsHorizontal = Math.ceil(bounds.width / averageCellSize);
        final cellsVertical = Math.ceil(bounds.height / averageCellSize);
        return new Vector(cellsHorizontal, cellsVertical);
    }
}