package reve.input;

import reve.math.Vector;
import reve.util.Maybe;
import hxd.Pad;

class Gamepad {

    public static var connected(get, never): Bool;

    private static var _gamepad: Maybe<Pad>;

    public static inline function init() {
        Pad.wait(onConnect);
    }

    public static inline function isDown(btn: Int): Bool {
        if (!_gamepad.exists()) return false;
        return _gamepad.sure().isDown(btn);
    }

    public static inline function isPressed(btn: Int): Bool {
        if (!_gamepad.exists()) return false;
        return _gamepad.sure().isPressed(btn);
    }

    public static inline function isReleased(btn: Int): Bool {
        if (!_gamepad.exists()) return false;
        return _gamepad.sure().isReleased(btn);
    }

    public static function getAnalog(): Vector {
        if (!_gamepad.exists()) return Vector.zero;
        final gamepad = _gamepad.sure();
        return new Vector(gamepad.xAxis, gamepad.yAxis);
    }

    public static function getValue(which: Int): Float {
        if (!_gamepad.exists()) return 0.0;
        return _gamepad.sure().values[which];
    }

    private static function onConnect(gamepad: Pad) {
        _gamepad = gamepad;
        trace("gamepad connected!");
        _gamepad.sure().onDisconnect = onDisconnect;
    }

    private static function onDisconnect() {
        _gamepad = null;
        trace("gamepad disconnected!");
    }

    private static inline function get_connected(): Bool {
        return _gamepad.exists();
    }
}