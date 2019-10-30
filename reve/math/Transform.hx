package reve.math;

class Transform {

    public var translation: Vector;
    public var scale: Vector;
    public var rotation: Float;

    public function new(?translation: Vector, ?scale: Vector, ?rotation: Float) {
        this.translation = translation == null ? Vector.zero : translation;
        this.scale = scale == null ? Vector.one : scale;
        this.rotation = rotation == null ? 0 : rotation;
    }

    public inline function translated(translation: Vector): Transform {
        return new Transform(this.translation + translation, scale, rotation);
    }

    public inline function scaled(scale: Vector): Transform {
        return new Transform(translation, this.scale * scale, rotation);
    }

    public inline function rotated(rotation: Float): Transform {
        return new Transform(translation, scale, this.rotation + rotation);
    }
}