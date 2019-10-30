package reve.level;

import reve.util.Maybe;
import haxe.io.Path;
import hxd.Res;
import reve.level.Types;

using reve.util.PathExtender;

/** This guy takes care of demultiplexing gid's into a Tile from one of the
    tilesets in the map. It does this based on the `firstgid` property in the tiled map. **/
class TilesetService {

    private static final _maxGid = 999999;

    private final _tilesets: Array<Tileset> = [];
    private final _firstGids: Array<Int> = [];
    private final _lastGids: Array<Int> = [];

    public function new(tilesetReferences: Array<TilesetReference>, mapPath: Path) {

        for (i in 0...tilesetReferences.length) {
            final tilesetReference = tilesetReferences[i];
            
            // get the absolute path (rooted in res/) of the tileset given the
            // path of the map and the relative path to the tileset
            final relativePathToTileset = new Path(tilesetReference.source);
            final tilesetPath = mapPath.applyRelative(relativePathToTileset);

            // load the data
            final tilesetData = Res.load(tilesetPath.toString());

            final tileset = new Tileset(tilesetData);

            add(tileset);
        }
    }

    public function getByName(name: String): Maybe<Tileset> {
        for (tileset in _tilesets) {
            if (tileset.name == name) return tileset;
        }
        return null;
    }

    /** Searches all tilesets in the level for the first tile that passes the filter **/
    public function tileWhere(filter: MapTile -> Bool): Maybe<MapTile> {
        for (tileset in _tilesets) {
            final result = tileset.tileWhere(filter);
            if (result.exists()) return result;
        }
        return null;
    }

    /** Searches all tilesets in the level for tiles that pass the filter and returns them as an array. **/
    public inline function tilesWhere(filter: MapTile -> Bool): Array<MapTile> {
        var result: Array<MapTile> = [];
        for (tileset in _tilesets) {
            final partialResult = tileset.tilesWhere(filter);
            result = result.concat(partialResult);
        }
        return result;
    }

    /** Gets a tile based on the given gid. For internal use only. Assumes `gid` > 0 **/
    @:noCompletion
    public function get(gid: Int): MapTile {
        for (i in 0..._tilesets.length) {
            if (gid > _lastGids[i]) continue;
            final tileset = _tilesets[i];
            // id is zero-based, gid is one-based
            final id = gid - _firstGids[i];
            return tileset.getTile(id);
        }
        throw new InvalidGidException(gid);
    }

    public function add(tileset: Tileset) {

        final tilesetCount = _tilesets.length;

        if (tilesetCount > 0) {
            final lastTileset = _tilesets[tilesetCount - 1];

            final firstGid = _firstGids[tilesetCount - 1] + lastTileset.tilecount;

            _lastGids[tilesetCount - 1] = firstGid - 1;

            _firstGids.push(firstGid);
        } else {
            _firstGids.push(1);
        }
        
        _lastGids.push(_maxGid);

        _tilesets.push(tileset);
    }

    public function contains(tileset: Tileset): Bool {
        for (existingTileset in _tilesets) {
            // we compare by name
            if (tileset.name == existingTileset.name) return true;
        }
        return false;
    }
}

class InvalidGidException extends Exception {
    
    public final gid: Int;

    public function new(gid: Int) {
        this.gid = gid;
        super('No tileset found with gid = $gid for any tileset in level.');
    }
}