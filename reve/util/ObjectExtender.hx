package reve.util;

import h2d.Object;
import reve.math.Vector;
import reve.math.Transform;

class ObjectExtender {

    public static inline function setPositionV(obj: Object, position: Vector): Vector {
        obj.x = position.x;
        obj.y = position.y;
        return position;
    }

    public static inline function setScaleV(obj: Object, scale: Vector): Vector {
        obj.scaleX = scale.x;
        obj.scaleY = scale.y;
        return scale;
    }

    public static inline function applyTransform(obj: Object, transform: Transform) {
        obj.x += transform.translation.x;
        obj.y += transform.translation.y;
        obj.scaleX *= transform.scale.x;
        obj.scaleX *= transform.scale.y;
        obj.rotation += transform.rotation;
    }
}