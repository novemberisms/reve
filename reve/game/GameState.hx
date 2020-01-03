package reve.game;

import reve.camera.Camera;
import reve.pushdown.IPdaState;
import reve.input.Input;

class GameState implements IPdaState {

    public final game: Game;
    public final scene = new EngineScene();
    public final input = new Input();
    public final camera = new Camera();

    public function new(game: Game) {
        this.game = game;
    }

    @virtual public function dispose() {
        scene.dispose();
    }

    @virtual public function onEnter() {}
    @virtual public function onExit() {}
    @virtual public function onResume() {}
    @virtual public function onPause() {}

    @virtual public function update(dt: Float) {}

}