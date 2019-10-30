package reve.util;

import haxe.ds.GenericStack;

class GenericStackExtender {
    public static function popMaybe<S>(s: GenericStack<S>): Maybe<S> {
        return s.pop();
    }

    public static function peek<S>(s: GenericStack<S>): Maybe<S> {
        return s.first();
    }
}