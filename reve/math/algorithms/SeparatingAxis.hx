package reve.math.algorithms;

class SeparatingAxis {

    /** Gets the projection of the shape expressed as an array of points along the **unit vector** `axis`. 
        `points` must be at least length 3. **/
    public static function getShadow(points: Array<Vector>, axis: Vector): {min: Float, max: Float, minPoint: Vector, maxPoint: Vector} {
        var min = Math.POSITIVE_INFINITY;
        var max = Math.NEGATIVE_INFINITY;
        var minPoint = Vector.zero;
        var maxPoint = minPoint;

        for (point in points) {
            final projection = point.dot(axis);
            if (projection < min) {
                min = projection;
                minPoint = point;
            }
            if (projection > max) {
                max = projection;
                maxPoint = point;
            }
        }

        return {
            min: min,
            max: max,
            minPoint: minPoint,
            maxPoint: maxPoint,
        };
    }

	public static inline function testForSeparatingAxis(minA: Float, maxA: Float, minB: Float, maxB: Float): Bool {
		if (minA >= maxB) return true;
		if (maxA <= minB) return true;
		return false;
	}

	/** Assuming no separation can be found along the axis, returns the overlap 
		of the projections of A and B unto the axis. Returns a positive float if the penetration of A in B points towards the max
		value, and returns a negative float if the penetration of A in B points towards the min value. **/
	public static inline function getOverlap(minA: Float, maxA: Float, minB: Float, maxB: Float): Float {
		final rightOverlap = maxA - minB;
		final leftOverlap = maxB - minA;
		return rightOverlap <= leftOverlap ? rightOverlap : -leftOverlap;
	}
}