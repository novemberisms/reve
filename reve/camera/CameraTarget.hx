package reve.camera;

import reve.math.Vector;

class CameraTarget {

    public var position: Vector;
    public var lookOffset: Vector;

    public function new(position: Vector, lookOffset: Vector) {
        this.position = position;
        this.lookOffset = lookOffset;
    }

}