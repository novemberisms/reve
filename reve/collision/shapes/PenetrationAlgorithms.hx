package reve.collision.shapes;

import reve.math.Circle;
import reve.math.Rectangle;
import reve.math.Vector;

class PenetrationAlgorithms {

    public static function getPenetration(shapeA: CollisionShape, shapeB: CollisionShape): Vector {

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

        if (lowest == distToLeft) return Vector.right * distToLeft;
        if (lowest == distToRight) return Vector.left * distToRight;
        if (lowest == distToTop) return Vector.down * distToTop;

        return Vector.up * distToBottom;
    }

    private static function rectRect(r1: Rectangle, r2: Rectangle): Vector {
        if (!r1.intersects(r2)) return Vector.zero;


        return Vector.zero;
    }

    private static function rectCirc(r: Rectangle, c: Circle): Vector {
        return Vector.zero;
    }

    private static function rectVec(r: Rectangle, v: Vector): Vector {
        return Vector.zero;
    }
}