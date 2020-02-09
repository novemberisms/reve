package reve.input;

import reve.util.Set;
import reve.util.Event;
using Lambda;

class ActionController<Target> {

    public var enabled(default, set) = true;
    public final actionsListenedTo = new Set<String>();

    private var _wasDisabled = false;

    private var _queue: Array<String> = [];
    private var _previousQueue: Array<String> = [];

    private final _onDown: Map<String, Event<Target>> = [];
    private final _onPressed: Map<String, Event<Target>> = [];
    private final _onReleased: Map<String, Event<Target>> = [];

    public function new() {}

    public inline function queueAction(action: String) {
        _queue.push(action);
    }

    public inline function isQueuedDown(action: String): Bool {
        return _queue.has(action);
    }

    public function isQueuedReleased(action: String): Bool {
        if (_queue.has(action)) return false;
        return _previousQueue.has(action);
    }

    public function isQueuedPressed(action: String): Bool {
        if (_previousQueue.has(action)) return false;
        return _queue.has(action);
    }

    public function update(target: Target) {
        if (_wasDisabled) {
            _queue = [];
            _previousQueue = [];
            _wasDisabled = false;
        }

        if (!enabled) return;

        // released gets called first
        for (prevAction in _previousQueue) {
            if (!_onReleased.exists(prevAction)) continue;
            if (_queue.has(prevAction)) continue;
            _onReleased[prevAction].execute(target);
        }

        // pressed and down then get executed
        for (action in _queue) {
            if (_onPressed.exists(action)) {
                if (!_previousQueue.has(action)) {
                    _onPressed[action].execute(target);
                }
            }

            if (_onDown.exists(action)) {
                _onDown[action].execute(target);
            }
        }

        _previousQueue = _queue;
        _queue = [];
    }

    public inline function addListenerDown(action: String, fn: Target -> Void) {
        createEventIfNotExists(action, _onDown);
        _onDown[action].add(fn);
    }

    public inline function addListenerPressed(action: String, fn: Target -> Void) {
        createEventIfNotExists(action, _onPressed);
        _onPressed[action].add(fn);
    }

    public inline function addListenerReleased(action: String, fn: Target -> Void) {
        createEventIfNotExists(action, _onReleased);
        _onReleased[action].add(fn);
    }

    public inline function hasAction(action: String): Bool {
        return actionsListenedTo.contains(action);
    }

    private inline function set_enabled(v: Bool): Bool {
        if (v == false) _wasDisabled = true;
        return enabled = v;
    } 

    private inline function createEventIfNotExists(action: String, map: Map<String, Event<Target>>) {
        if (map.exists(action)) return;
        map[action] = new Event();
        actionsListenedTo.add(action);
    } 

}