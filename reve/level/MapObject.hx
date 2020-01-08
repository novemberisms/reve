package reve.level;

import reve.math.Vector;
import reve.level.Types;

enum ObjectKind {
    tile(obj: TileObject);
    rectangle(obj: RectangleObject);
    point(obj: PointObject);
    ellipse(obj: EllipseObject);
    polygon(obj: PolygonObject);
}

class MapObject {

    public var kind(default, null): ObjectKind;
    public final id: Int;
    public final name: String;
    public final type: String;
    /** Rotation of the object in radians **/
    public final rotation: Float;
    public final properties: Properties;

    public var position: Vector;

    private function new(id: Int, data: TiledObject) {
        this.id = id;
        name = data.name;
        type = data.type;
        rotation = data.rotation * Math.PI / 180;
        properties = data.properties;
    }

    public static function create(id: Int, data: TiledObject, tilesetService: TilesetService): MapObject {
        if (data.gid.exists()) {
            final maptile = tilesetService.get(data.gid.sure());
            return new TileObject(id, data, maptile);
        } else if (data.ellipse.exists()) {
            return new EllipseObject(id, data);
        } else if (data.point.exists()) {
            return new PointObject(id, data);
        } else if (data.polygon.exists()) {
            return new PolygonObject(id, data);
        } else {
            return new RectangleObject(id, data);
        }
    }


}

/** extends MapObject **/
class TileObject extends MapObject {

    public final maptile: MapTile;
    public final size: Vector;
    public final scale: Vector;

    public function new(id: Int, data: TiledObject, maptile: MapTile) {
        super(id, data);
        kind = tile(this);

        this.maptile = maptile;
        size = new Vector(data.width, data.height);
        scale = size / maptile.size;
        position = new Vector(
            data.x + data.height * Math.sin(rotation),
            data.y - data.height * Math.cos(rotation)
        );

    }
}

/** extends MapObject **/
class RectangleObject extends MapObject {

    public final size: Vector;

    public function new(id: Int, data: TiledObject) {
        super(id, data);
        kind = rectangle(this);

        position = new Vector(data.x, data.y);
        size = new Vector(data.width, data.height);
    }
}

/** extends MapObject **/
class PointObject extends MapObject {

    public function new(id: Int, data: TiledObject) {
        super(id, data);
        kind = point(this);

        position = new Vector(data.x, data.y);
    }
}

/** extends MapObject **/
class EllipseObject extends MapObject {

    public final center: Vector;
    public final size: Vector;

    public function new(id: Int, data: TiledObject) {
        super(id, data);
        kind = ellipse(this);

        position = new Vector(data.x, data.y);
        size = new Vector(data.width, data.height);

        center = position + (size / 2).rotated(rotation);
    }
}

/** extends MapObject **/
class PolygonObject extends MapObject {

    public var points(get, never): Array<Vector>;

    private final _offsets: Array<Vector> = [];

    public function new(id: Int, data: TiledObject) {
        super(id, data);
        kind = polygon(this);

        position = new Vector(data.x, data.y);

        for (offset in data.polygon.sure()) {
            _offsets.push(new Vector(offset.x, offset.y));
        }
    }

    private function get_points(): Array<Vector> {
        final result: Array<Vector> = [];

        for (offset in _offsets) {
            result.push(position + offset);
        }

        return result;
    }
}
