package reve.math;

import h2d.col.Polygon as HeapsPolygon;

abstract Polygon(HeapsPolygon) from HeapsPolygon to HeapsPolygon {

    public var bounds(get, never): Rectangle;
    public var centroid(get, set): Vector;

    public function new(points: Array<Vector>) {
        this = new HeapsPolygon(points);
    }

    public function contains(point: Vector): Bool {
        return this.contains(point, true);
    }

    private inline function get_bounds(): Rectangle {
        return this.getBounds();
    }

    private inline function get_centroid(): Vector {
        return this.centroid();
    }

    private inline function set_centroid(v: Vector): Vector {
        final currentCenter = this.centroid();

        final offset = v - currentCenter;

        for (p in this) {
            p.x += offset.x;
            p.y += offset.y;
        }

        return v;
    }
}