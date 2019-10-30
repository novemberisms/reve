package reve.camera;

import reve.game.EngineScene;
import reve.math.Vector;
import reve.math.Rectangle;
import hxd.Window;

using reve.util.ObjectExtender;

/** A Camera is just a class that stores a viewport rectangle and takes in some h2d.Object to transform so that
    the parts of the object that would correspond to the viewport take up the entirety of the window. It does not
    have any logic on how it should be moved or how it should scale. It is the `CameraDirector`'s job to move the
    camera. **/
class Camera {

    private var _viewport: Rectangle;

    private final _window = Window.getInstance();

    public function new() {
        _viewport = new Rectangle(Vector.zero, getWindowSize());
    }

    /** Returns a copy of this camera's viewport **/
    public inline function getViewport(): Rectangle {
        return _viewport.copy;
    }

    public inline function setViewport(rect: Rectangle) {
        _viewport = rect;
    }

    public function apply(scene: EngineScene) {
        final scale = getWindowSize() / _viewport.size;

        final truePosition = -(_viewport.topleft * scale);

        scene.gameLayers.setPositionV(truePosition.floor());
        scene.gameLayers.setScaleV(scale);
    }

    private inline function getWindowSize(): Vector {
        return new Vector(_window.width, _window.height);
    }
}
