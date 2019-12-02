package reve.test;

import utest.Runner;
import utest.ui.Report;
import reve.test.cases.*;
import reve.test.cases.ecs.*;
import reve.test.cases.ecs.components.*;
import reve.test.cases.algorithms.*;

class TestAll {
    static function main() {
        final runner = new Runner();

        runner.addCase(new TestActionController());
        runner.addCase(new TestBitflag());
        runner.addCase(new TestBoxFinder());
        runner.addCase(new TestCollision());
        runner.addCase(new TestFsm());
        runner.addCase(new TestPushdown());
        runner.addCase(new TestSet());
        runner.addCase(new TestShapes());
        runner.addCase(new TestSpatialHash());
        runner.addCase(new TestSystemOrdering());
        runner.addCase(new TestTimeAverage());
        runner.addCase(new TestVector());

        Report.create(runner);
        runner.run();
    }
}
