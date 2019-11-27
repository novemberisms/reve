package reve.math;

import h2d.col.Polygon as HeapsPolygon;

abstract Polygon(HeapsPolygon) from HeapsPolygon to HeapsPolygon {

    public var bounds(get, never): Rectangle;
    public var centroid(get, set): Vector;

    public function new(points: Array<Vector>) {
        this = new HeapsPolygon(points);
    }

    // TODO: DOES A POINT ON THE EDGE RETURN FALSE? IT REALLY SHOULD.
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
    public function getDistanceSquared(point: Vector): Float {
        return this.distanceSq(point, true);
    }

    /**
     * Returns the distance squared from the closest edge of the polygon to a point **inside** of it.
     * If the point is outside, returns zero
     * @param point the point to compute distance to
     */
    public function getDistanceSquaredInside(point: Vector): Float {
        return this.distanceSq(point, false);
    }

    /**
     * Returns the closest point on the edges of the polygon to the given point.
     * @param point The point with which to find the closest point to.
     */
    public function getClosestPointOnEdgeTo(point: Vector): Vector {
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
}