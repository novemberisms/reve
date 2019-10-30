package reve.math;

using Lambda;

interface ITimeAverage<T> {
    public var value(get, never): T;
    public function update(dt: Float): Void;
    public function send(value: T): Void;
}

class TimeAverage implements ITimeAverage<Float> {

    public var value(get, never): Float;
    
    private final _timespan: Float;
    private final _times: Array<Float> = [];
    private final _data: Array<Float> = [];

    private var _time = 0.0;

    public function new(initialValue: Float, timespan: Float) {
        _timespan = timespan;
        _data.push(initialValue);
        _times.push(0.0);
    }

    public function update(dt: Float) {
        _time += dt;

        var earliestValueToKeep = _data[0];

        while (_times.length > 0) {

            final t = _times[0];

            if (t <= _time - _timespan) {
                
                final val = _data[0];
                earliestValueToKeep = val;
                
                _times.shift();
                _data.shift();
            } else {
                break;
            }
        }

        _times.insert(0, _time - _timespan);
        _data.insert(0, earliestValueToKeep);
    }

    public inline function send(value: Float) {
        final lastTime = _times[_times.length - 1];
        if (_time == lastTime) {
            _data[_data.length - 1] = value;
        } else {
            _times.push(_time);
            _data.push(value);
        }
    }

    private function get_value(): Float {
        if (_data.length == 1) return _data[0];

        var total = 0.0;

        for (i in 0..._times.length - 1) {
            final value = _data[i];
            final delta = _times[i + 1] - _times[i];
            total += value * delta;
        }

        final lastDelta = _time - _times[_times.length - 1];
        final lastValue = _data[_data.length - 1];
        total += lastValue * lastDelta;

        return total / _timespan;
    }
}

class VectorTimeAverage implements ITimeAverage<Vector> {

    public var value(get, never): Vector;

    private final _xAverage: TimeAverage;
    private final _yAverage: TimeAverage;

    public function new(initialValue: Vector, timespan: Float) {
        _xAverage = new TimeAverage(initialValue.x, timespan);
        _yAverage = new TimeAverage(initialValue.y, timespan);
    }

    public inline function update(dt: Float) {
        _xAverage.update(dt);
        _yAverage.update(dt);
    }

    public inline function send(value: Vector) {
        _xAverage.send(value.x);
        _yAverage.send(value.y);
    }

    private inline function get_value(): Vector {
        return new Vector(_xAverage.value, _yAverage.value);
    }
}