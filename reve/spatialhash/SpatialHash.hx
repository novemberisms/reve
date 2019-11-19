package reve.spatialhash;

import reve.util.Set;
import reve.math.Vector;
import reve.math.Rectangle;
import haxe.ds.Vector as FixedArray;

@:generic
class SpatialHash<T: {}> {

    public var entities(get, never): Iterator<T>;
    public var bounds(get, never): Rectangle;
    public var cellSize(get, never): Vector;

    private final _cellSize: Vector;
    private final _bounds: Rectangle;
    private final _cellsPerEntity = new Map<T, Set<Int>>();
    private final _data: FixedArray<Set<T>>;
    private final _width: Int;
    private final _height: Int;

    public function new(bounds: Rectangle, cellsPerDimension: Vector) {
        _bounds = bounds;
        _cellSize = bounds.size / cellsPerDimension;

        _width = Std.int(cellsPerDimension.x);
        _height = Std.int(cellsPerDimension.y);

        _data = new FixedArray(_width * _height);
        for (i in 0..._data.length) _data[i] = new Set<T>();
    }

    /** Adds an entity into the spatialhash with the given bounds. If the entity has
        already been added, this will update the bounds associated with the entity. **/
    public function add(entity: T, entityBounds: Rectangle) {

        if (has(entity)) remove(entity);
        
        _cellsPerEntity[entity] = new Set<Int>();

        final startCell = toGridCoords(entityBounds.topleft);
        final endCell = toGridCoords(entityBounds.bottomright);

        final startX = Std.int(startCell.x);
        final startY = Std.int(startCell.y);
        final endX = Std.int(endCell.x) + 1;
        final endY = Std.int(endCell.y) + 1;

        for (gy in startY...endY) for (gx in startX...endX) {
            final index = toIndex(gx, gy);
            _cellsPerEntity[entity].add(index);
            _data[index].add(entity);
        }
    }

    public inline function remove(entity: T) {
        for (index in _cellsPerEntity[entity]) _data[index].remove(entity);
        _cellsPerEntity.remove(entity);
    }

    public inline function has(entity: T): Bool {
        return _cellsPerEntity.exists(entity);
    }

    public function nearby(entity: T): Set<T> {
        final result = new Set<T>();
        for (index in _cellsPerEntity[entity]) {
            final cell = _data[index];
            for (other in cell) {
                result.add(other);
            }
        }
        result.remove(entity);
        return result;
    }

    public function query(area: Rectangle): Set<T> {
        final result = new Set<T>();
        
        final startCell = toGridCoords(area.topleft);
        final endCell = toGridCoords(area.bottomright);
        final startX = Std.int(startCell.x);
        final startY = Std.int(startCell.y);
        final endX = Std.int(endCell.x) + 1;
        final endY = Std.int(endCell.y) + 1;

        for (gy in startY...endY) for (gx in startX...endX) {
            final cell = _data[toIndex(gx, gy)];
            for (entity in cell) result.add(entity);
        }

        return result;
    }

    private function toGridCoords(position: Vector): Vector {
        final fromOrigin = position - _bounds.topleft;
        final gridCoords = (fromOrigin / cellSize).floor(); 
        if (gridCoords.x < 0) gridCoords.x = 0;
        if (gridCoords.y < 0) gridCoords.y = 0;
        if (gridCoords.x >= _width) gridCoords.x = _width - 1;
        if (gridCoords.y >= _height) gridCoords.y = _height - 1;
        return gridCoords;
    }

    private inline function toIndex(gx: Int, gy: Int): Int {
        return gy * _width + gx;
    }

    private inline function get_entities(): Iterator<T> {
        return _cellsPerEntity.keys();
    }

    private inline function get_bounds(): Rectangle {
        return _bounds.copy;
    }

    private inline function get_cellSize(): Vector {
        return _cellSize.copy;
    }

}
