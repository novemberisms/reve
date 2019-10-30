package reve.util;

abstract Maybe<T>(Null<T>) from Null<T> {

    public inline function exists(): Bool {
        return this != null;
    }

    public inline function sure(): T {
        return exists() ? this : throw "No value";
    }

    public inline function or(other: T): T {
        return exists() ? this : other;
    }

    public inline function may(fn: (T)-> Void): Void {
        if (exists()) fn(this);
    }

    public inline function map<S>(fn: (T)-> S): Maybe<S> {
        return exists() ? fn(this) : null;
    }
}
