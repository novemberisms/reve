package reve.math;

import h2d.col.Polygon as HeapsPolygon;

abstract Polygon(HeapsPolygon) from HeapsPolygon to HeapsPolygon {

    public var bounds(get, never): Rectangle;
    /** Gets a copy of the points in this polygon. Modifying the returned value will not affect the polygon. */
    public var points(get, never): Array<Vector>;
    public var centroid(get, set): Vector;

    public function new(points: Array<Vector>) {
        this = new HeapsPolygon(points);
#if !skipAsserts
        if (!this.isConvex()) throw "Only supports convex polygons";
        if (!this.isClockwise()) throw "Only supports clockwise polygons";
#end
    }

    public function contains(point: Vector): Bool {

        var p1 = this.points[this.length - 1];

        for (p2 in this.points) {
            @:privateAccess
            if (this.side(p1, p2, point) <= 0) return false;
            p1 = p2;
        }

        return true;
    }

    /** 
     * Returns the distance squared from the closest edge of the polygon to a point **outside** of it.
     * If the point is inside, returns zero. 
     * @param point the point to compute distance to
     */
    public inline function getDistanceSquared(point: Vector): Float {
        return this.distanceSq(point, true);
    }

    /**
     * Returns the distance squared from the closest edge of the polygon to a point **inside** of it.
     * If the point is outside, returns zero
     * @param point the point to compute distance to
     */
    public inline function getDistanceSquaredInside(point: Vector): Float {
        return this.distanceSq(point, false);
    }

    /**
     * Returns the closest point on the edges of the polygon to the given point.
     * @param point The point with which to find the closest point to.
     */
    public inline function getClosestPointOnEdgeTo(point: Vector): Vector {
        return this.projectPoint(point);
    }

    public function collideBounds(rect: Rectangle): Bool {
        // if the bounds of this polygon does not even intersect with the rectangle, then there is no chance
        if (!rect.intersects(bounds)) return false;

        // check each point in the polygon if it is contained within the rectangle. If any does, then they are intersecting
        for (point in this) {
            if (rect.contains(point)) return true;
        } 

        // failing that, check each corner of the rectangle to see if it is contained within the polygon
        if (contains(rect.topleft)) return true;
        if (contains(rect.topright)) return true;
        if (contains(rect.bottomleft)) return true;
        if (contains(rect.bottomright)) return true;

        return false;
    }

    public function collidePolygon(other: Polygon): Bool {
        // check each point within this polygon to see if any of them are contained in the other polygon\
        for (point in this) {
            if (other.contains(point)) return true;
        }

        // check each point within the other polygon to see if any of them are contained within this one
        for (point in other.points) {
            if (contains(point)) return true;
        }

        return false;
    }

    private inline function get_bounds(): Rectangle {
        return this.getBounds();
    }

    private inline function get_centroid(): Vector {
        return this.centroid();
    }

    private inline function set_centroid(v: Vector): Vector {
        final currentCenter = this.centroid();

        final offset = v - currentCenter;

        for (p in this) {
            p.x += offset.x;
            p.y += offset.y;
        }

        return v;
    }

    private inline function get_points(): Array<Vector> {
        final copy = new Array<Vector>();

        for (point in this) copy.push(point.clone());

        return copy;
    }
}