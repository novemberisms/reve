package reve.test.cases;

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

        world.add(rect);
        world.add(circ);

        Assert.isTrue(world.has(rect));
        Assert.isTrue(world.has(circ));
        Assert.isFalse(world.has(point));

    }
}
