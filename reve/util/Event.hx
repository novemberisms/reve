package reve.util;

@:generic
abstract Event<T>(Array<T -> Void>) {

    public inline function new() {
        this = [];
    }

    public inline function execute(target: T) {
        for (fn in this) fn(target);
    }

    public inline function add(fn: T -> Void) {
        this.push(fn);
    }

    public inline function remove(fn: T -> Void) {
        this.remove(fn);
    }

    public inline function iterator(): Iterator<T -> Void> {
        return this.iterator();
    }

    @:generic
    @:op(A + B)
    private static inline function combine<T>(a: Event<T>, b: Event<T>): Event<T> {
        final result = new Event<T>();
        for (fn in a) result.add(fn);
        for (fn in b) result.add(fn);
        return result;
    }

    @:generic
    @:op(A += B)
    private static inline function addFn<T>(a: Event<T>, fn: T -> Void): Event<T> {
        a.add(fn);
        return a;
    }

    @:generic
    @:op(A + B)
    private static inline function addOpFn<T>(a: Event<T>, fn: T -> Void): Event<T> {
        final result = new Event<T>();
        for (existing in a) result.add(existing);
        result.add(fn);
        return result;
    }

}