package reve.data;

import hxd.Res;

/** This static class serves as a wrapper for all app-specific data in the form of a Castle DB database.
    This requires a file in the resource folder called 'data.cdb'. 
    
    Now this data file must have some required sheets. **/
@:final class Data {

    /** A cache of images turned into Tiles, indexed by filepath **/
    private static final _tileImages: Map<String, h2d.Tile> = [];

    //=========================================================================
    // PUBLIC FUNCTIONS
    //=========================================================================
    //-------------------------------------------------------------------------
    // Initializers
    public static function load() {
        Db.load(Res.data.entry.getText());
    }

    //-------------------------------------------------------------------------
    // Data fetchers
    
    /** Given an identifier for a row in the 'animations' sheet, returns a new Animation **/
    public static function animation(id: DbAnimationsKind): reve.Animation {
        final data = Db.animations.get(id);

        final looping = data.looping;
        final fps = data.fps;
        final frames = data.frames.map(f -> toTile(f.tile));
        
        return new engine.Animation(frames, fps, looping);
    }

    //=========================================================================
    // PRIVATE FUNCTIONS
    //=========================================================================

    /** Turns a cdb Tile into an h2d.Tile **/
    private static function toTile(data: cdb.Types.TilePos): h2d.Tile {
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

    /** Use this function to get an image from a path provided by data.cdb. This **/
    private static inline function getImage(path: String): h2d.Tile {
        if (!_tileImages.exists(path)) {
            _tileImages[path] = Res.load(path).toTile();
        }
        return _tileImages[path].clone();
    }

}

// Re-exporting these as typedefs so that external code does not need to import both engine.data.Data and engine.data.Db

typedef DbAnimationsKind = Db.AnimationsKind;
typedef DbAnimations = Db.Animations;

