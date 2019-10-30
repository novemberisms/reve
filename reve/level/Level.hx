package reve.level;

import reve.math.Vector;
import haxe.io.Path;
import reve.util.Maybe;
import reve.level.ObjectLayer;
import reve.level.TileLayer;
import reve.level.Types;
import hxd.res.Resource;
import reve.util.JsonReader;

class Level {

    public final width: Int;
    public final height: Int; 
    public final tileWidth: Int;
    public final tileHeight: Int;
    public final properties: Properties;
    public final tilesetService: TilesetService;
    public final factory: Factory;

    public var tilesize(get, never): Vector;
    public var pixelsize(get, never): Vector;
    public var gridsize(get, never): Vector;

    public var layers(get, never): Array<Layer>;

    private final _layerManager: LayerManager;

    public function new(mapSource: Resource, factory: Factory) {

        final mapData: TiledMap = JsonReader.load(mapSource);
        // required since tileset references are stored as relative paths to this
        final path = new Path(mapSource.entry.path);

        width = mapData.width;
        height = mapData.height;
        tileWidth = mapData.tilewidth;
        tileHeight = mapData.tileheight;
        properties = mapData.properties;
        tilesetService = new TilesetService(mapData.tilesets, path);
        this.factory = factory;
        
        _layerManager = new LayerManager(mapData.layers, this);
    }

    public inline function update(dt: Float) {
        _layerManager.update(dt);
    }

    public function getTiles(gridPosition: Vector): Array<MapTile> {
        final result: Array<MapTile> = [];
        for (tilelayer in _layerManager.getTileLayers()) {
            final tile = tilelayer.getTile(gridPosition);
            if (tile.exists()) result.push(tile.sure());
        }
        return result;
    }

    public inline function getTilesAt(position: Vector): Array<MapTile> {
        final gridPosition = getGridPosition(position);
        return getTiles(gridPosition);
    }

    public inline function getLayer(name: String): Maybe<Layer> {
        return _layerManager.getByName(name);
    }
    
    /** Returns a grid position in the level
    
        Note that this assumes `position`'s origin is at the top-left of the level. 
        and that **there is no scaling adjustment** **/
    public inline function getGridPosition(position: Vector): Vector {
        return new Vector(
            Math.floor(position.x / tileWidth),
            Math.floor(position.y / tileHeight)
        );
    }

    /** Returns a position in pixels of the top-left corner of the
        cell that corresponds to the given grid position
        
        Note that this world position's origin will be the top-left of the level
        and that **there is no scaling adjustment**  **/
    public inline function getWorldPosition(gridPosition: Vector): Vector {
        return gridPosition * tilesize;
    }

    private inline function get_layers(): Array<Layer> {
        return _layerManager.layers;
    }

    private inline function get_tilesize(): Vector {
        return new Vector(tileWidth, tileHeight);
    }

    private inline function get_gridsize(): Vector {
        return new Vector(width, height);
    }

    private inline function get_pixelsize(): Vector {
        return tilesize * gridsize;
    }

}

//===============================================================================================

/** This guy takes care of the layers in a level **/
private class LayerManager {

    public final layers: Array<Layer> = [];

    public function new(layersData: Array<TiledLayer>, level: Level) {
        var layerIndex = 0;
        for (layerData in layersData) {
            // there are two supported types of layers: Tile Layers and Objects Layers.
            if (layerData.type == LayerType.tilelayer) {
                layers.push(new TileLayer(layerIndex, layerData, level));
            } else if (layerData.type == LayerType.objectgroup) {
                layers.push(new ObjectLayer(layerIndex, layerData, level));
            }
            layerIndex++;
        }
    }

    /** Updates the animations in the level. **/
    public inline function update(dt: Float) {
        for (layer in layers) layer.update(dt);
    }

    public function getByName(name: String): Maybe<Layer> {
        for (layer in layers) {
            if (layer.name == name) return layer;
        }
        return null;
    }

    public function getTileLayers(): Array<TileLayer> {
        final result: Array<TileLayer> = [];

        for (layer in layers) {
            switch (layer.kind) {
            case tile(tileLayer):
                result.push(tileLayer);
            default:
            }
        }

        return result;
    }

    public function getObjectLayers(): Array<ObjectLayer> {
        final result: Array<ObjectLayer> = [];

        for (layer in layers) {
            switch (layer.kind) {
            case object(objectlayer):
                result.push(objectlayer);
            default:
            }
        }

        return result;
    }
}
