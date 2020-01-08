package reve.level;

import reve.util.Maybe;
import reve.math.Vector;
import hxd.Res;
import reve.util.JsonReader;
import hxd.res.Resource;
import reve.level.Types;

using reve.util.PathExtender;

class Tileset {

    /** The image atlas turned into a h2d.Tile. This is lazy-loaded. May be null if
        the tileset uses a collection of images instead of an atlas. **/
    public var atlas(get, never): Maybe<h2d.Tile>;
    public var atlasPath: Maybe<String>;

    public final name: String;
    public final tilewidth: Int;
    public final tileheight: Int;
    public final columns: Int;
    public final tilecount: Int;
    public final isAtlas: Bool;

    public var tilesize(get, never): Vector;

    private final _tiles: Map<Int, MapTile> = [];
    private final _animations: Map<Int, Animation> = [];
    private final _tiledTileData: Map<Int, TiledTile> = [];

    private var _atlas: Maybe<h2d.Tile>;

    private final _tilesetPath: String;

    private final _tileImagePaths: Map<Int, String> = [];

    /** `data` is a Tiled Map editor JSON tileset. **/
    public function new(data: Resource) {

        _tilesetPath = data.entry.path;

        final tilesetData: TiledTileset = JsonReader.load(data);

        name = tilesetData.name;
        tilewidth = tilesetData.tilewidth;
        tileheight = tilesetData.tileheight;
        columns = tilesetData.columns;
        tilecount = tilesetData.tilecount;
        
        // save the "tiles" array from the tileset data to a map since we're going to
        // need to reference it in `createTile`
        if (tilesetData.tiles.exists()) {
            for (tile in tilesetData.tiles.sure()) {
                _tiledTileData[tile.id] = tile;
            }
        }

        isAtlas = tilesetData.image.exists();

        if (isAtlas) {
            setupAsAtlas(tilesetData);
        } else {
            setupAsCollection(tilesetData);
        }
    }

    public inline function getTile(id: Int): MapTile {
        if (_tiles[id] == null) _tiles[id] = MapTile.empty(id, this, () -> createTile(id));
        return _tiles[id];
    }

    /** Returns a path (relative to src/) to the image associated with the tile id. If this is an atlas tileset, this will be the path to the atlas.
        Otherwise, it will be a path to the image for that tile. */
    public inline function getSourceImagePath(id: Int): Maybe<String> {
        if (isAtlas) return atlasPath;
        return _tileImagePaths[id];
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

    private function setupAsAtlas(tilesetData: TiledTileset) {

        // keep the atlas path so that once atlas needs to be lazy-loaded in,
        // we can fetch it
        atlasPath = _tilesetPath.applyRelativeString(tilesetData.image.sure());

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

    private function setupAsCollection(tilesetData: TiledTileset) {
        if (!tilesetData.tiles.exists()) return;

        for (tile in tilesetData.tiles.sure()) {
            
            final pathToImage = _tilesetPath.applyRelativeString(tile.image.sure());
            _tileImagePaths[tile.id] = pathToImage;

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

    /** This method is passed down to each MapTile's constructor in order for the 
        map tile to be able to lazily construct its own h2d.Tile. This is necessary
        to preserve the one-way flow of data from tileset to tile **/
    private inline function createTile(id: Int): h2d.Tile {
        if (isAtlas) {
            final gx = id % columns;
            final gy = Std.int(id / columns);
            return atlas.sure().sub(gx * tilewidth, gy * tileheight, tilewidth, tileheight);
        } else {
            final tiledata = _tiledTileData[id];
            final pathToImage = _tilesetPath.applyRelativeString(tiledata.image.sure());
            return Res.load(pathToImage).toTile();
        }
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

    private inline function get_atlas(): Maybe<h2d.Tile >{
        if (!isAtlas) return null;

        if (!_atlas.exists()) {
            _atlas = Res.load(atlasPath.sure()).toTile();
        }

        return _atlas;
    }
}


