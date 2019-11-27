package reve.test.cases;

import reve.collision.CollisionPolygon;
import reve.math.algorithms.AngleEquate;
import hxd.Math;
import reve.collision.CollisionCircle;
import reve.collision.CollisionPoint;
import reve.collision.ICollisionShape;
import utest.Assert;
import utest.Test;

import reve.math.Vector;
import reve.collision.CollisionRectangle;

class TestShapes extends Test {

    //=============================================================================
    // HELPER FUNCTIONS
    //=============================================================================

    function overlapTest(shapeA: ICollisionShape, shapeB: ICollisionShape, expected: Bool, label: String) {
        // do the overlap test
        Assert.equals(expected, shapeA.collidesWith(shapeB), 'when overlap testing label "$label", expected an overlap of $expected but got ${!expected}');

        // this makes sure the collision overlap test is commutative.
        Assert.equals(expected, shapeB.collidesWith(shapeA), 'when overlap testing the reverse for label "$label", expected an overlap of $expected but got ${!expected}');
    }

	function penetrationTest(shapeA: ICollisionShape, shapeB: ICollisionShape, expected: Vector, label: String) {
        // do the penetration test
        final penetration = shapeA.getPenetration(shapeB);
		Assert.isTrue(expected == penetration, 'when penetration testing label "$label", expected penetration of $expected but got $penetration instead');
        
        // this makes sure that a penetration test works both ways.
        final reversePenetration = shapeB.getPenetration(shapeA);
        Assert.isTrue(-expected == reversePenetration, 'when penetration testing the reverse for label "$label", expected $expected but got $reversePenetration instead');
    }
    
    //=============================================================================
    // OVERLAP TESTS
    //=============================================================================

    function testPointPointOverlap() {
        overlapTest(CollisionPoint.from(10, 10), CollisionPoint.from(10, 10), true, "pp0");
    }

    function testPointRectOverlap() {
        overlapTest(CollisionPoint.from(5, 5), CollisionRectangle.from(0, 0, 10, 10), true, "pr0");
        overlapTest(CollisionPoint.from(10, 10), CollisionRectangle.from(0, 0, 10, 10), false, "pr1");
    }

    function testPointCircOverlap() {
        overlapTest(CollisionPoint.from(0, 10), CollisionCircle.from(Vector.zero, 10), false, "pc0");
    }

    function testPointPolyOverlap() {
        // final polygon = CollisionPolygon.from([Vector.zero, Vector.right, Vector.down]);
        final polygon = CollisionPolygon.from([Vector.zero, Vector.down, Vector.right]);
        overlapTest(CollisionPoint.from(0, 0), polygon, false, "gp0");
        overlapTest(CollisionPoint.from(0.5, 0), polygon, false, "gp1");
        overlapTest(CollisionPoint.from(1, 0), polygon, false, "gp2");
        overlapTest(CollisionPoint.from(0.5, 0.5), polygon, false, "gp3");
        overlapTest(CollisionPoint.from(0, 1), polygon, false, "gp4");
        overlapTest(CollisionPoint.from(0, 0.5), polygon, false, "gp5");

        overlapTest(CollisionPoint.from(0.4, 0.4), polygon, true, "gp6");
        overlapTest(CollisionPoint.from(0.1, 0.1), polygon, true, "gp7");
    }

    //=============================================================================
    // PENETRATION TESTS
    //=============================================================================

    function testPointRectPenetration() {
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
        penetrationTest(point, rect, Vector.right * 1, "pr0");
        point = CollisionPoint.from(centerX - 1, centerY);
        penetrationTest(point, rect, Vector.right * (halfWidth - 1), "pr1");
        // from the top
        point = CollisionPoint.from(centerX, startY + 1);
        penetrationTest(point, rect, Vector.down * 1, "pr2");
        point = CollisionPoint.from(centerX, centerY - 6);
        penetrationTest(point, rect, Vector.down * (halfHeight - 6), "pr3");
        // from the right
        point = CollisionPoint.from(endX - 1, centerY);
        penetrationTest(point, rect, Vector.left * 1, "pr4");
        point = CollisionPoint.from(centerX + 1, centerY);
        penetrationTest(point, rect, Vector.left * (halfWidth - 1), "pr5");
        // from the bottom
        point = CollisionPoint.from(centerX, endY - 1);
        penetrationTest(point, rect, Vector.up * 1, "pr6");
        point = CollisionPoint.from(centerX, centerY + 6);
        penetrationTest(point, rect, Vector.up * (halfHeight - 6), "pr7");

        // points on the edge should not be considered 'contained'
        point = CollisionPoint.from(startX, startY);
        penetrationTest(point, rect, Vector.zero, "pr8");
        point = CollisionPoint.from(centerX, startY);
        penetrationTest(point, rect, Vector.zero, "pr9");
        point = CollisionPoint.from(endX, startY);
        penetrationTest(point, rect, Vector.zero, "pr10");
        point = CollisionPoint.from(startX, centerY);
        penetrationTest(point, rect, Vector.zero, "pr11");
        point = CollisionPoint.from(endX, centerY);
        penetrationTest(point, rect, Vector.zero, "pr12");
        point = CollisionPoint.from(startX, endY);
        penetrationTest(point, rect, Vector.zero, "pr13");
        point = CollisionPoint.from(centerX, endY);
        penetrationTest(point, rect, Vector.zero, "pr14");
        point = CollisionPoint.from(endX, endY);
        penetrationTest(point, rect, Vector.zero, "pr15");

    }

    function testPointRectPenetrationTieBreakerPriority() {
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
        penetrationTest(CollisionPoint.from(halfSide, halfSide), square, Vector.down * halfSide, "centerSquareDown");
        // a point along the topleft diagonal of a square should return a vector pointing down
        penetrationTest(CollisionPoint.from(quarterSide, quarterSide), square, Vector.down * quarterSide, "topleftSquareDown");
        // a point along the topright diagonal should point down
        penetrationTest(CollisionPoint.from(endQuarterSide, quarterSide), square, Vector.down * quarterSide, "topRightSquareDown");
        // ... bottomleft .. up
        penetrationTest(CollisionPoint.from(quarterSide, endQuarterSide), square, Vector.up * quarterSide, "bottomLeftSquareUp");
        // ... bottomright ... up
        penetrationTest(CollisionPoint.from(endQuarterSide, endQuarterSide), square, Vector.up * quarterSide, "bottomRightSquareUp");

        // TODO: finish
    }

    function testPointCircPenetration() {
        final origin = Vector.zero;
        final radius = 10.0;

        final circle = CollisionCircle.from(origin, radius);

        var point: CollisionPoint;

        final edgeTestCount = 10;
        // points on the edge of the circle should have a penetration of 0
        for (i in 0...edgeTestCount) {
            final angle = (2 * Math.PI) * (i / edgeTestCount);
            final vector = origin + Vector.unit(angle) * radius;

            point = new CollisionPoint(vector);

            penetrationTest(point, circle, Vector.zero, 'pointCircEdge$i');
        }

        // a point that is at the center should return a penetration that
        // points down
        point = new CollisionPoint(origin);

        penetrationTest(point, circle, Vector.down * radius, "pointCircCenterDown");

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

    function testRectRectPenetration() {
        var r1: CollisionRectangle;
        var r2: CollisionRectangle;

        // TODO
        Assert.pass();
    }
}