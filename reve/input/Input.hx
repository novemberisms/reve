package reve.input;

import hxd.Key;

/** This class is meant to abstract away the actual keys and buttons a player needs 
    to press to send signals to the game. We now read "Actions" instead of 
    raw button values and axes. This makes the keys and buttons rebindable
    and we can set up a number of different profiles. 
    **/
class Input {

    private final _bindings: Map<String, Binding> = [];

    public function new() {}

    public inline function isActionPressed(action: String): Bool {
        return hasBinding(action) ? _bindings[action].isPressed() : false;
    }

    public inline function isActionReleased(action: String): Bool {
        return hasBinding(action) ? _bindings[action].isReleased() : false;
    }

    public inline function isActionDown(action: String): Bool {
        return hasBinding(action) ? _bindings[action].isDown() : false;
    }

    public inline function getValue(action: String): Float {
        return hasBinding(action) ? _bindings[action].getValue() : 0;
    }

    public function bindActionKey(action: String, key: Int) {
        createIfNotExists(action);
        _bindings[action].addKey(key);
    }

    public function bindActionButton(action: String, button: Int) {
        createIfNotExists(action);
        _bindings[action].addButton(button);
    }

    public function bindActionAxis(action: String, axis: Int) {
        createIfNotExists(action); 
        _bindings[action].addAxis(axis);
    }

    public inline function hasBinding(action: String): Bool {
        return _bindings.exists(action);
    }

    public function clearBindings() {
        for (k in _bindings.keys()) {
            _bindings.remove(k);
        }
    }

    private function createIfNotExists(action: String) {
        if (hasBinding(action)) return;
        _bindings[action] = new Binding();
    }
}

private class Binding {

    public final keys: Array<Int> = [];
    public final buttons: Array<Int> = [];
    public final axes: Array<Int> = [];
    
    public function new() {}

    public inline function addKey(key: Int) {
        keys.push(key);
    }

    public inline function addButton(button: Int) {
        buttons.push(button);
    }

    public inline function addAxis(axis: Int) {
        axes.push(axis);
    }

    public function isPressed(): Bool {
        for (key in keys) {
            if (Key.isPressed(key)) return true;
        }

        for (btn in buttons) {
            if (Gamepad.isPressed(btn)) return true;
        }

        for (axis in axes) {
            if (Gamepad.isPressed(axis)) return true;
        }

        return false;
    }

    public function isReleased(): Bool {
        for (key in keys) {
            if (Key.isReleased(key)) return true;
        }

        for (btn in buttons) {
            if (Gamepad.isReleased(btn)) return true;
        }

        for (axis in axes) {
            if (Gamepad.isReleased(axis)) return true;
        }

        return false;
    }

    public function isDown(): Bool {
        for (key in keys) {
            if (Key.isDown(key)) return true;
        }

        for (btn in buttons) {
            if (Gamepad.isDown(btn)) return true;
        }

        for (axis in axes) {
            if (Gamepad.isDown(axis)) return true;
        }

        return false;
    }

    public function getValue(): Float {

        for (axis in axes) {
            final value = Gamepad.getValue(axis);
            if (value > 0) return value;
        }

        for (btn in buttons) {
            if (Gamepad.isDown(btn)) return 1;
        }

        for (key in keys) {
            if (Key.isDown(key)) return 1;
        }

        return 0;
    }
}
