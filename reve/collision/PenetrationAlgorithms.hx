package reve.collision;

import reve.math.Polygon;
import reve.math.Circle;
import reve.math.Rectangle;
import reve.math.Vector;

class PenetrationAlgorithms {

    public static function getPenetration(shapeA: ICollisionShape, shapeB: ICollisionShape): Vector {
        switch (shapeA.shapeType) {
            case point(pA):
                switch (shapeB.shapeType) {
                    case point(pB):
                        return vecVec(pA.vector, pB.vector);
                    case rectangle(rB):
                        return vecRect(pA.vector, rB.rectangle);
                    case circle(cB):
                        return vecCirc(pA.vector, cB.circle);
                    case polygon(gB):
                        return vecPoly(pA.vector, gB.polygon);
                }
			case rectangle(rA):
				switch (shapeB.shapeType) {
					case point(pB):
                        return -vecRect(pB.vector, rA.rectangle);
					case rectangle(rB):
                        return rectRect(rA.rectangle, rB.rectangle);
					case circle(cB):
                        return rectCirc(rA.rectangle, cB.circle);
                    case polygon(gB):
                        return rectPoly(rA.rectangle, gB.polygon);
				}
			case circle(cA):
				switch (shapeB.shapeType) {
					case point(pB):
                        return -vecCirc(pB.vector, cA.circle);
					case rectangle(rB):
                        return -rectCirc(rB.rectangle, cA.circle);
					case circle(cB):
                        return circCirc(cA.circle, cB.circle);
                    case polygon(gB):
                        return circPoly(cA.circle, gB.polygon);
				}
            case polygon(gA):
				switch (shapeB.shapeType) {
					case point(pB):
                        return -vecPoly(pB.vector, gA.polygon);
					case rectangle(rB):
                        return -rectPoly(rB.rectangle, gA.polygon);
					case circle(cB):
                        return -circPoly(cB.circle, gA.polygon);
                    case polygon(gB):
                        return polyPoly(gA.polygon, gB.polygon);
				}
        }
        return Vector.zero;
    }

	// =========================================================================
	// VECTOR METHODS
	// =========================================================================

    private static inline function vecVec(v1: Vector, v2: Vector): Vector {
        return Vector.zero;
    }

    private static function vecRect(v: Vector, r: Rectangle): Vector {
        if (!r.contains(v)) return Vector.zero;

        final distToLeft = v.x - r.xMin;
        final distToRight = r.xMax - v.x;
        final distToTop = v.y - r.yMin;
        final distToBottom = r.yMax - v.y;

        final lowest = Math.min(
            Math.min(distToLeft, distToRight),
            Math.min(distToTop, distToBottom)
        );

        // as you can see, if a point is in the dead center of a square, it will prioritize a vector pointing down.
        // in a wide rectangle, points on the diagonals will prioritize pointing down, then up
        // in a tall rectangle, points on the diagonals will prioritize pointing right, then left

        if (lowest == distToTop) return Vector.down * distToTop;
        if (lowest == distToBottom) return Vector.up * distToBottom;
        if (lowest == distToLeft) return Vector.right * distToLeft;
        
        return Vector.left * distToRight;
    }

    private static function vecCirc(v: Vector, c: Circle): Vector {
        if (!c.contains(v)) return Vector.zero;

        final toCenter = c.center - v;

        if (toCenter == Vector.zero) return Vector.down * c.radius;

        return (toCenter.normalized * c.radius) - toCenter;
    }

    // TODO: test
    private static function vecPoly(v: Vector, p: Polygon): Vector {
        if (!p.contains(v)) return Vector.zero;

        final closestPoint = p.getClosestPointOnEdgeTo(v);
        return v - closestPoint;
    }

	// =========================================================================
	// RECT METHODS
	// =========================================================================

    // TODO: test
    private static function rectRect(r1: Rectangle, r2: Rectangle): Vector {
        if (!r1.intersects(r2)) return Vector.zero;

        final rightOverlap = r1.xMax - r2.xMin;
        final leftOverlap = r2.xMax - r1.xMin;
        final downOverlap = r1.yMax - r2.yMin;
        final upOverlap = r2.yMax - r1.yMin;

        final lowest = Math.min(
            Math.min(rightOverlap, leftOverlap),
            Math.min(upOverlap, downOverlap)
        );

        if (lowest == downOverlap) return Vector.down * downOverlap;
        if (lowest == upOverlap) return Vector.up * upOverlap;
        if (lowest == rightOverlap) return Vector.right * rightOverlap;

        return Vector.left * leftOverlap;
    }

    // TODO: test
    private static function rectCirc(r: Rectangle, c: Circle): Vector {
        if (!c.collideBounds(r)) return Vector.zero;

        // we know they are intersecting. not we just need to find the penetration
        
        final cx = c.center.x;
        final cy = c.center.y;

        if (cx < r.xMin) {
            // circle is in left region
            if (cy < r.yMin) {
                // circle is in topleft region
                return cornerPenetration(c.center, c.radius, r.topleft);
            } else if (cy > r.yMax) {
                // circle is in bottomleft region
                return cornerPenetration(c.center, c.radius, r.bottomleft);
            } else {
                // circle is in midleft region
                return Vector.left * (cx + c.radius - r.xMin);
            }
        } else if (cx > r.xMax) {
            // circle is in right region
            if (cy < r.yMin) {
                // circle is in topright region
                return cornerPenetration(c.center, c.radius, r.topright);
            } else if (cy > r.yMax) {
                // circle is in bottomright region
                return cornerPenetration(c.center, c.radius, r.bottomright);
            } else {
                // circle is in midright region
                return Vector.right * (r.xMax - (cx - c.radius));
            }
        } else {
            // circle is in center region
            if (cy < r.yMin) {
                // circle is in topcenter region
                return Vector.up * (cy + c.radius - r.yMin);
            } else if (cy > r.yMax) {
                // circle is in bottomcenter region
                return Vector.down * (r.yMax - (cy - c.radius));
            } else {
                // circle is entirely within rectangle
                return rectRect(r, c.bounds);
            }
        }
    }

    // TODO
    private static function rectPoly(r: Rectangle, p: Polygon): Vector {
        final polygonBounds = p.bounds;

        if (!polygonBounds.intersects(r)) return Vector.zero;

		// if the bounds collide, then the Separating Axis cannot be among the rectangle's two axes.
		// therefore, we only need to check the axes defined by the sides of the polygon

        for (segment in p.toSegments()) {
            
        }



        // since the bounds of the polygon do intersect with the rectangle, then we know for sure
        // that no separating axis can be found among the x and y axes. However, in order to compute the
        // minimum penetration later on (in case of collision), we need to find the overlap of the polygon's bounds
        // with the rectangle's bounds wrt the x and y axes.

		final xPenetration = computeProjectionOverlap(r.xMin, r.xMax, polygonBounds.xMin, polygonBounds.xMax);
        final yPenetration = computeProjectionOverlap(r.yMin, r.yMax, polygonBounds.yMin, polygonBounds.yMax);


        // use the Separating axis theorem to check if they actually do intersect.
        // then, find the axis with the least overlap and return a vector normal to that 
        // axis pointing inwards whose magnitude is the found least overlap

        return Vector.zero;
    }

	// =========================================================================
    // CIRCLE METHODS
	// =========================================================================

    // TODO: test
    private static function circCirc(c1: Circle, c2: Circle): Vector {
        if (!c1.collideCircle(c2)) return Vector.zero;

        final toCenter = c2.center - c1.center;

        if (toCenter.lengthSq == 0) return Vector.down * (c1.radius + c2.radius);

        return toCenter.normalized * (c1.radius + c2.radius) - toCenter;
    }

    // TODO
    private static function circPoly(c: Circle, p: Polygon): Vector {
        return Vector.zero;
    }

	// =========================================================================
    // POLYGON METHODS
	// =========================================================================

    // TODO
    private static function polyPoly(p1: Polygon, p2: Polygon): Vector {
        return Vector.zero;
    }

	// =========================================================================
    // HELPER METHODS
	// =========================================================================

    /** Helper function for rectCirc */
    private static inline function cornerPenetration(center: Vector, radius: Float, corner: Vector): Vector {
        final toCenter = center - corner;
        return (toCenter.normalized * radius) - toCenter;
    }

    /** Helper function for polygon methods. Assuming no separation can be found along the axis, returns the overlap 
        of the projections of A and B unto the axis. Returns a positive float if the penetration of A in B points towards the max
        value, and returns a negative float if the penetration of A in B points towards the min value. **/
    private static inline function computeProjectionOverlap(minA: Float, maxA: Float, minB: Float, maxB: Float): Float {
        final aRight = maxA - minB;
        final aLeft = maxB - minA;
        return aRight <= aLeft ? aRight : -aLeft;
    }

    private static inline function hasProjectionOverlap(minA: Float, maxA: Float, minB: Float, maxB: Float): Bool {
        if (minA >= maxB) return false;
        if (maxA <= minB) return false;
        return true;
    }

}