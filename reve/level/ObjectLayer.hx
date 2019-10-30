package reve.level;

import h2d.Object;
import reve.level.Types;

/** Extends Layer **/
class ObjectLayer extends Layer {

    private final _objects: Array<MapObject> = [];

    public function new(index: Int, layerData: TiledLayer, level: Level) {
        kind = object(this);

        final tiledObjects = layerData.objects.sure();

        for (id in 0...tiledObjects.length) {
            final objectdata = tiledObjects[id];
            _objects.push(MapObject.create(id, objectdata, level.tilesetService));
        }
        
        super(index, layerData, level);
    }
    
    //=========================================================================
    // PUBLIC FUNCTIONS
    //=========================================================================


    //=========================================================================
    // VIRTUAL FUNCTIONS
    //=========================================================================

    private override function createSprite(): Object {
        final container = new Object();

        for (unknownObj in _objects) {
            createObject(unknownObj);
        }

        embedTilegroups(container);
        embedAnimations(container);

        return container;
    }

    private function createObject(unknownObj: MapObject) {
        switch (unknownObj.kind) {
        case tile(obj):
            final spawnCommand = _level.factory.onObject(obj, this, _level);
            switch (spawnCommand) {
            case allow:
                final maptile = obj.maptile;
                final tilegroup = getTileGroupFor(maptile.tileset);
                tilegroup.addTransform(obj.position.x, obj.position.y, obj.scale.x, obj.scale.y, obj.rotation, maptile.tile);
            case prevent:
                // do nothing
            case replace(newobj):
                createObject(newobj);
            }
        case rectangle(obj):
        case point(obj):
        case ellipse(obj):
        case polygon(obj):
        }
    }

    //=========================================================================
    // HELPER FUNCTIONS
    //=========================================================================
    
}
