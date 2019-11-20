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
     * @param shape the shape to add
     */
    public function add(shape: ICollisionShape) {
        this.add(shape, shape.bounds);
    }

    public function getCollisions(shape: ICollisionShape): Array<Collision> {
        final collisions = new Array<Collision>();

        for (nearbyShape in this.nearby(shape)) {
            if (!shouldCheckCollision(shape, nearbyShape)) continue;
            
            final penetration = shape.getPenetration(nearbyShape);
            
            if (penetration.lengthSq == 0) continue;
            
            collisions.push({
                shape: shape,
                collidingWith: nearbyShape,
                penetration: penetration,
            });
        }

        return collisions;
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