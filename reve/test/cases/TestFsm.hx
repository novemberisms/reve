package reve.test.cases;

import utest.Test;
import utest.Assert;
import reve.fsm.FiniteStateMachine;


//=============================================================================
// STATES AND ACTIONS
//=============================================================================

private enum FlipFlopState { on; off; }
private enum FlipFlopAction { toggle; noise; }

//-----------------------------------------------------------------------------

private enum RsNorState { stateA; stateB; }
private enum RsNorAction { activateA; activateB; }

//-----------------------------------------------------------------------------

private enum CounterState { state0; state1; state2; state3; state4; }
private enum CounterAction { increment; reset; }

//-----------------------------------------------------------------------------
private enum BrineState {
    sleeping;
    awake;
    eating;
    brining;
    quiching;
}

private enum BrineActions {
    morningTime;
    alarm;
    findFood;
    finishEating;
    bored;
    cozytime;
    finishBrining;
    seesAcey;
    finishQuiching;
}

//=============================================================================
// TEST PROPER
//=============================================================================

class TestFsm extends Test {

    function testFlipFlop() {
        final stateMap = new FsmStateMap([
            on => [toggle => off],
            off => [toggle => on],
        ]);

        final fsm = new FiniteStateMachine<FlipFlopState, FlipFlopAction>(off, stateMap);

        Assert.equals(off, fsm.state);
        fsm.send(toggle);
        Assert.equals(on, fsm.state);
        fsm.send(noise);
        Assert.equals(on, fsm.state);
        fsm.send(toggle);
        Assert.equals(off, fsm.state);
        fsm.send(noise);
        Assert.equals(off, fsm.state);
    }

    function testRsNor() {

        final stateMap = new FsmStateMap([
            stateA => [ activateB => stateB ],
            stateB => [ activateA => stateA ],
        ]);

        final fsm = new FiniteStateMachine<RsNorState, RsNorAction>(stateA, stateMap);

        Assert.equals(stateA, fsm.state);
        fsm.send(activateA);
        Assert.equals(stateA, fsm.state);
        fsm.send(activateB);
        Assert.equals(stateB, fsm.state);
        fsm.send(activateB);
        Assert.equals(stateB, fsm.state);
        fsm.send(activateA);
        Assert.equals(stateA, fsm.state);
    }

    function testGlobal() {

        final stateMap = new FsmStateMap([
            state0 => [increment => state1],
            state1 => [increment => state2],
            state2 => [increment => state3],
            state3 => [increment => state4],
        ]);

        stateMap.globalTransition(reset, state0);

        final fsm = new FiniteStateMachine<CounterState, CounterAction>(state0, stateMap);
        Assert.equals(state0, fsm.state);
        // helper method so it doesn't become too verbose
        function sendTest(activation: CounterAction, expected: CounterState) {
            fsm.send(activation);
            Assert.equals(expected, fsm.state);
        }

        sendTest(increment, state1);
        sendTest(increment, state2);
        sendTest(increment, state3);
        sendTest(increment, state4);
        sendTest(increment, state4);

        sendTest(reset, state0);
        sendTest(increment, state1);
        
        sendTest(reset, state0);
        sendTest(increment, state1);
        sendTest(increment, state2);

        sendTest(reset, state0);
        sendTest(increment, state1);
        sendTest(increment, state2);
        sendTest(increment, state3);

        sendTest(reset, state0);
        sendTest(increment, state1);
        sendTest(increment, state2);
        sendTest(increment, state3);
        sendTest(increment, state4);
        
        sendTest(reset, state0);
        sendTest(reset, state0);
    }

    function testBrineBot() {

        final stateMap = new FsmStateMap([
            sleeping => [
                morningTime => awake,
                alarm => awake,
            ],
            awake => [
                findFood => eating,
                bored => brining,
                cozytime => sleeping,
            ],
            eating => [
                finishEating => awake,
            ],
            brining => [
                finishBrining => sleeping,
            ],
            quiching => [
                finishQuiching => awake,
            ],
        ]);
        // no matter what state brine is in, if he sees acey then he quiches her
        stateMap.globalTransition(seesAcey, quiching);

        final fsm = new FiniteStateMachine<BrineState, BrineActions>(sleeping, stateMap);
        Assert.equals(sleeping, fsm.state);

        // helper method so it doesn't become too verbose
        function sendTest(activation: BrineActions, expected: BrineState) {
            fsm.send(activation);
            Assert.equals(expected, fsm.state);
        }

        // brine is sleeping, but now it's morning time!
        sendTest(morningTime, awake);

        // but it's super cozy because it's raining, so he goes back to sleep!
        sendTest(cozytime, sleeping);

        // there's food in the fridge, but since brine's still sleeping, he can't eat it
        sendTest(findFood, sleeping);

        // the alarm rings! brine wakes up
        sendTest(alarm, awake);

        // brine sees acey and she's super cute mwawma so he quiches her
        sendTest(seesAcey, quiching);

        // they quiche a lot, mwamwa
        sendTest(finishQuiching, awake);

        // then they eat together. so sweet <3
        sendTest(findFood, eating);

        // it's cozy but they're still eating
        sendTest(cozytime, eating);

        // while eating they quiche, and then eat some more
        sendTest(seesAcey, quiching);
        sendTest(finishQuiching, awake);
        sendTest(findFood, eating);
        
        // they finish eating
        sendTest(finishEating, awake);

        // and now briney gets bored so he just brines around
        sendTest(bored, brining);

        // brine finishes brining for the day and now he goes back to sleep
        sendTest(finishBrining, sleeping); 
    }
}
