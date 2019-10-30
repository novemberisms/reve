package reve.test.cases;

import reve.math.Rectangle;
import reve.math.Vector;
import utest.Test;
import utest.Assert;
import reve.spatialhash.SpatialHash;

private class Entity {
    
    public final bounds: Rectangle;
    
    public function new(x: Float, y: Float, width: Float, height: Float) {
        bounds = new Rectangle(new Vector(x, y), new Vector(width, height));
    }
}


class TestSpatialHash extends Test {

    function testCreation() {

        final s = new SpatialHash<Entity>(
            new Rectangle(Vector.zero, Vector.one * 100),
            new Vector(10, 10)    
        );

        Assert.pass();

    }
}
