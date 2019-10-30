package reve.camera;

import reve.math.Circle;
import reve.math.Vector;

class PointOfInterest {

    public final center: Vector;
    public final fullControlArea: Circle;
    public final influenceArea: Circle;

    public function new(center: Vector, fullControlRadius: Float, influenceRadius: Float) {
#if !skipAsserts
        if (influenceRadius < fullControlRadius) throw "influence radius must be greater than or equal to fullControlRadius";
#end
        this.center = center;
        fullControlArea = new Circle(center, fullControlRadius);
        influenceArea = new Circle(center, influenceRadius);
    }

    public function getInfluenceFactor(position: Vector): Float {
        if (!influenceArea.contains(position)) return 0;
        if (fullControlArea.contains(position)) return 1;
        return 1 - fullControlArea.distanceTo(position) / (influenceArea.radius - fullControlArea.radius);
    }
}