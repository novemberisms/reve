package reve.collision;

import reve.math.Vector;
import reve.spatialhash.SpatialHash;
import reve.math.Rectangle;
import reve.collision.shapes.CollisionShape;

@:forward(remove, has)
abstract CollisionWorld(SpatialHash<CollisionShape>) {

    public function new(bounds: Rectangle, averageCellSize: Float = 100) {
        final cellsPerDimension = calculateCellsPerDimension(bounds, averageCellSize);
        this = new SpatialHash(bounds, cellsPerDimension);
    }

    /**
     * Adds a shape to the collision world. If the shape has already been added, it will update the location of the shape.
     * @param shape the shape to add
     */
    public function add(shape: CollisionShape) {
        this.add(shape, shape.bounds);
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