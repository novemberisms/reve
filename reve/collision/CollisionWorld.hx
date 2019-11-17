package reve.collision;

import reve.math.Vector;
import reve.spatialhash.SpatialHash;
import reve.math.Rectangle;
import reve.collision.shapes.CollisionShape;

class CollisionWorld {

    private final _spatialHash: SpatialHash<CollisionShape>;
    private var _collisionsThisFrame = new Array<Collision>();

    public function new(bounds: Rectangle, averageCellSize: Float = 100) {
        final cellsPerDimension = calculateCellsPerDimension(bounds, averageCellSize);
        _spatialHash = new SpatialHash(bounds, cellsPerDimension);
    }

    public function update() {
        // flush the collisions from the previous frame
        _collisionsThisFrame = new Array<Collision>();

        

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