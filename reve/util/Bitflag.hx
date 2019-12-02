package reve.util;

import hxd.impl.UInt16;

abstract Bitflag(UInt16) from UInt16 to UInt16 {

    public static final maxPosition = 15;

	public inline function new(int: UInt16 = 0) {
        this = int;
    }

    public static inline function fromArray(array: Array<Bool>): Bitflag {
        final bitflag = new Bitflag();
        
        for (i in 0...array.length) {
            if (array[i]) bitflag.set(i, array[i]);
        }
        
        return bitflag;
    }

    public inline function set(position: Int, value: Bool) {
#if !skipAsserts
        if (position > maxPosition || position < 0) throw 'Bitflags are limited to positions 0 - $maxPosition';
#end
        if (value) {
            this = this | (1 << position);
        } else {
            final mask: UInt16 = ~(1 << position);
            this = this & mask;
        }
    }

    public inline function get(position: Int): Bool {
#if !skipAsserts
        if (position > maxPosition || position < 0) throw 'Bitflags are limited to positions 0 - $maxPosition';
#end
        return this & (1 << position) != 0;
    }

    public inline function testAny(mask: Bitflag): Bool {
        final maskInt: UInt16 = mask;

        final result = this & maskInt;

        return result != 0;
    }

    public inline function testAll(mask: Bitflag): Bool {
        final maskInt: UInt16 = mask;

        final result = this & maskInt;

        return result == maskInt;
    }

}