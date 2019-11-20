package reve.collision.shapes;

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
                }
			case rectangle(rA):
				switch (shapeB.shapeType) {
					case point(pB):
                        return -vecRect(pB.vector, rA.rectangle);
					case rectangle(rB):
					case circle(cB):
				}
			case circle(cA):
				switch (shapeB.shapeType) {
					case point(pB):
					case rectangle(rB):
					case circle(cB):
				}
        }
        return Vector.zero;
    }

    private static inline function vecVec(v1: Vector, v2: Vector): Vector {
        return Vector.zero;
    }

    // TODO: test
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

    // TODO: test
    private static function vecCirc(v: Vector, c: Circle): Vector {
        if (!c.contains(v)) return Vector.zero;

        final toCenter = c.center - v;

        final distanceToSide = c.radius - toCenter.length;

        return toCenter.normalized * distanceToSide;
    }

    private static function rectRect(r1: Rectangle, r2: Rectangle): Vector {
        if (!r1.intersects(r2)) return Vector.zero;


        return Vector.zero;
    }

    private static function rectCirc(r: Rectangle, c: Circle): Vector {
        return Vector.zero;
    }

}