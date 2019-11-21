package reve.test.cases;

import reve.math.algorithms.AngleEquate;
import hxd.Math;
import reve.collision.shapes.CollisionCircle;
import reve.collision.shapes.CollisionPoint;
import reve.collision.shapes.ICollisionShape;
import utest.Assert;
import utest.Test;

import reve.math.Vector;
import reve.collision.shapes.CollisionRectangle;

class TestCollisionShapePenetration extends Test {

	function doTest(shapeA: ICollisionShape, shapeB: ICollisionShape, expected: Vector, label: String) {
        // do the penetration test
        final penetration = shapeA.getPenetration(shapeB);
		Assert.isTrue(expected == penetration, 'when testing label "$label", expected penetration of $expected but got $penetration instead');
        
        // this makes sure that a penetration test works both ways.
        final reversePenetration = shapeB.getPenetration(shapeA);
        Assert.isTrue(-expected == reversePenetration, 'when testing the reverse penetration for label "$label", expected $expected but got $reversePenetration instead');
    }

    function testPointRect() {
        final startX = 10.0;
        final startY = 20.0;
        final width = 30.0;
        final height = 40.0;
        final centerX = startX + width / 2;
        final centerY = startY + height / 2;
        final endX = startX + width;
        final endY = startY + height;
        final halfWidth = width / 2;
        final halfHeight = height / 2;

        final rect = CollisionRectangle.from(startX, startY, width, height);
        var point: CollisionPoint;

        // from the left
        point = CollisionPoint.from(startX + 1, centerY);
        doTest(point, rect, Vector.right * 1, "pr0");
        point = CollisionPoint.from(centerX - 1, centerY);
        doTest(point, rect, Vector.right * (halfWidth - 1), "pr1");
        // from the top
        point = CollisionPoint.from(centerX, startY + 1);
        doTest(point, rect, Vector.down * 1, "pr2");
        point = CollisionPoint.from(centerX, centerY - 6);
        doTest(point, rect, Vector.down * (halfHeight - 6), "pr3");
        // from the right
        point = CollisionPoint.from(endX - 1, centerY);
        doTest(point, rect, Vector.left * 1, "pr4");
        point = CollisionPoint.from(centerX + 1, centerY);
        doTest(point, rect, Vector.left * (halfWidth - 1), "pr5");
        // from the bottom
        point = CollisionPoint.from(centerX, endY - 1);
        doTest(point, rect, Vector.up * 1, "pr6");
        point = CollisionPoint.from(centerX, centerY + 6);
        doTest(point, rect, Vector.up * (halfHeight - 6), "pr6");
    }

    function testPointRectTieBreakerPriority() {
        final side = 10.0;
        final halfSide = side / 2;
        final quarterSide = side / 4;
        final endQuarterSide = quarterSide * 3;

        final longSide = side * 2;
        final quarterLongSide = longSide / 4;
        final endQuarterLongSide = quarterLongSide * 3;
        
        final square = CollisionRectangle.from(0, 0, side, side);
        final wideRect = CollisionRectangle.from(0, 0, longSide, side);
        final tallRect = CollisionRectangle.from(0, 0, side, longSide);


        // a point in the center of a square should return a vector pointing down
        doTest(CollisionPoint.from(halfSide, halfSide), square, Vector.down * halfSide, "centerSquareDown");
        // a point along the topleft diagonal of a square should return a vector pointing down
        doTest(CollisionPoint.from(quarterSide, quarterSide), square, Vector.down * quarterSide, "topleftSquareDown");
        // a point along the topright diagonal should point down
        doTest(CollisionPoint.from(endQuarterSide, quarterSide), square, Vector.down * quarterSide, "topRightSquareDown");
        // ... bottomleft .. up
        doTest(CollisionPoint.from(quarterSide, endQuarterSide), square, Vector.up * quarterSide, "bottomLeftSquareUp");
        // ... bottomright ... up
        doTest(CollisionPoint.from(endQuarterSide, endQuarterSide), square, Vector.up * quarterSide, "bottomRightSquareUp");

    }

    function testPointCirc() {
        final origin = Vector.zero;
        final radius = 10.0;

        final circle = CollisionCircle.from(origin, radius);

        var point: CollisionPoint;

        // a point that is at the center should return a penetration that
        // points down
        point = new CollisionPoint(origin);

        doTest(point, circle, Vector.down * radius, "pointCircCenterDown");

        // spiral test

        final testCount = 10;
        final angleInc = 2 * Math.PI / testCount;
        final distInc = (radius - 2) / testCount;

        var dist = 1.0;
        var angle = 0.0;

        for (i in 0...testCount) {
            final vector = origin + Vector.unit(angle) * dist;

            point = new CollisionPoint(vector);

            final penetration = point.getPenetration(circle);

            // the magnitude of the penetration must be from the outer edge of the circle
            // to the current distance

            Assert.floatEquals(radius - dist, penetration.length);
            
            // the penetration must be pointing inwards towards the center of the
            // circle

            final sameAngle = AngleEquate.angleEquals(
                angle + Math.PI,
                penetration.angle 
            );

            Assert.isTrue(sameAngle);
            
            angle += angleInc;
            dist += distInc;

        }
    }

    function testRectRect() {
        var r1: CollisionRectangle;
        var r2: CollisionRectangle;

        // TODO
        Assert.pass();
    }
}