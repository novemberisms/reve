package reve.level;

import reve.math.Vector;

enum TileSpawnCommand {
    allow;
    prevent;
    replace(tile: MapTile);
    moveTo(gridposition: Vector);
    replaceAt(tile: MapTile, gridposition: Vector);
}

enum ObjectSpawnCommand {
    allow;
    prevent;
    replace(object: MapObject);
}

class Factory {

    private final _tileRules: Map<Int, Bool> = [];

    public function new() {}

    public function addRule() {

    }

    @virtual public function onTile(
        tile: MapTile,
        layer: Layer, 
        level: Level,
        // NOTE that different tiles may have different tilesizes, which is why we can't get rid of this
        position: Vector, 
        gridPosition: Vector 
    ): TileSpawnCommand {
        
        return allow;
    }

    @virtual public function onObject(
        object: MapObject,
        layer: Layer,
        level: Level
    ): ObjectSpawnCommand {
        return allow;
    }

}
