package reve.math;

import h2d.col.Point;

abstract Vector(Point) from Point to Point {

    public var x(get, set): Float;
    public var y(get, set): Float;

    public var length(get, never): Float;
    public var lengthSq(get, never): Float;
    public var angle(get, never): Float;
    public var normalized(get, never): Vector;
    public var copy(get, never): Vector;

    public inline function new(x: Float = 0.0, y: Float = 0.0) {
        this = new Point(x, y);
    }

    public inline function toString(): String {
        return 'Vector{$x, $y}';
    }

    public inline function dot(v: Vector): Float {
        return this.x * v.x + this.y * v.y;
    }

    public inline function cross(v: Vector): Float {
        return this.x * v.y - v.x * this.y;
    }

    public inline function rotated(amount: Float): Vector {
        final cos = Math.cos(amount);
        final sin = Math.sin(amount);
        return new Vector(x * cos - y * sin, x * sin + y * cos);
    }

    public function closeEnough(v: Vector, epsilon: Float = 0.001): Bool {
        if (Math.abs(x - v.x) > epsilon) return false;
        if (Math.abs(y - v.y) > epsilon) return false;
        return true;
    }

    /** Returns a vector pointing in the same direction whose magnitude is clamped 
        between `min` and `max`. **/
    public function clamped(min: Float, max: Float): Vector {
        if (lengthSq < min * min) return normalized * min;
        if (lengthSq > max * max) return normalized * max;
        return copy;
    }

    /** If this vector's length is less than `minimumLength`, it will return a vector
        pointing in the same direction whose length is clamped.  **/
    public function min(minimumLength: Float): Vector {
        if (lengthSq < minimumLength * minimumLength) return normalized * minimumLength;
        return copy;
    }

    /** If this vector's length is more than `maximumLength`, it will return a vector
        pointing in the same direction whose length is clamped.  **/
    public function max(maximumLength: Float): Vector {
        if (lengthSq > maximumLength * maximumLength) return normalized * maximumLength;
        return copy;
    }

    public inline function floor(): Vector {
        return new Vector(Math.floor(x), Math.floor(y));
    }

    private inline function get_x(): Float return this.x;
    private inline function get_y(): Float return this.y;
    private inline function set_x(val): Float return this.x = val;
    private inline function set_y(val): Float return this.y = val;

    private inline function get_lengthSq(): Float return x * x + y * y;
    private inline function get_length(): Float return Math.sqrt(lengthSq);
    private inline function get_angle(): Float return Math.atan2(y, x);
    private inline function get_copy(): Vector return new Vector(x, y);

    private inline function get_normalized(): Vector {
        final mag = length;
        if (mag == 0) throw new NormalizeZeroException("Cannot normalize a zero vector.");
        return new Vector(x / mag, y / mag);
    }

    @:op(A + B)
    private static inline function add(a: Vector, b: Vector): Vector {
        return new Vector(a.x + b.x, a.y + b.y);
    }

    @:op(A += B)
    private static inline function addWith(a: Vector, b: Vector): Vector {
        a.x += b.x;
        a.y += b.y;
        return a;
    }

    @:op(A - B)
    private static inline function sub(a: Vector, b: Vector): Vector {
        return new Vector(a.x - b.x, a.y - b.y);
    }

    @:op(A -= B)
    private static inline function subWith(a: Vector, b: Vector): Vector {
        a.x -= b.x;
        a.y -= b.y;
        return a;
    }

    @:op(A == B)
    private static inline function equals(a: Vector, b: Vector): Bool {
        if (a == null && b == null) return true;
        if (a == null) return false;
        if (b == null) return false;
        
        return a.x == b.x && a.y == b.y;
    }

    @:op(A != B)
    private static inline function notEquals(a: Vector, b: Vector): Bool {
        return !equals(a, b);
    }

    @:op(-A)
    private static inline function negate(a: Vector): Vector {
        return new Vector(-a.x, -a.y);
    }

    @:op(A * B)
    private static inline function mul(a: Vector, b: Vector): Vector {
        return new Vector(a.x * b.x, a.y * b.y);
    }

    @:op(A * B)
    @:commutative
    private static inline function mulf(a: Vector, f: Float): Vector {
        return new Vector(a.x * f, a.y * f);
    }

    @:op(A *= B)
    private static inline function mulWith(a: Vector, b: Vector): Vector {
        a.x *= b.x;
        a.y *= b.y;
        return a;
    }

    @:op(A *= B)
    private static inline function mulfWidth(a: Vector, f: Float): Vector {
        a.x *= f;
        a.y *= f;
        return a;
    }

    @:op(A / B)
    private static inline function div(a: Vector, b: Vector): Vector {
        if (b.x == 0 || b.y == 0) throw new VectorDivideByZeroException("Divisor vector has 0 component");
        return new Vector(a.x / b.x, a.y / b.y);
    }

    @:op(A / B)
    private static inline function divf(a: Vector, f: Float): Vector {
        if (f == 0) throw new VectorDivideByZeroException("Divisor float equals 0");
        return new Vector(a.x / f, a.y / f);
    }

    @:op(A / B)
    private static inline function fdiv(f: Float, a: Vector): Vector {
        if (a.x == 0 || a.y == 0) throw new VectorDivideByZeroException("Divisor vector has 0 component");
        return new Vector(f / a.x, f / a.y);
    }

    @:op(A /= B)
    private static inline function divWith(a: Vector, b: Vector): Vector {
        a.x /= b.x;
        a.y /= b.y;
        return a;
    }

    @:op(A / B)
    private static inline function divfWith(a: Vector, f: Float): Vector {
        a.x /= f;
        a.y /= f;
        return a;
    }

    @:op(A % B)
    private static inline function mod(a: Vector, i: Int): Vector {
        return new Vector(a.x % i, a.y % i);
    }

    public static var zero(get, never): Vector;
    public static var one(get, never): Vector;
    public static var up(get, never): Vector;
    public static var down(get, never): Vector;
    public static var left(get, never): Vector;
    public static var right(get, never): Vector;

    /** Returns a unit vector pointing towards `angle`. **/
    public static inline function unit(angle: Float): Vector {
        return new Vector(Math.cos(angle), Math.sin(angle));
    }

    private static inline function get_zero() {
        return new Vector();
    }
    private static inline function get_one() {
        return new Vector(1, 1);
    }
    private static inline function get_up() {
        return new Vector(0, -1);
    }
    private static inline function get_down() {
        return new Vector(0, 1);
    }
    private static inline function get_left() {
        return new Vector(-1, 0);
    }
    private static inline function get_right() {
        return new Vector(1, 0);
    }

}

class NormalizeZeroException extends Exception {}

class VectorDivideByZeroException extends Exception {}