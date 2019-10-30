package reve.math;

class ExponentialExtrapolator {

    public var value(default, null): Float;

    private final _initialValue: Float;
    private final _finalValue: Float;
    private final _minimumSpeed: Float;
    private final _coefficient: Float;
    private final _totalChange: Float;

    public function new(initialValue: Float, finalValue: Float, settlingTime: Float = 1.0, minimumSpeed: Float = 1.0) {
        _initialValue = initialValue;
        _finalValue = finalValue;
        _minimumSpeed = minimumSpeed;
        _coefficient = 5 / settlingTime;
        _totalChange = finalValue - initialValue;

        value = initialValue;
    }

    public function update(dt: Float) {
        if (value == _finalValue) return;

        final diff = _finalValue - value;

        var velocity = diff * _coefficient;

        if (Math.abs(velocity) < _minimumSpeed) {
            velocity = sign(diff) * _minimumSpeed;
        }

        value += velocity * dt;

        final delta = value - _initialValue;

        if (Math.abs(delta) > Math.abs(_totalChange)) value = _finalValue;
    }

    private static inline function sign(v: Float): Float {
        return v < 0 ? -1 : (v > 0 ? 1 : 0);
    }
}

class VectorExponentialExtrapolator {

    public var value(default, null): Vector;

    private final _initialValue: Vector;
    private final _finalValue: Vector;
    private final _minimumSpeed: Float;
    private final _coefficient: Float;
    private final _totalChange: Vector;

    public function new(initialValue: Vector, finalValue: Vector, settlingTime: Float = 1.0, minimumSpeed: Float = 1.0) {
        _initialValue = initialValue;
        _finalValue = finalValue;
        _minimumSpeed = minimumSpeed;
        _coefficient = 5 / settlingTime;
        _totalChange = finalValue - initialValue;
        
        value = initialValue.copy;
    }

    public function update(dt: Float) {
        if (value == _finalValue) return;

        final diff = _finalValue - value;

        final velocity = (diff * _coefficient).min(_minimumSpeed);

        value += velocity * dt;

        final delta = value - _initialValue;

        if (delta.lengthSq > _totalChange.lengthSq) value = _finalValue;
    }
}

class RectangleExponentialExtrapolator {

    public var value(default, null): Rectangle;

    private final _positionExtrapolator: VectorExponentialExtrapolator;
    private final _sizeExtrapolator: VectorExponentialExtrapolator;
    private final _usesTopLeft: Bool;

    public function new(
        initialValue: Rectangle, 
        finalValue: Rectangle, 
        useTopLeft: Bool = false,
        settlingTime: Float = 1.0, 
        minimumPositionSpeed: Float = 1.0, 
        minimumSizeSpeed: Float = 1.0
    ) {
        _usesTopLeft = useTopLeft;

        _positionExtrapolator = new VectorExponentialExtrapolator(
            useTopLeft ? initialValue.topleft : initialValue.center,
            useTopLeft ? finalValue.topleft : finalValue.center,
            settlingTime,
            minimumPositionSpeed
        );

        _sizeExtrapolator = new VectorExponentialExtrapolator(
            initialValue.size,
            finalValue.size,
            settlingTime,
            minimumSizeSpeed
        );

        value = initialValue.copy;
    }

    public function update(dt: Float) {
        _positionExtrapolator.update(dt);
        _sizeExtrapolator.update(dt);

        if (_usesTopLeft) {
            value.topleft = _positionExtrapolator.value;
            value.size = _sizeExtrapolator.value;
        } else {
            value.center = _positionExtrapolator.value;
            value.resizeFromCenter(_sizeExtrapolator.value);
        }

    }
}
