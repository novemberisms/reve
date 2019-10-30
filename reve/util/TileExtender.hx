package reve.util;

import h2d.Tile;
import haxe.ds.Vector;

class TileExtender {

    public static function gridSplit(
        tile: Tile, 
        width: Float, 
        height: Float, 
        dx: Float = 0.0, 
        dy: Float = 0.0
    ): Vector<Vector<Tile>> {

        final endY = Std.int(tile.height / height);
        final endX = Std.int(tile.width / width);

        final result = new Vector<Vector<Tile>>(endY);

        for (gy in 0...endY) {
            final row = new Vector<Tile>(endX);
            
            for (gx in 0...endX) {
                row[gx] = tile.sub(
                    gx * width,
                    gy * height,
                    width,
                    height,
                    dx,
                    dy
                );
            }

            result[gy] = row;
        }

        return result;
    }
}