package reve.util;

import hxd.Res;

class CastleHelper {

    /** A cache of images turned into tiles, indexed by filepath. **/
    private static final _tileSources: Map<String, h2d.Tile> = [];

    public static function toTile(data: cdb.Types.TilePos): h2d.Tile {
        final atlas = getImage(data.file);

        final size = data.size;

        var width = size;
        if (data.width != null) width *= data.width;
        var height = size;
        if (data.height != null) height *= data.height;

        final xOffset = size * data.x;
        final yOffset = size * data.y;

        return atlas.sub(xOffset, yOffset, width, height);
    }

    public static function clearTileCache() {
        _tileSources.clear();
    }

    private static function getImage(path: String): h2d.Tile {
        if (!_tileSources.exists(path)) {
            _tileSources[path] = Res.load(path).toTile();
        }

        return _tileSources[path].clone();
    }
}