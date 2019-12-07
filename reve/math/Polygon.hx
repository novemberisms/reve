package reve.math;

import h2d.col.Polygon as HeapsPolygon;
import reve.math.algorithms.SeparatingAxis;

@:forward(toSegments, area)
abstract Polygon(HeapsPolygon) from HeapsPolygon to HeapsPolygon {

    public var bounds(get, never): Rectangle;
    public var points(get, never): Array<Vector>;

    public var centroid(get, set): Vector;

    public function new(points: Array<Vector>) {
        this = new HeapsPolygon(points);
#if !skipAsserts
        if (!this.isConvex()) throw "Only supports convex polygons";
        if (!this.isClockwise()) throw "Only supports clockwise polygons";
#end
    }

    /** Returns whether the given point is contained within the polygon. If the point lies on the
        edge, it is not considered contained. **/
    public function contains(point: Vector): Bool {

        var p1 = this.points[this.length - 1];

        for (p2 in this.points) {
            @:privateAccess
            if (this.side(p1, p2, point) <= 0) return false;
            p1 = p2;
        }

        return true;
    }

    /** Returns the normal vectors for each side in this polygon. The vectors will point outwards from the center of the 
        polygon and will be all unit vectors. There is no guaranteed order to the sides except that they will be clockwise. **/
    public function getNormals(): Array<Vector> {
        final normals = new Array<Vector>();

        // cast this to an array of vectors from an array of points
        final myPoints: Array<Vector> = this;

        var p1 = myPoints[myPoints.length - 1];
        
        for (p2 in myPoints) {
            final sideVec = p2 - p1;
            // since polygons can only be clockwise, then to get the normal of this side, we only need to find the vector pointing 
            // outwards, which will be if the vector is rotated 90 degrees counter-clockwise
            final outward = sideVec.perpendicularCounterClockwise();

            normals.push(outward.normalized);

            p1 = p2;
        }

        return normals;
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

    public inline function getClosestCornerTo(point: Vector): Vector {
        return this.findClosestPoint(point, Math.POSITIVE_INFINITY);
    }

    public function collideBounds(rect: Rectangle): Bool {

        // if the bounds of this polygon does not even intersect with the rectangle, then there is no chance
        if (!rect.intersects(bounds)) return false;

        // use the SAT to find a separating axis
        // since the bounds intersect, then the separating axis cannot be along the x or y axes

        final rectCorners = rect.corners();

        for (normal in getNormals()) {
            // getting the projection of a vector to a unit vector is as simple as taking the dot product
            final rectProjection = SeparatingAxis.getShadow(rectCorners, normal);
            final polyProjection = SeparatingAxis.getShadow(this.points, normal);

            if (SeparatingAxis.testForSeparatingAxis(
                rectProjection.min, 
                rectProjection.max, 
                polyProjection.min, 
                polyProjection.max
            )) {
                return false;
            }
        }

        return true;
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

    public function translate(translation: Vector) {
        for (p in this) {
            p.x += translation.x;
            p.y += translation.y;
        }
    }

    public function rotate(angle: Float, origin: Vector) {
        for (p in this) {
            final diff = p - origin;
            final newPos = origin + diff.rotated(angle);
            p.x = newPos.x;
            p.y = newPos.y;
        }
    }

    public function scale(value: Vector, origin: Vector) {
        for (p in this) {
            final diff = p - origin;
            final newPos = origin + diff * value;
            p.x = newPos.x;
            p.y = newPos.y;
        }
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

        translate(offset);

        return v;
    }

    private inline function get_points(): Array<Vector> {
        return this;
    }
}