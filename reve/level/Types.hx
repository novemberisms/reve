package reve.level;

import reve.util.Maybe;

/** Description of a single level or map for the Tiled map editor. **/
typedef TiledMap = {
    public var width(default, null): Int;
    public var height(default, null): Int;
    public var layers(default, null): Array<TiledLayer>;
    public var tiledversion(default, null): String;
    public var tilewidth(default, null): Int;
    public var tileheight(default, null): Int; 
    public var tilesets(default, null): Array<TilesetReference>;
    public var properties(default, null): Properties;
}

/** Description of a single layer within a level. There are two kinds of supported
    layers: Tile Layers, and Object Layers.  **/
typedef TiledLayer = {
    public var data(default, null): Maybe<Array<Int>>;
    public var name(default, null): String;
    public var objects(default, null): Maybe<Array<TiledObject>>;
    public var type(default, null): LayerType;
    public var properties: Properties;
}

enum abstract LayerType(String) {
    public var tilelayer;
    public var objectgroup;
}

/** Description of an object in an Object Layer. Note that Tile objects' origins
    are at the bottom left while shape objects have their origins at the top left. **/
typedef TiledObject = {
    /** If this is not null, then the object is a tile object**/
    public var gid(default, null): Maybe<Int>;
    /** If this is not null, then the object is an ellipse object**/
    public var ellipse(default, null): Maybe<Bool>;
    /** If this is not null, then the object is a point object**/
    public var point(default, null): Maybe<Bool>;
    /** If this is not null, then the object is a polygon object**/
    public var polygon(default, null): Maybe<Array<{x: Float, y: Float}>>;
    public var width(default, null): Int;
    public var height(default, null): Int;
    public var name(default, null): String;
    public var type(default, null): String;
    public var x(default, null): Float;
    public var y(default, null): Float;
    public var rotation(default, null): Float;
    public var properties: Properties;
}

/** Each level must reference at least one tileset from which to draw its tiles from. 
    It refers to each tile using a GID, which is like an ID in a tileset, but offset
    by a certain amount based on the order the tileset appears in in the level's list
    of tilesets, and is also based on the total number of tiles in tilesets before it. **/
typedef TilesetReference = {
    public var firstgid(default, null): Int;
    public var source(default, null): String;
}

/** Description of a tileset used by the Tiled Map Editor as seen in the tileset JSON files. **/
typedef TiledTileset = {
    public var image(default, null): String;
    public var imageheight(default, null): Int;
    public var imagewidth(default, null): Int;
    public var name(default, null): String;
    public var tiledversion(default, null): String;
    public var tilewidth(default, null): Int;
    public var tileheight(default, null): Int;
    public var tilecount(default, null): Int;
    public var margin(default, null): Int;
    public var spacing(default, null): Int;
    public var columns(default, null): Int;
    public var type(default, null): String;
    public var tiles(default, null): Maybe<Array<TiledTile>>;
}

/** Description of a tile with some added metadata in a tileset file. Not all tiles have this. 
    Only the ones with custom properties, animations, etc. **/
typedef TiledTile = {
    public var id: Int;
    public var properties: Properties;
    public var type: Maybe<String>;
    public var animation: Maybe<Array<TileAnimationFrame>>;
}

typedef TileAnimationFrame = {
    /** In milliseconds **/
    public var duration: Int;
    public var tileid: Int; 
}

/** `TiledMap`s, `TiledTile`s, `TiledObject`s, and `TiledLayer`s can each have their own custom properties
    defined within Tiled. **/
typedef CustomProperty = {
    public var name: String;
    public var type: CustomPropertyType;
    public var value: Any;
}

enum abstract CustomPropertyType(String) {
    public var undefined;
    public var string;
    public var int;
    public var float;
    public var bool;
}

/** An abstraction over `CustomProperty` with methods for easy fetching of property values
    and types by name. **/
abstract Properties(Maybe<Array<CustomProperty>>) {

    public var empty(get, never): Bool;

    private function get<T>(name: String): Maybe<T> {
        if (!this.exists()) return null;
        for (prop in this.sure()) {
            if (prop.name == name) return prop.value;
        }
        return null;
    }

    public inline function getString(name: String): Maybe<String> {
        return get(name);
    }

    public inline function getInt(name: String): Maybe<Int> {
        return get(name);
    }

    public inline function getFloat(name: String): Maybe<Float> {
        return get(name);
    }

    public inline function getBool(name: String): Maybe<Bool> {
        return get(name);
    }

    public function typeof(name: String): CustomPropertyType {
        if (!this.exists()) return CustomPropertyType.undefined;
        for (prop in this.sure()) {
            if (prop.name == name) return prop.type;
        }
        return CustomPropertyType.undefined;
    }

    private inline function get_empty(): Bool {
        return !this.exists();
    }
}