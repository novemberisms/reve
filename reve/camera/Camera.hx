package reve.camera;

import h2d.Object;
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

    /** Applies the camera transformation on the object such that the region in the object
        corresponding to the camera viewport will take up the entirety of the screen. This does
        not do any view culling. **/
    public function apply(object: Object) {
		final scale = getWindowSize() / _viewport.size;

		final truePosition = -(_viewport.topleft * scale);

		object.setPositionV(truePosition.floor());
		object.setScaleV(scale);
    }

    /** Applies the camera transformation on specifically only the `gameLayers` field of an `EngineScene`
        while leaving the `guiLayers` unmoving. **/
    public inline function applyScene(scene: EngineScene) {
        apply(scene.gameLayers);
    }

    private inline function getWindowSize(): Vector {
        return new Vector(_window.width, _window.height);
    }
}
