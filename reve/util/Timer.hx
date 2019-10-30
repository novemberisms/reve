package reve.util;

/** Remember that you have to start the timer. **/
class Timer {

    public var timeLeft(default, null): Float;
    public var period(default, null): Float;
    public var ongoing(default, null) = false;

    public var frequency(get, never): Float;
    public var completion(get, never): Float;
    public var remaining(get, never): Float;

    public function new(period: Float) {
        this.period = period;
        this.timeLeft = period;
    }

    public function start() {
        timeLeft = period;
        ongoing = true;
    }

    public function pause() {
        ongoing = false;
    }

    public function unpause() {
        ongoing = true;
    }

    /** Updates the timer and returns `true` if it expired in doing so. **/
    public function update(dt: Float): Bool {
        if (!ongoing) return false;

        timeLeft -= dt;
        if (timeLeft > 0) return false;

        // for maximum accuracy
        while (timeLeft < 0) timeLeft += period;

        return true;
    }

    public function setPeriod(newPeriod: Float) {
        period = newPeriod;
        if (timeLeft > period) timeLeft = period;
    }

    private inline function get_frequency(): Float return 1 / period;

    private inline function get_completion(): Float return 1 - timeLeft / period;

    private inline function get_remaining(): Float return timeLeft / period;
}

class OneShotTimer extends Timer {

    public override function update(dt: Float) {
        if (!ongoing) return false;

        timeLeft -= dt;
        if (timeLeft > 0) return false;
        
        timeLeft = 0;
        ongoing = false;

        return true;
    }
}