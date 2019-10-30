package reve.test.cases;

import utest.Assert;
import reve.pushdown.IPdaState;
import reve.pushdown.PushdownAutomata;
import utest.Test;

using reve.util.Iterators;

private class TestState implements IPdaState {

    private static final doNothing = function() {};

    public final name: String;
    public var enter = doNothing;
    public var exit = doNothing;
    public var pause = doNothing;
    public var resume = doNothing;

    public function new(name: String) {
        this.name = name;
    }

    public function onEnter() {
        enter();
    }
    
    public function onExit() {
        exit();
    }
    
    public function onPause() {
        pause();
    }

    public function onResume() {
        resume();
    }
}

class TestPushdown extends Test {
    function testEmpty() {
        final machine = new PushdownAutomata<TestState>();
        Assert.isNull(machine.currentState);
        Assert.isNull(machine.popState());
    }

    function testPushPop() {
        final machine = new PushdownAutomata<TestState>();
        final states = ["A", "B", "C", "D", "E"];

        for (name in states) {
            final state = new TestState(name);
            machine.pushState(state);
            Assert.equals(machine.currentState, state);
        }

        for (name in states.reversed()) {
            final state = machine.popState().sure();
            Assert.equals(name, state.name);
        }
    }
}