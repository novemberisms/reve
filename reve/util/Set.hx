package reve.util;

import haxe.ds.StringMap;
import haxe.ds.IntMap;
import haxe.ds.ObjectMap;
import haxe.ds.EnumValueMap;
import haxe.Constraints.IMap;

@:multiType(@:followWithAbstracts T)
abstract Set<T>(IMap<T, Bool>) {

    /** Gets the number of elements within the set. **This traverses the entire set.** **/
    public var count(get, never): Int;

    public function new();

    public inline function add(element: T) {
        this.set(element, true);
    }

    public inline function remove(element: T) {
        this.remove(element);
    }

    public inline function contains(element: T): Bool {
        return this.exists(element);
    }

    public inline function iterator(): Iterator<T> {
        return this.keys();
    }

    /** Removes all elements from the set. **/
    public inline function empty() {
        for (keys in this.keys()) this.remove(keys);
    }

    /** Produces a new set whose contents are the union of this set and another set. **/
    @:generic
    public static function union<T>(setA: Set<T>, setB: Set<T>): Set<T> {
        final result = new Set<T>();

        for (element in setA) result.add(element);
        for (element in setB) result.add(element);

        return result;
    }

    /** Produces a new set whose contents are the intersection of this set and another set. **/
    @:generic
    public static function intersection<T>(setA: Set<T>, setB: Set<T>): Set<T> {
        final result = new Set<T>();

        for (element in setA) {
            if (setB.contains(element)) result.add(element);
        }

        return result;
    }

    @:generic
    public static function from<T>(iterable: Iterable<T>): Set<T> {
        final set = new Set<T>();

        for (element in iterable) set.add(element);

        return set;
    }

    private inline function get_count(): Int {
        var i = 0;
        for (element in this.keys()) i++;
        return i;
    }

	@:to static inline function toStringMap<K: String>(t: IMap<K, Bool>): StringMap<Bool> {
		return new StringMap<Bool>();
	}

	@:to static inline function toIntMap<K: Int>(t: IMap<K, Bool>): IntMap<Bool> {
		return new IntMap<Bool>();
	}

	@:to static inline function toEnumValueMapMap<K: EnumValue>(t: IMap<K, Bool>): EnumValueMap<K, Bool> {
		return new EnumValueMap<K, Bool>();
	}

	@:to static inline function toObjectMap<K: { }>(t: IMap<K, Bool>): ObjectMap<K, Bool> {
		return new ObjectMap<K, Bool>();
	}

}
