package reve.math;

import h2d.col.Circle as HeapsCircle;

@:forward(collideBounds, collideCircle)
abstract Circle(HeapsCircle) from HeapsCircle to HeapsCircle {

    public var center(get, set): Vector;
    public var radius(get, set): Float;
    public var bounds(get, never): Rectangle;
    public var cx(get, set): Float;
    public var cy(get, set): Float;

    public function new(center: Vector, radius: Float) {
        this = new HeapsCircle(center.x, center.y, radius);
    }

    // TODO: MAKE SURE A POINT ON THE EDGE RETURNS FALSE
    public inline function contains(point: Vector): Bool {
        return this.contains(point);
    }

    public inline function distanceTo(point: Vector): Float {
        return (point - center).length - radius;
    }

    public inline function collidePolygon(polygon: Polygon): Bool {
        return polygon.getDistanceSquared(center) < radius * radius;
    }

    private inline function get_center(): Vector {
        return new Vector(this.x, this.y);
    }

    private inline function set_center(v: Vector): Vector {
        this.x = v.x;
        this.y = v.y;
        return v;
    }

    private inline function get_radius(): Float {
        return this.ray;
    }

    private inline function set_radius(v: Float): Float {
        return this.ray = v;
    }

    private inline function get_bounds(): Rectangle {
        final topleft = center - Vector.one * radius;
        return new Rectangle(topleft, Vector.one * 2 * radius);
    }

    private inline function get_cx(): Float {
        return this.x;
    }

    private inline function set_cx(v: Float): Float {
        return this.x = v;
    }

    private inline function get_cy(): Float {
        return this.y;
    }

    private inline function set_cy(v: Float): Float {
        return this.y = v;
    }
} 