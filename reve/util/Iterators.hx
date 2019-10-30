package reve.util;

typedef IterableWithLength<T> = Iterable<T> & {
    public var length(default, null): Int; 
}

@:generic
class Iterators {
    
    public static inline function reversed<T>(a: Array<T>): Iterator<T> {
        return new ReverseIterator(a);
    }

    public static inline function firstWhere<T>(a: Iterable<T>, fn: T -> Bool): Maybe<T> {
        var result: Maybe<T> = null;
        for (it in a) {
            if (fn(it)) {
                result = it;
                break;
            }
        }
        return result;
    }
}


@:generic
class ReverseIterator<T> {
    private var _index: Int;
    private final _array: Array<T>;

    public inline function new(array: Array<T>) {
        _index = array.length - 1;
        
        _array = array;
    }

    public inline function hasNext() return _index >= 0;
    public inline function next() return _array[_index--]; 
}