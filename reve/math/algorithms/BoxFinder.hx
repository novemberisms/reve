package reve.math.algorithms;

class BoxFinder {

    public static function findBoxes(data: Array<Bool>, width: Int, height: Int): Array<Rectangle> {
        final result: Array<Rectangle> = [];

        final checked = [for (i in 0...width*height) false];

        for (index in 0...width*height) {
            if (!data[index]) continue;
            if (checked[index]) continue;

            // encountered a new rectangle!
            
            final w = findWidth(data, index, width);
            final h = findHeight(data, index, w, width, height);

            final x = getX(index, width);
            final y = getY(index, width);
            result.push(Rectangle.from(x, y, w, h));

            checkCells(checked, x, y, w, h, width);
        }

        return result;
    }

    private static function findWidth(data: Array<Bool>, startIndex: Int, dataWidth: Int): Int {
        var width = 0;
        var x = getX(startIndex, dataWidth);

        while (x < dataWidth) {
            if (!data[startIndex + width]) break;
            width++;
            x++;
        }

        return width;
    }

    private static function findHeight(data: Array<Bool>, startIndex: Int, boxWidth: Int, dataWidth: Int, dataHeight: Int): Int {
        var height = 0;
        var y = getY(startIndex, dataWidth);
        final x = getX(startIndex, dataWidth);

        while (y < dataHeight) {
            final index = getIndex(x, y, dataWidth);
            var brokenRow = false;
            for (i in index...index+boxWidth) {
                if (data[i]) continue;
                brokenRow = true;
                break;
            }
            if (brokenRow) break;

            y++;
            height++;
        }

        return height;
    }

    private static function checkCells(checked: Array<Bool>, x: Int, y: Int, w: Int, h: Int, dataWidth: Int) {
        for (currY in y...y+h) {
            final rowIndex = getIndex(x, currY, dataWidth);
            for (offset in 0...w) {
                checked[rowIndex + offset] = true;
            }
        } 
    }

    private static inline function getX(index: Int, width: Int): Int {
        return index % width;
    }

    private static inline function getY(index: Int, width: Int): Int {
        return Math.floor(index / width);
    }

    private static inline function getIndex(x: Int, y: Int, width: Int): Int {
        return y * width + x;
    }
}