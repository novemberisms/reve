package reve.test.cases;

import utest.Test;
import utest.Assert;
import reve.math.Vector;
import h2d.col.Point;

class TestVector extends Test {

    function testCreate() {
        final v = new Vector(3.0, 4.0);

        Assert.equals(3.0, v.x);
        Assert.equals(4.0, v.y);
    }

    function testCreateZero() {
        final z = new Vector();

        Assert.equals(0.0, z.x);
        Assert.equals(0.0, z.y);
    }

    function testCreateWithInts() {
        final x: Int = 3;
        final y: Int = 4;
        final i = new Vector(x, y);
        Assert.equals(3.0, i.x);
        Assert.equals(4.0, i.y);
    }

    function testCreateFromPoint() {
        final p = new Point(3.0, 4.0);
        final v: Vector = p;
        
        Assert.equals(3.0, v.x);
        Assert.equals(4.0, v.y);
    }

    function testAssignToPoint() {
        var p = new Point();
        var v = new Vector();

        p = v;

        Assert.pass();
    }

    function testEqual() {
        final a = new Vector(3, 4);
        final b = new Vector(3, 4);
        final c = new Vector(1, 2);

        Assert.isTrue(a == b);
        Assert.isFalse(a == c);
        Assert.isFalse(b == c);

        final x: Vector = null;
        Assert.isTrue(x == null);
        Assert.isFalse(a == x);
        final y: Vector = null;
        Assert.isTrue(x == y);

        final e = new Entity(new Vector(10, 20));

        if (e.pos == new Vector(10, 20)) {
            Assert.pass();
        } else {
            Assert.fail();
        }

        function f(): Bool return a == b;

        Assert.isTrue(f());
    }

    function testNotEqual() {
        final a = new Vector(3, 4);
        final b = new Vector(3, 4);
        final c = new Vector(1, 2);

        Assert.isFalse(a != b);
        Assert.isTrue(a != c);
        Assert.isTrue(b != c);
    }

    function testModify() {
        final v = new Vector(3.0, 4.0);

        v.x = 12.0;
        v.y = -999.0;

        Assert.equals(12.0, v.x);
        Assert.equals(-999.0, v.y);
    }

    function testToString() {
        final v = new Vector(3, 4);

        Assert.equals("Vector{3, 4}", v.toString());
        Assert.equals("Vector{3, 4}", '$v');
    }

    function testAdd() {
        final p = new Vector(3, 4);
        final q = new Vector(5, 6);

        final s = p + q;

        Assert.equals(8.0, s.x);
        Assert.equals(10.0, s.y);
    }

    function testIncrement() {
        var p = new Vector(3, 4);

        p += new Vector(-3, -4);
        p += new Vector(1, 2);
        
        Assert.equals(1, p.x);
        Assert.equals(2, p.y);

        final e = new Entity(p);

        e.pos += new Vector(9, 9);

        Assert.equals(10, e.pos.x);
        Assert.equals(11, e.pos.y);
        Assert.equals(1, p.x);
        Assert.equals(2, p.y);
    }

    function testSub() {
        final p = new Vector(3, 4);
        final q = new Vector(1, 2);

        final s = p - q;

        Assert.equals(2, s.x);
        Assert.equals(2, s.y);

        final p1 = new Vector(-10, 24);
        final q1 = new Vector(-3, -4);

        final s1 = p1 - q1;

        Assert.equals(-7, s1.x);
        Assert.equals(28, s1.y);
    }

    function testDecrement() {
        var p = new Vector(3, 4);

        p -= new Vector(1, 3);

        Assert.equals(2, p.x);
        Assert.equals(1, p.y);

        final e = new Entity(p);

        e.pos -= new Vector(9, 9);

        Assert.equals(-7, e.pos.x);
        Assert.equals(-8, e.pos.y);
        Assert.equals(2, p.x);
        Assert.equals(1, p.y);
    }

    function testNegate() {
        final q1 = new Vector(3, 4);
        final q2 = new Vector(-5, 6);
        final q3 = new Vector(-7, -8);
        final q4 = new Vector(9, -10);

        final r1 = -q1;
        final r2 = -q2;
        final r3 = -q3;
        final r4 = -q4;

        Assert.isTrue(r1 == new Vector(-3, -4));
        Assert.isTrue(r2 == new Vector(5, -6));
        Assert.isTrue(r3 == new Vector(7, 8));
        Assert.isTrue(r4 == new Vector(-9, 10));
    }

    function testLengthSq() {
        final p1 = new Vector(3, 4);
        Assert.equals(25, p1.lengthSq);

        final p2 = new Vector(-3, 10);
        Assert.equals(109, p2.lengthSq);

        final z = new Vector();
        Assert.equals(0, z.lengthSq);
    
        final i = new Vector(Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY);
        Assert.equals(Math.POSITIVE_INFINITY, i.lengthSq);

        final iz = new Vector(Math.POSITIVE_INFINITY, 0);
        Assert.equals(Math.POSITIVE_INFINITY, iz.lengthSq);
    }

    function testLength() {
        final p1 = new Vector(3, 4);
        Assert.equals(5, p1.length);

        final p2 = new Vector(1, 2);
        Assert.floatEquals(Math.sqrt(5), p2.length);

        final z = new Vector();
        Assert.equals(0, z.length);
    }

    function testAngle() {
        final p1 = new Vector();
        // the zero vector has angle of 0
        Assert.equals(0, p1.angle);

        final root3 = Math.sqrt(3);
        final pi = Math.PI;

        // 0 degrees
        final p2 = new Vector(1, 0);
        Assert.equals(0, p2.angle);

        // 30 degrees
        final p3 = new Vector(root3/2, 1/2);
        Assert.floatEquals(pi / 6, p3.angle);

        // 45 degrees
        final p4 = new Vector(1, 1);
        Assert.floatEquals(pi / 4, p4.angle);

        // 60 degrees
        final p5 = new Vector(1/2, root3/2);
        Assert.floatEquals(pi / 3, p5.angle);

        // 90 degrees
        final p6 = new Vector(0, 1);
        Assert.floatEquals(pi / 2, p6.angle);

        // 120 degrees
        final p7 = new Vector(-1/2, root3/2);
        Assert.floatEquals(2*pi / 3, p7.angle);

        // 135 degrees
        final p8 = new Vector(-1, 1);
        Assert.floatEquals(3*pi / 4, p8.angle);

        // 150 degrees
        final p9 = new Vector(-root3/2, 1/2);
        Assert.floatEquals(5*pi / 6, p9.angle);

        // 180 degrees
        final p10 = new Vector(-1, 0);
        Assert.floatEquals(pi, p10.angle);

        // 210 degrees
        final p11 = new Vector(-root3/2, -1/2);
        Assert.floatEquals(-5 * pi / 6, p11.angle);

        // 225 degrees
        final p12 = new Vector(-1, -1);
        Assert.floatEquals(-3*pi/4, p12.angle);

        // 240 degrees
        final p13 = new Vector(-1/2, -root3/2);
        Assert.floatEquals(-2*pi/3, p13.angle);

        // 270 degrees
        final p14 = new Vector(0, -1);
        Assert.floatEquals(-pi/2, p14.angle);

        // 300 degrees
        final p15 = new Vector(1/2, -root3/2);
        Assert.floatEquals(-pi/3, p15.angle);

        // 315 degrees
        final p16 = new Vector(1, -1);
        Assert.floatEquals(-pi/4, p16.angle);

        // 330 degrees
        final p17 = new Vector(root3/2, -1/2);
        Assert.floatEquals(-pi/6, p17.angle);
    }

    function testNormalized() {
        final a = new Vector(120, -120);
        final a_n = a.normalized;

        final root2 = Math.sqrt(2);

        Assert.floatEquals(1, a_n.length);
        Assert.floatEquals(root2/2, a_n.x);
        Assert.floatEquals(-root2/2, a_n.y);

        final b = new Vector(0, 0);
        Assert.raises(() -> { b.normalized; }, NormalizeZeroException);
    }

    function testMultiplyVectors() {
        final p = new Vector(3, 4);
        final q = new Vector(5, 6);

        final s = p * q;

        Assert.equals(15, s.x);
        Assert.equals(24, s.y);
    }

    function testMultiplyFloat() {
        final p = new Vector(3, 4);
        final f = 5.0;

        Assert.isTrue(p * f == new Vector(15, 20));
        Assert.isTrue(f * p == new Vector(15, 20));
    }

    function testDivideVectors() {
        final p = new Vector(3, 4);
        final q = new Vector(6, 8);

        final s = p / q;

        Assert.equals(0.5, s.x);
        Assert.equals(0.5, s.y);

        final t = q / p;

        Assert.equals(2, t.x);
        Assert.equals(2, t.y);
    }

    function testDivideFloat() {
        final p = new Vector(3, 4);
        final f = 5.0;

        final s = p / f;

        Assert.equals(3/5, s.x);
        Assert.equals(4/5, s.y);

        final t = f / p;

        Assert.equals(5/3, t.x);
        Assert.equals(5/4, t.y);
    }

    function testModulo() {
        final p = new Vector(3, 4);
        final s = p % 2;

        Assert.equals(1, s.x);
        Assert.equals(0, s.y);
    }

    function testMultiplyInPlace() {
        var p = new Vector(3, 4);
        var q = new Vector(5, 6);

        p *= q;

        Assert.equals(15, p.x);
        Assert.equals(24, p.y);

        p *= -3;
        
        Assert.equals(-45, p.x);
        Assert.equals(-72, p.y);
    }

    function testDivideInPlace() {
        var p = new Vector(240, 360);
        var q = new Vector(3, 4);

        p /= q;

        Assert.equals(80, p.x);
        Assert.equals(90, p.y);

        p /= 10;

        Assert.equals(8, p.x);
        Assert.equals(9, p.y);
    }

    function testDivideByZero() {
        final p = new Vector(3, 4);
        final z = new Vector(1, 0);
        Assert.raises(() -> { p / z; }, VectorDivideByZeroException);
        Assert.raises(() -> { p / 0; }, VectorDivideByZeroException);
        Assert.raises(() -> { 1 / z; }, VectorDivideByZeroException);
    }
    
}

private class Entity {
    public var pos: Vector;

    public function new(pos: Vector) {
        this.pos = pos;
    }
}
