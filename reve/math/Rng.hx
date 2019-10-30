package reve.math;

import hxd.Rand;
import haxe.ds.Vector as Vec;

class Rng {
    /** This sets how many unique permutations the rng can have. This has to be a fixed number
        due to how Heaps uses a signed Int for seeding the rng. We can't just use Sys.time directly
        or else it will always overflow to about -2e10 every time. **/
    private static final _permutations = 10e8;
    private static var _rand: Rand;

    public static function init(?seed: Int) {
        if (seed == null) {
            seed = Std.int((Sys.time() * 1000) % _permutations);
        }
        trace('Rng seed: $seed');
        _rand = new Rand(seed);
    }

    /** Generates a pseudorandom integer from `min` to `max` inclusive. **/
    public static inline function int(min, max): Int {
        final diff = max - min + 1;
        return min + _rand.random(diff);
    }

    /** Generates a pseudorandom float from `min` inclusive to `max` exclusive. **/
    public static inline function float(min, max): Float {
        final diff = max - min;
        return min + _rand.srand(diff);
    }

    /** Chooses a random element from the array `arr` and returns it. **/
    public static inline function choose<T>(arr: Array<T>): T {
        if (arr.length == 0) return null;
        return arr[int(0, arr.length - 1)];
    }

    /** Similar to `choose` but for `Vec`s (`haxe.ds.Vector`). **/
    public static inline function chooseFrom<T>(vec: Vec<T>): T {
        if (vec.length == 0) return null;
        return vec[int(0, vec.length - 1)];
    }
}