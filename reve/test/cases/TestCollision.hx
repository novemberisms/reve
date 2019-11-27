package reve.test.cases;

import reve.math.Polygon;
import reve.collision.CollisionPolygon;
import reve.collision.CollisionPoint;
import reve.collision.CollisionCircle;
import reve.collision.CollisionRectangle;
import reve.math.Vector;
import reve.math.Rectangle;
import reve.math.Circle;
import utest.Test;
import utest.Assert;

import reve.collision.CollisionWorld;

class TestCollision extends Test {

    function testImpl() {
        Assert.pass();
    }

    function testAdd() {
        final world = new CollisionWorld(new Rectangle(Vector.zero, Vector.one * 1000));
        
        final rect = new CollisionRectangle(new Rectangle(Vector.zero, Vector.one));
        final circ = new CollisionCircle(new Circle(Vector.one * 100, 10));
        final point = new CollisionPoint(new Vector(100, 100));
        final polygon = new CollisionPolygon(new Polygon([Vector.up, Vector.right, Vector.down]));

        world.add(rect);
        world.add(circ);

        Assert.isTrue(world.has(rect));
        Assert.isTrue(world.has(circ));
        Assert.isFalse(world.has(point));
        Assert.isFalse(world.has(polygon));

        world.add(point);
        world.add(polygon);

        Assert.isTrue(world.has(point));
        Assert.isTrue(world.has(polygon));
    }
}
