package reve.pushdown;

import haxe.ds.GenericStack;
import reve.util.Maybe;

using reve.util.GenericStackExtender;
using Lambda;

@:generic
class PushdownAutomata<S: IPdaState> {
    
    public var currentState(get, never): Maybe<S>;

    private final _stateStack = new GenericStack<S>();
    
    public function new() {}

    private inline function get_currentState(): Maybe<S> {
        return _stateStack.peek();
    }

    public function pushState(newState: S) {
        this.currentState.may(s -> s.onPause());
        
        _stateStack.add(newState);
        newState.onEnter();
    }

    public function popState(): Maybe<S> {

        final previousState = _stateStack.popMaybe();
        previousState.may(s -> s.onExit());

        final newState = this.currentState;
        newState.may(s -> s.onResume());

        return previousState;
    }

    /** Replaces the top state in the stack with another without calling the `onResume` of any state underneath it.
        Returns the state that was replaced. **/
    public function replaceState(newState: S): Maybe<S> {
        final previousState = _stateStack.popMaybe();

        _stateStack.add(newState);
        newState.onEnter();
        
        return previousState;
    }

    public function containsState(state: S): Bool {
        return _stateStack.has(state);
    }
}