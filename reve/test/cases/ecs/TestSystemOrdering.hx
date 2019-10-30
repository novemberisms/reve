package reve.test.cases.ecs;

import reve.ecs.World;
import reve.ecs.System;
import utest.Assert;
import utest.Test;


//=============================================================================
// SYSTEMS
//=============================================================================
//-----------------------------------------------------------------------------
private class SystemA extends System {
    private override function getOrderingLabels() return ["a"];
    private override function getOrderingConstraints() return []; 
}
private class SystemB extends System {
    private override function getOrderingLabels() return ["b"];
    private override function getOrderingConstraints() return [after("a")];
}
private class SystemC extends System {
    private override function getOrderingLabels() return ["c"];
    private override function getOrderingConstraints() return [after("b")];
}
//-----------------------------------------------------------------------------
// If you wish to make an apple pie from scratch, you must first invent the universe. -- Carl Sagan
private class SystemUniverse extends System {
    private override function getOrderingLabels() return ["universe"];
    private override function getOrderingConstraints() return [before("apple")];
}
private class SystemApple extends System {
    private override function getOrderingLabels() return ["apple"];
    private override function getOrderingConstraints() return [before("applepie")];
}
private class SystemApplePie extends System {
    private override function getOrderingLabels() return ["applepie"];
    private override function getOrderingConstraints() return [];
}
//-----------------------------------------------------------------------------
private class SystemRoot extends System {
    private override function getOrderingLabels() return ["root"];
}
private class SystemBranch extends System {
    private override function getOrderingLabels() return ["branch"];
    private override function getOrderingConstraints() return [after("root")];
}
private class SystemBranchA extends SystemBranch {}
private class SystemBranchB extends SystemBranch {}
private class SystemBranchC extends SystemBranch {}
private class SystemCanopy extends System {
    private override function getOrderingConstraints() return [after("branch")];
}
//=============================================================================
// TEST PROPER
//=============================================================================
class TestSystemOrdering extends Test {
    
    function testAfterOk() {
        final world = new World();
        world.addSystem(new SystemA(world));
        world.addSystem(new SystemB(world));
        world.addSystem(new SystemC(world));

        try {
            world.validateSystemOrderingConstraints();
            Assert.pass();
        } catch (d: Dynamic) {
            Assert.fail();
        }
    }

    function testAfterFails() {
        final firstworld = new World();
        
        firstworld.addSystem(new SystemB(firstworld));
        firstworld.addSystem(new SystemA(firstworld));
        firstworld.addSystem(new SystemC(firstworld));

        Assert.raises(() -> {
            firstworld.validateSystemOrderingConstraints();
        }, OrderingConstraintViolatedException);

        
        final secondworld = new World();
        
        secondworld.addSystem(new SystemA(secondworld));
        secondworld.addSystem(new SystemC(secondworld));
        secondworld.addSystem(new SystemB(secondworld));

        Assert.raises(() -> {
            secondworld.validateSystemOrderingConstraints();
        }, OrderingConstraintViolatedException);


        final thirdworld = new World();
        
        thirdworld.addSystem(new SystemB(thirdworld));
        thirdworld.addSystem(new SystemC(thirdworld));
        thirdworld.addSystem(new SystemA(thirdworld));

        Assert.raises(() -> {
            thirdworld.validateSystemOrderingConstraints();
        }, OrderingConstraintViolatedException);
    }

    function testMissingAfterLabelStillWorks() {
        final world = new World();
        world.addSystem(new SystemB(world));
        world.addSystem(new SystemC(world));
        
        try {
            world.validateSystemOrderingConstraints();
            Assert.pass();
        } catch (d: Dynamic) {
            Assert.fail();
        }
    }

    function testBeforeOk() {
        final world = new World();

        world.addSystem(new SystemUniverse(world));
        world.addSystem(new SystemApple(world));
        world.addSystem(new SystemApplePie(world));

        try {
            world.validateSystemOrderingConstraints();
            Assert.pass();
        } catch (d: Dynamic) {
            Assert.fail();
        }

    }

    function testBeforeFails() {
        final firstworld = new World();
        
        firstworld.addSystem(new SystemApple(firstworld));
        firstworld.addSystem(new SystemUniverse(firstworld));
        firstworld.addSystem(new SystemApplePie(firstworld));

        Assert.raises(() -> {
            firstworld.validateSystemOrderingConstraints();
        }, OrderingConstraintViolatedException);

        
        final secondworld = new World();
        
        secondworld.addSystem(new SystemApplePie(secondworld));
        secondworld.addSystem(new SystemApple(secondworld));
        secondworld.addSystem(new SystemUniverse(secondworld));

        Assert.raises(() -> {
            secondworld.validateSystemOrderingConstraints();
        }, OrderingConstraintViolatedException);


        final thirdworld = new World();
        
        thirdworld.addSystem(new SystemUniverse(thirdworld));
        thirdworld.addSystem(new SystemApplePie(thirdworld));
        thirdworld.addSystem(new SystemApple(thirdworld));

        Assert.raises(() -> {
            thirdworld.validateSystemOrderingConstraints();
        }, OrderingConstraintViolatedException);
    }

    function testMultipleAfter() {
        final firstworld = new World();

        firstworld.addSystem(new SystemRoot(firstworld));
        firstworld.addSystem(new SystemBranchA(firstworld));
        firstworld.addSystem(new SystemBranchB(firstworld));
        firstworld.addSystem(new SystemBranchC(firstworld));
        firstworld.addSystem(new SystemCanopy(firstworld));

        try {
            firstworld.validateSystemOrderingConstraints();
            Assert.pass();
        } catch (d: Dynamic) {
            Assert.fail();
        }

        final secondworld = new World();

        secondworld.addSystem(new SystemRoot(secondworld));
        secondworld.addSystem(new SystemBranchA(secondworld));
        secondworld.addSystem(new SystemBranchB(secondworld));
        secondworld.addSystem(new SystemCanopy(secondworld));
        secondworld.addSystem(new SystemBranchC(secondworld));

        Assert.raises(() -> {
            secondworld.validateSystemOrderingConstraints();
        }, OrderingConstraintViolatedException);
    }


}