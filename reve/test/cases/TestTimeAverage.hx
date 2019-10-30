package reve.test.cases;

import utest.Test;
import utest.Assert;
import reve.math.TimeAverage;

class TestTimeAverage extends Test {

    function testInitialValue() {
        final t0 = new TimeAverage(0, 10);
        Assert.floatEquals(0, t0.value);

        final t1 = new TimeAverage(-345, 10);
        Assert.floatEquals(-345, t1.value);
    }

    function testUnchangingValue() {
        final t = new TimeAverage(5, 10);

        for (i in 0...10) {
            t.update(0.1);
            Assert.floatEquals(5, t.value);
        }
    }

    function testLongTimeNoSend() {
        final t = new TimeAverage(5, 10);

        t.update(10);
        t.update(10);
        t.update(10);
        t.update(10);

        Assert.floatEquals(5, t.value);
    }

    function testDelta() {
        final t = new TimeAverage(5, 10);

        t.update(1);

        t.send(10);

        Assert.floatEquals(5, t.value);
    }

    function testConstantInputs() {
        final t = new TimeAverage(5, 10);

        for (i in 0...20) {
            t.update(1);
            t.send(5);
            Assert.floatEquals(5, t.value);
        }
    }

    function testStabilization() {
        final t = new TimeAverage(5, 10);
        t.update(1);

        for (i in 0...10) {
        
            t.send(10);
            t.update(1);
            t.send(0);
            t.update(1);
            
            Assert.floatEquals(5, t.value);
        }
    }
}