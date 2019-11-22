package reve.collision;

import reve.math.Vector;
import reve.spatialhash.SpatialHash;
import reve.math.Rectangle;
import reve.collision.shapes.ICollisionShape;

@:forward(remove, has)
abstract CollisionWorld(SpatialHash<ICollisionShape>) {

    public function new(bounds: Rectangle, averageCellSize: Float = 100) {
        final cellsPerDimension = calculateCellsPerDimension(bounds, averageCellSize);
        this = new SpatialHash(bounds, cellsPerDimension);
    }

    /**
     * Adds a shape to the collision world. If the shape has already been added, it will update the location of the shape.
     */
    public function add(shape: ICollisionShape) {
        this.add(shape, shape.bounds);
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
        if (shapeA.ownerID == shapeB.ownerID) return false;
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