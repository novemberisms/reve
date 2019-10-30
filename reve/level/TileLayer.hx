package reve.level;

import reve.level.Layer.AnimationChange;
import reve.util.Maybe;
import reve.math.Vector;
import reve.level.Types;
import h2d.Object;
using reve.util.ObjectExtender;

/** Extends Layer **/
class TileLayer extends Layer {

    public final width: Int;
    public final height: Int;
    public final tileWidth: Int;
    public final tileHeight: Int;

    public var tilesize(get, never): Vector;

    /** Raw initial data of gid's **/
    private final _data: Array<Int>;
    /** The actual working copy of the layer's tiles. This serves as the 
        layer's state, and editting this array should change what appears on screen
        after calling `redraw()` **/
    private final _tiles: Array<Maybe<MapTile>> = [];

    public function new(index: Int, layerData: TiledLayer, level: Level) {
        kind = tile(this);

        _data = layerData.data.sure();

        width = level.width;
        height = level.height;
        tileWidth = level.tileWidth;
        tileHeight = level.tileHeight;
        
        // fills _tiles with width * height null entries
        _tiles.resize(width * height);

        super(index, layerData, level);
    }

    //=========================================================================
    // PUBLIC FUNCTIONS
    //=========================================================================

    //-------------------------------------------------------------------------
    // These functions just get information

    public inline function getTile(gridPosition: Vector): Maybe<MapTile> {
        if (!withinBounds(gridPosition)) return null;
        return _tiles[getIndex(gridPosition)];
    }

    public inline function getTileAt(position: Vector): Maybe<MapTile> {
        final gridPosition = _level.getGridPosition(position);
        return getTile(gridPosition);
    }

    //-------------------------------------------------------------------------
    // These functions modify the tilemap

    public function clearTile(gridPosition: Vector) {
        if (!withinBounds(gridPosition)) return;
        
        final tileIndex = getIndex(gridPosition);
        final existingTile = _tiles[tileIndex];

        if (!existingTile.exists()) return;

        if (existingTile.sure().isAnimated) {
            markAnimationChange(AnimationChange.remove(tileIndex));
        } else {
            markTileChange(existingTile.sure());
        }

        _tiles[tileIndex] = null;
    }

    public function setTile(tile: MapTile, gridPosition: Vector) {
        if (!withinBounds(gridPosition)) return;

        final tileIndex = getIndex(gridPosition);
        final existingTile = _tiles[tileIndex];

        if (existingTile.exists()) {
            if (existingTile.sure().isAnimated) {
                markAnimationChange(AnimationChange.remove(tileIndex));
            } else {
                markTileChange(existingTile.sure());
            }
        }

        if (tile.isAnimated) {
            final newAnimation = tile.cloneAnimation();
            newAnimation.setPositionV(getPositionFromIndex(tileIndex));
            markAnimationChange(AnimationChange.add(newAnimation, tileIndex));
        } else {
            markTileChange(tile);
        }

        _tiles[tileIndex] = tile;
    }

    //=========================================================================
    // VIRTUAL FUNCTIONS
    //=========================================================================

    /** Tells the layer to redraw all of its contents after a change. If there are no pending changes,
        this does nothing. **/
    private override function redrawTileGroups() {
        
        for (index in 0..._tiles.length) {
            final tileMaybe = _tiles[index];

            if (!tileMaybe.exists()) continue;
            
            final tile = tileMaybe.sure();
            
            if (tile.isAnimated) continue;

            final group = getTileGroupFor(tile.tileset);

            if (!_tilegroupsToRedraw.contains(group)) continue;

            final position = getPositionFromIndex(index);
            group.add(position.x, position.y, tile.tile);
        }
    }
    
    private override function createSprite(): Object {
        final container = new Object();

        var i = 0;
        for (gy in 0...height) {
            for (gx in 0...width) {
                final gid = _data[i];
                if (gid > 0) {
                    final maptile = _level.tilesetService.get(gid);
                    createTile(maptile, new Vector(gx, gy), i);
                }
                i++;
            }
        }

        embedTilegroups(container);
        embedAnimations(container);

        return container;
    }

    //=========================================================================
    // HELPER FUNCTIONS
    //=========================================================================

    private inline function getIndex(gridPosition: Vector): Int {
        return Std.int(gridPosition.y * width + gridPosition.x);
    }

    private inline function getPositionFromIndex(index: Int): Vector {
        return new Vector((index % width) * tileWidth, Math.floor(index / width) * tileHeight);
    }

    private inline function get_tilesize(): Vector {
        return new Vector(tileWidth, tileHeight);
    }

    /** Tells whether a given grid coordinate is inside the grid of this layer. **/
    private inline function withinBounds(gridPosition: Vector): Bool {
        if (gridPosition.x < 0) return false;
        if (gridPosition.y < 0) return false;
        if (gridPosition.x >= width) return false;
        if (gridPosition.y >= height) return false;
        return true;
    }

    //=========================================================================
    // HELPER FUNCTIONS FOR CREATESPRITE
    //=========================================================================

    private function createTile(tile: MapTile, gridPosition: Vector, index: Int) {
        final position = gridPosition * tilesize;
        final spawnCommand = _level.factory.onTile(tile, this, _level, position, gridPosition);
        
        switch (spawnCommand) {
        case allow:
            if (tile.isAnimated) {
                emitAnimation(tile, gridPosition, index);
            } else {
                emitTile(tile, gridPosition, index);
            }

        case prevent:
            // do nothing

        case replace(newtile):
            createTile(newtile, gridPosition, index);

        case moveTo(newGridPosition):
            if (tile.isAnimated) {
                emitAnimation(tile, newGridPosition, index);
            } else {
                emitTile(tile, newGridPosition, index);
            }

        case replaceAt(newtile, newGridPosition):
            createTile(newtile, newGridPosition, index);
        }
    }

    private inline function emitAnimation(tile: MapTile, gridPosition: Vector, index: Int) {
        final animation = tile.cloneAnimation();
        animation.setPositionV(gridPosition * tilesize);
        _animations[index] = animation;
    }

    private inline function emitTile(tile: MapTile, gridPosition: Vector, index: Int) {
        final tileGroup = getTileGroupFor(tile.tileset);
        final position = gridPosition * tilesize;
        tileGroup.add(position.x, position.y, tile.tile);
        _tiles[index] = tile;
    }

}