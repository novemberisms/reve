package reve.level;

import reve.math.Vector;
import reve.level.Types;
import reve.util.Maybe;
import reve.level.Tileset;

class MapTile {

    public final id: Int;
    public final properties: Properties;
    public final type: String;
    public final tileset: Tileset;
    public final size: Vector;

    /** Gets a lazy-loaded h2d.Tile for this tile **/
    public var tile(get, never): h2d.Tile;
    private var _tile: Maybe<h2d.Tile>;

    public var isAnimated(get, never): Bool;
    private var _animation: Maybe<Animation>;

    /** A method that will create a brand new h2d.Tile for this MapTile. **/
    private final _createTileFn: Void -> h2d.Tile;
    private final _createAnimationFn: Maybe<Void -> Animation>;

    public function new(
        tileData: TiledTile, 
        tileset: Tileset, 
        createTileFn: Void -> h2d.Tile, 
        createAnimationFn: Maybe<Void -> Animation>
    ) {
        id = tileData.id;
        properties = tileData.properties;
        type = tileData.type.or("");
        size = tileset.tilesize;

        _createTileFn = createTileFn;
        _createAnimationFn = createAnimationFn;

        this.tileset = tileset;
    }

    public inline function cloneAnimation(): Animation {
#if !skipAsserts
        if (!isAnimated) throw "Trying to clone the animation of a tile which has none";
#end
        if (!_animation.exists()) {
            final createAnimation = _createAnimationFn.sure();
            _animation = createAnimation();
        } 
        return _animation.sure().clone();
    }

    private inline function get_tile(): h2d.Tile {
        if (!_tile.exists()) {
            _tile = _createTileFn();
        }

        return _tile.sure();
    }

    private inline function get_isAnimated(): Bool {
        return _createAnimationFn.exists();
    }

    /** Creates an empty map tile. An empty tile does not mean that there is nothing to display;
        it just denotes a tile that has no special properties. It still has a corresponding
        sprite in the tileset which is displayed normally. Tilesets that are collections of images
        will not have any empty maptiles. **/
    public static inline function empty(
        id: Int, 
        tileset: Tileset, 
        createTileFn: Void -> h2d.Tile
    ): MapTile {
        return new MapTile({
            id: id,
            type: "",
            properties: null,
            animation: null,
            image: null,
            imagewidth: null,
            imageheight: null,
        }, tileset, createTileFn, null);
    }

}
