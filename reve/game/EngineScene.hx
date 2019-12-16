package reve.game;

import reve.math.Vector;
import h2d.Layers;
import h2d.Object;
import h2d.Scene;

class EngineScene {

    public final gameLayers = new Layers();
    public final guiLayers = new Layers();

    public final scene = new Scene();

    public var width(get, never): Float;
    public var height(get, never): Float;
    public var size(get, never): Vector;

    public function new() {
        scene.addChildAt(gameLayers, 0);
        scene.addChildAt(guiLayers, 1);
    }

    public inline function dispose() {
        scene.dispose();
    }

    private inline function get_width(): Float {
        return scene.width;
    }

    private inline function get_height(): Float {
        return scene.height;
    }

    private inline function get_size(): Vector {
        return new Vector(scene.width, scene.height);
    }
}