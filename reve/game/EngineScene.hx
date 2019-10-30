package reve.game;

import h2d.Layers;
import h2d.Object;
import h2d.Scene;

class EngineScene {

    public final gameLayers = new Layers();
    public final guiLayers = new Layers();

    public final scene = new Scene();

    public function new() {
        scene.addChildAt(gameLayers, 0);
        scene.addChildAt(guiLayers, 1);
    }

    public inline function dispose() {
        scene.dispose();
    }
}