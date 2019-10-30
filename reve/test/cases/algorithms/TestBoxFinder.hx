package reve.test.cases.algorithms;

import reve.math.Rectangle;
import utest.Test;
import utest.Assert;
import reve.math.algorithms.BoxFinder;

using Lambda;

class TestBoxFinder extends Test {

    private function go(data: Array<Int>, width: Int, height: Int) {
        final boolData = data.map(i -> i > 0);
        final results = BoxFinder.findBoxes(boolData, width, height);
        final recreation = [for (_ in 0...width*height) 0];

        for (rect in results) {
            final startX = Std.int(rect.xMin);
            final startY = Std.int(rect.yMin);
            final endX = Std.int(rect.xMax) ;
            final endY = Std.int(rect.yMax) ;

            for (y in startY...endY) for (x in startX...endX) {
                final index = y * width + x;
                recreation[index]++;
            }
        }

        function traceData(a: Array<Int>) {
            var out = "";
            for (y in 0...height) {
                var line = "";
                for (x in 0...width) {
                    final index = y * width + x;
                    line += '${a[index]},';
                }
                out += line + '\n';
            }
            trace('\n$out');
        }

        for (i in 0...width*height) {
            if (recreation[i] != data[i]) {
                trace('FAILED results: $results');
                trace('data');
                traceData(data);
                trace('recreation');
                traceData(recreation);
                Assert.fail("Data and Recreation do not match. See trace for details");
                return;
            }
        }

        // trace('PASSED results: ${results.map(r -> r.toString())}');
        // trace('data');
        // traceData(data);
        // trace('recreation');
        // traceData(recreation);

        Assert.pass();
    }


    function testSimplest() {
        go([1], 1, 1);
    
        go([0], 1, 1);

        go([
            1, 1, 
            1, 1
        ], 2, 2);

        go([
            1, 1,
            0, 1,
        ], 2, 2);

        go([
            1, 1, 1, 1
        ], 4, 1);

        go([
            0, 1, 1, 0
        ], 4, 1);

        go([
            0, 0, 0, 0,
            0, 1, 1, 1,
            0, 1, 1, 0,
            0, 1, 1, 0,
        ], 4, 4);

    }
}