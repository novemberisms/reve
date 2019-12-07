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
}