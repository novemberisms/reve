package reve.test.cases;

import utest.Test;
import utest.Assert;
import reve.util.Bitflag;

class TestBitflag extends Test {

    function testCreation() {
        final bf = new Bitflag();

        for (i in 0...Bitflag.maxPosition + 1) {
            Assert.isFalse(bf.get(i));
        }

        final bf2 = new Bitflag(0xabcd);

        final expected = [true, false, true, false, true, false, true, true, true, true, false, false, true, true, false, true];
        expected.reverse();

        for (i in 0...expected.length) {
            Assert.equals(expected[i], bf2.get(i));
        }

        final bf3 = Bitflag.fromArray(expected);

        for (i in 0...expected.length) {
            Assert.equals(expected[i], bf3.get(i));
        }
    }

    function testModify() {
        final bf = new Bitflag();

        Assert.isFalse(bf.get(0));

        bf.set(0, true);

        Assert.isTrue(bf.get(0));

        bf.set(0, false);

        Assert.isFalse(bf.get(0));

		Assert.isFalse(bf.get(15));

		bf.set(15, true);

		Assert.isTrue(bf.get(15));

		bf.set(15, false);

		Assert.isFalse(bf.get(15));

        bf.set(3, true);
        bf.set(4, true);
        bf.set(5, true);

        Assert.isTrue(bf.get(3));
        Assert.isTrue(bf.get(4));
        Assert.isTrue(bf.get(5));

        bf.set(4, false);

		Assert.isTrue(bf.get(3));
		Assert.isFalse(bf.get(4));
		Assert.isTrue(bf.get(5));

		bf.set(4, false);

		Assert.isTrue(bf.get(3));
		Assert.isFalse(bf.get(4));
		Assert.isTrue(bf.get(5));

        bf.set(3, false);

		Assert.isFalse(bf.get(3));
		Assert.isFalse(bf.get(4));
		Assert.isTrue(bf.get(5));
    }

    function testLimit() {
        final bf = new Bitflag();

        Assert.raises(() -> bf.get(Bitflag.maxPosition + 1), String);

        Assert.raises(() -> bf.get(-1), String);
    }

    function testAny() {
        final collisionLayers = new Bitflag();
        collisionLayers.set(1, true);
        collisionLayers.set(3, true);
        collisionLayers.set(5, true);

        var collisionMask = new Bitflag();
        collisionMask.set(2, true);
        collisionMask.set(4, true);
        collisionMask.set(5, true);

        Assert.isTrue(collisionLayers.testAny(collisionMask));

		collisionMask = new Bitflag();
		collisionMask.set(2, true);
		collisionMask.set(4, true);
		collisionMask.set(6, true);

        Assert.isFalse(collisionLayers.testAny(collisionMask));
    }

	function testAll() {
		final collisionLayers = new Bitflag();
		collisionLayers.set(1, true);
		collisionLayers.set(3, true);
		collisionLayers.set(5, true);

		var collisionMask = new Bitflag();
		collisionMask.set(2, true);
		collisionMask.set(4, true);
		collisionMask.set(5, true);

		Assert.isFalse(collisionLayers.testAll(collisionMask));

		collisionMask = new Bitflag();
		collisionMask.set(2, true);
		collisionMask.set(3, true);
		collisionMask.set(5, true);

		Assert.isFalse(collisionLayers.testAll(collisionMask));

		collisionMask = new Bitflag();
		collisionMask.set(1, true);
		collisionMask.set(3, true);
		collisionMask.set(5, true);

		Assert.isTrue(collisionLayers.testAll(collisionMask));
    }
}