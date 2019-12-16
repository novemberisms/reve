package reve.game;

import h2d.Scene;
import hxd.App;
import reve.pushdown.PushdownAutomata;
import reve.util.Maybe;

class Game extends App {

    public var state(get, never): Maybe<GameState>;
    public var activeScene(default, null): EngineScene;

    private final _stateMachine = new PushdownAutomata<GameState>();

    override function update(dt: Float) {
#if macos
        try {
            _stateMachine.currentState.sure().update(dt);
        } catch (d: Dynamic) {
		    final stack = haxe.CallStack.toString(haxe.CallStack.exceptionStack());
            Sys.print(d.toString());
            Sys.print(stack);
            Sys.exit(1);
        }
#else 
        _stateMachine.currentState.sure().update(dt);
#end
    }

    public inline function pushState(newState: GameState) {
#if macos
        try {
            _stateMachine.pushState(newState);
            switchScene(newState.scene);
        } catch (d: Dynamic) {
		    final stack = haxe.CallStack.toString(haxe.CallStack.exceptionStack());
            Sys.print(d.toString());
            Sys.print(stack);
            Sys.exit(1);
        }
#else
        _stateMachine.pushState(newState);
        // replace the active scene, but do not dispose the previous since it is still in the stack
        switchScene(newState.scene);
#end
    }

    /** Pops the current state out of the stack. Note that the state just popped and returned has not been disposed yet. 
        So it must be disposed manually. **/
    public inline function popState(): Maybe<GameState> {
        final previousState = _stateMachine.popState();
        // if there is a state underneath the popped gamestate, then replace the active scene
        _stateMachine.currentState.may((state) -> switchScene(state.scene));
        return previousState;
    }

    /** Replaces the current state of the stack with the given new state. Note that the state just replaced has not been 
        disposed yet and must be disposed manually if it won't be used anymore. **/
    public inline function replaceState(newState: GameState): Maybe<GameState> {
        final previousState = _stateMachine.replaceState(newState);
        switchScene(newState.scene);
        return previousState;
    }

    // the following two functions are marked noCompletion because we don't want
    // users of this engine to call them publicly

    @:noCompletion
    public override function setScene2D(h2dScene: Scene, disposePrevious = false) {
        super.setScene2D(h2dScene, disposePrevious);
    }

    @:noCompletion
    public override function setScene(s: hxd.SceneEvents.InteractiveScene, disposePrevious = true) {
        super.setScene(s, disposePrevious);
    }

    private inline function switchScene(scene: EngineScene) {
        setScene2D(scene.scene, false);
        activeScene = scene;
    }

    private inline function get_state(): Maybe<GameState> {
        return _stateMachine.currentState;
    }
}

