package reve.level;

import reve.util.Maybe;
import reve.math.Vector;
import hxd.Res;
import reve.util.JsonReader;
import hxd.res.Resource;
import reve.level.Types;

using reve.util.PathExtender;

class Tileset {

    /** The image atlas turned into a h2d.Tile. This is lazy-loaded **/
    public var atlas(get, never): h2d.Tile;

    public final name: String;
    public final tilewidth: Int;
    public final tileheight: Int;
    public final columns: Int;
    public final tilecount: Int;

    public var tilesize(get, never): Vector;

    private final _tiles: Map<Int, MapTile> = [];
    private final _animations: Map<Int, Animation> = [];

    private var _atlas: Maybe<h2d.Tile>;
    private final _atlasPath: String;

    /** `data` is a Tiled Map editor JSON tileset. **/
    public function new(data: Resource) {

        final tilesetPath = data.entry.path;
        final tilesetData: TiledTileset = JsonReader.load(data);

        name = tilesetData.name;
        tilewidth = tilesetData.tilewidth;
        tileheight = tilesetData.tileheight;
        columns = tilesetData.columns;
        tilecount = tilesetData.tilecount;

        // keep the atlas path so that once atlas needs to be lazy-loaded in,
        // we can fetch it
        _atlasPath = tilesetPath.applyRelativeString(tilesetData.image);

        // create a populated MapTile for each tile data in the tileset
        if (tilesetData.tiles.exists()) {
            for (tile in tilesetData.tiles.sure()) {

                final createAnimationFn: Maybe<Void -> Animation> = tile.animation.exists()
                    ? () -> createAnimation(tile.id, tile.animation.sure())
                    : null;

                _tiles[tile.id] = new MapTile(
                    tile, 
                    this, 
                    () -> createTile(tile.id), 
                    createAnimationFn
                );
            }
        }
    }

    public inline function getTile(id: Int): MapTile {
        if (_tiles[id] == null) _tiles[id] = MapTile.empty(id, this, () -> createTile(id));
        return _tiles[id];
    }

    /** Returns a list of map tiles in this tileset which correspond to Tiled tiles
        whose properties match the given filter function.  **/
    public inline function tilesWhere(filter: MapTile -> Bool): Array<MapTile> {
        final result: Array<MapTile> = [];
        for (id => tile in _tiles) {
            if (filter(tile)) result.push(tile);
        }
        return result;
    }

    /** Similar to `tilesWhere`, but only returns the first tile it can find that
        matches `filter`. Can return null if no tiles match the filter. **/
    public function tileWhere(filter: MapTile -> Bool): Maybe<MapTile> {
        for (id => tile in _tiles) {
            if (filter(tile)) return tile;
        }
        return null;
    }

    /** This method is passed down to each MapTile's constructor in order for the 
        map tile to be able to lazily construct its own h2d.Tile. This is necessary
        to preserve the one-way flow of data from tileset to tile **/
    private inline function createTile(id: Int): h2d.Tile {
        final gx = id % columns;
        final gy = Std.int(id / columns);
        return atlas.sub(gx * tilewidth, gy * tileheight, tilewidth, tileheight);
    }

    private inline function createAnimation(id: Int, animationFrames: Array<TileAnimationFrame>): Animation {
        if (!_animations.exists(id)) {
            final frames = [for (frame in animationFrames) createTile(frame.tileid)];
            final fps = 1000 / animationFrames[0].duration;
            _animations[id] = new Animation(frames, fps);
        }
        return _animations[id].clone();
    }

    private inline function get_tilesize(): Vector {
        return new Vector(tilewidth, tileheight);
    }

    private inline function get_atlas(): h2d.Tile {
        if (!_atlas.exists()) {
            _atlas = Res.load(_atlasPath).toTile();
        }
        return _atlas.sure();
    }

}


