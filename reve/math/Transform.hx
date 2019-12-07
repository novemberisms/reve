package reve.math;

import h2d.col.Matrix;

abstract Transform(Matrix) from Matrix to Matrix {

    public var clone(get, never): Transform;

    public function new() {
        this = new Matrix();
    }

    public inline function scale(x: Float, y: Float): Transform {
        final copy = clone;
        copy.doScale(x, y);
        return copy;
    }

    public inline function translate(dx: Float, dy: Float): Transform {
        final copy = clone;
        copy.doTranslate(dx, dy);
        return copy;
    }

    public inline function rotate(angle: Float): Transform {
        final copy = clone;
        copy.doRotate(angle);
        return copy;
    }

    public inline function translateV(translation: Vector): Transform {
        return translate(translation.x, translation.y);
    }

    public inline function doScale(x: Float, y: Float) {
        this.scale(x, y);
    }

    public inline function doTranslate(dx: Float, dy: Float) {
        this.translate(dx, dy);
    }

    public inline function doRotate(angle: Float) {
        this.rotate(angle);
    }

    private inline function get_clone(): Transform {
        final copy = new Matrix();
        copy.a = this.a;
        copy.b = this.b;
        copy.c = this.c;
        copy.d = this.d;
        copy.x = this.x;
        copy.y = this.y;
        return copy;
    }
}