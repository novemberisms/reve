package reve.level;

import reve.util.Maybe;
import reve.math.Vector;
import hxd.Res;
import reve.util.JsonReader;
import hxd.res.Resource;
import reve.level.Types;

using reve.util.PathExtender;

enum TilesetType {
    atlas(atlasSet: AtlasTileset);
    collection(collectionSet: CollectionTileset);
}

/**
 * An abstract class that unifies the two kinds of tilesets: those that use a single sprite atlas,
 * and those that use a collection of images for its tiles.
 * 
 * Pattern match on `.kind` to downcast to the correct type. 
 */
class Tileset {

    public var kind(default, null): TilesetType;

    public final name: String;

    public final tilecount: Int;

    private final _tiles: Map<Int, MapTile> = [];
    private final _animations: Map<Int, Animation> = [];

    private final _tilesetPath: String;

    /** `data` is a Tiled Map editor JSON tileset. **/
    public static function create(data: Resource): Tileset {
		final tilesetPath = data.entry.path;
        final tilesetData: TiledTileset = JsonReader.load(data);
        
        if (tilesetData.image.exists()) {
            return new AtlasTileset(tilesetData, tilesetPath);
        } else {
            return new CollectionTileset(tilesetData, tilesetPath);
        }
    }

    private function new(tilesetData: TiledTileset, tilesetPath: String) {

        _tilesetPath = tilesetPath;

        name = tilesetData.name;
        tilecount = tilesetData.tilecount;
        
        if (!tilesetData.tiles.exists()) return;
        
        // create a populated MapTile for each tile data in the tileset
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

    public inline function getTile(id: Int): MapTile {
        if (_tiles[id] == null) _tiles[id] = MapTile.empty(id, this, () -> createTile(id));
        return _tiles[id];
    }

    /** Returns a path (relative to src/) to the image associated with the tile id. If this is an atlas tileset, this will be the path to the atlas.
        Otherwise, it will be a path to the image for that tile. */
    @:virtual public function getSourceImagePath(id: Int): String {
        return "";
    } 

    /** Returns a list of map tiles in this tileset which correspond to Tiled tiles
        whose properties match the given filter function.  **/
    public inline function tilesWhere(filter: MapTile -> Bool): Array<MapTile> {
        final result: Array<MapTile> = [];
        for (_ => tile in _tiles) {
            if (filter(tile)) result.push(tile);
        }
        return result;
    }

    /** Similar to `tilesWhere`, but only returns the first tile it can find that
        matches `filter`. Can return null if no tiles match the filter. **/
    public function tileWhere(filter: MapTile -> Bool): Maybe<MapTile> {
        for (_ => tile in _tiles) {
            if (filter(tile)) return tile;
        }
        return null;
    }

    @:virtual public function createTilegroup(id: Int): h2d.TileGroup {
        return new h2d.TileGroup(h2d.Tile.fromColor(0xff0000));
    }

    /** This method is passed down to each MapTile's constructor in order for the 
        map tile to be able to lazily construct its own h2d.Tile. This is necessary
        to preserve the one-way flow of data from tileset to tile **/
    @:virtual private function createTile(id: Int): h2d.Tile {
        return h2d.Tile.fromColor(0xff0000);
    }

    private function createAnimation(id: Int, animationFrames: Array<TileAnimationFrame>): Animation {
        if (!_animations.exists(id)) {
            final frames = [for (frame in animationFrames) createTile(frame.tileid)];
            final fps = 1000 / animationFrames[0].duration;
            _animations[id] = new Animation(frames, fps);
        }
        return _animations[id].clone();
    }

}



class AtlasTileset extends Tileset {
    
    /** The image atlas turned into a h2d.Tile. This is lazy-loaded. */
    public var atlas(get, never): h2d.Tile;
    public final atlasPath: String;

    public final tilewidth: Int;
    public final tileheight: Int; 
    public var tilesize(get, never): Vector;

    private final _columns: Int;
    private var _atlas: Maybe<h2d.Tile>;

    public function new(tilesetData: TiledTileset, tilesetPath: String) {
        kind = TilesetType.atlas(this);

        tilewidth = tilesetData.tilewidth;
        tileheight = tilesetData.tileheight;
        _columns = tilesetData.columns;
        
		// keep the atlas path so that once atlas needs to be lazy-loaded in,
		// we can fetch it
        atlasPath = tilesetPath.applyRelativeString(tilesetData.image.sure());
        
        super(tilesetData, tilesetPath);
    }

    public override function getSourceImagePath(id: Int): String {
        return atlasPath;
    }

    public override function createTilegroup(id: Int): h2d.TileGroup {
        return new h2d.TileGroup(atlas);
    }

    private inline function get_atlas(): h2d.Tile {
        if (!_atlas.exists()) {
            _atlas = Res.load(atlasPath).toTile();
        }

        return _atlas.sure();
    }

    private override function createTile(id: Int): h2d.Tile {
        final gx = id % _columns;
        final gy = Std.int(id / _columns);
        return atlas.sub(gx * tilewidth, gy * tileheight, tilewidth, tileheight);
    }

    private inline function get_tilesize(): Vector {
        return new Vector(tilewidth, tileheight);
    }
}


class CollectionTileset extends Tileset {

    private final _tileImagePaths: Map<Int, String> = [];

    public function new(tilesetData: TiledTileset, tilesetPath: String) {
        kind = TilesetType.collection(this);

        super(tilesetData, tilesetPath);

        if (!tilesetData.tiles.exists()) return;

        for (tile in tilesetData.tiles.sure()) {
            final pathToImage = tilesetPath.applyRelativeString(tile.image.sure());
            _tileImagePaths[tile.id] = pathToImage;
        }
    }

    public override function getSourceImagePath(id: Int): String {
        return _tileImagePaths[id];
    }

    public override function createTilegroup(id: Int): h2d.TileGroup {
        return new h2d.TileGroup(_tiles[id].tile);
    }

    private override function createTile(id: Int): h2d.Tile {
        final pathToImage = _tileImagePaths[id];
        return Res.load(pathToImage).toTile();
    }
}