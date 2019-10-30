package reve.test.cases;

import utest.Test;
import utest.Assert;
import reve.util.Set;

using Lambda;

class TestSet extends Test {

    function testBasicUse() {
        final s = new Set<String>();

        s.add("Grain");
        s.add("Hopper");
        s.add("Mussel");

        Assert.isTrue(s.contains("Grain"));
        Assert.isFalse(s.contains("Wildberry"));
        Assert.isTrue(s.contains("Hopper"));
        Assert.isFalse(s.contains("Ricotta"));
        Assert.isTrue(s.contains("Mussel"));

        // remove twice
        s.remove("Grain");
        Assert.isFalse(s.contains("Grain"));
        s.remove("Grain");
        Assert.isFalse(s.contains("Grain"));

        // add twice
        s.add("Grain");
        Assert.isTrue(s.contains("Grain"));
        s.add("Grain");
        Assert.isTrue(s.contains("Grain"));
    }

    function testIteration() {
        final s = new Set<String>();

        s.add("a");
        s.add("a");
        s.add("a");
        s.add("a");
        s.add("b");
        s.add("b");
        s.add("b");
        s.add("c");
        s.add("c");
        s.add("d");

        final count = ["a" => 0, "b" => 0, "c" => 0, "d" => 0];
        for (letter in s) count[letter]++;
        
        Assert.equals(1, count["a"]);
        Assert.equals(1, count["b"]);
        Assert.equals(1, count["c"]);
        Assert.equals(1, count["d"]);

        s.remove("a");
        for (letter in s) count[letter]++;

        Assert.equals(1, count["a"]);
        Assert.equals(2, count["b"]);
        Assert.equals(2, count["c"]);
        Assert.equals(2, count["d"]);
    }

    function testClasses() {
        final s = new Set<Boi>();

        final tom = new Boi("tom");
        final jerry = new Boi("jerry");
        final andy = new Boi("andy");

        s.add(tom);
        s.add(tom);
        s.add(tom);
        s.add(jerry);
        s.add(jerry);

        Assert.isTrue(s.contains(tom));
        Assert.isTrue(s.contains(jerry));
        Assert.isFalse(s.contains(andy));

        final count = [tom => 0, jerry => 0, andy => 0];
        for (boi in s) {
            count[boi]++;
        }

        Assert.equals(1, count[tom]);
        Assert.equals(1, count[jerry]);
        Assert.equals(0, count[andy]);
    }

    function testEnums() {
        final s = new Set<BoiChange>();

        final peepee = new Boi("Peepee");
        final poopoo = new Boi("Poopoo");

        s.add(BoiChange.add(peepee));
        s.add(BoiChange.add(peepee));

        Assert.isTrue(s.contains(BoiChange.add(peepee)));

        // All enums with the same kind and the same contained values are equal, no matter
        // when or how they are created, therefore the set should only contain one record
        Assert.isTrue(s.count == 1);

        s.add(BoiChange.remove(poopoo));

        Assert.isTrue(s.contains(BoiChange.remove(poopoo)));
        Assert.isFalse(s.contains(BoiChange.remove(peepee)));
        Assert.isTrue(s.count == 2);

        s.remove(BoiChange.add(peepee));
        Assert.isFalse(s.contains(BoiChange.add(peepee)));
        Assert.isTrue(s.count == 1);


        s.add(BoiChange.replace(peepee, 1));
        s.add(BoiChange.replace(peepee, 1));
        s.add(BoiChange.replace(peepee, 1));
        s.add(BoiChange.replace(peepee, 2));
        Assert.isTrue(s.contains(BoiChange.replace(peepee, 1)));
        Assert.isTrue(s.contains(BoiChange.replace(peepee, 2)));

        s.remove(BoiChange.replace(peepee, 1));
        Assert.isFalse(s.contains(BoiChange.replace(peepee, 1)));
        Assert.isTrue(s.contains(BoiChange.replace(peepee, 2)));


    }

    function testUnion() {

        final firstSets = [
            [3, 6, 9, 10, 23],
            [5, 23, 44, 0],
            [],
        ];

        final secondSets = [
            [3, 6, 11, 24],
            [5, 23, 44, 0],
            [3, 1, 4, 5],
        ];

        final expectedSets = [
            [3, 6, 9, 10, 11, 23, 24],
            [5, 23, 44, 0],
            [3, 1, 4, 5],
        ];

        for (i in 0...3) {
            final firstSet: Set<Int> = Set.from(firstSets[i]);
            final secondSet: Set<Int> = Set.from(secondSets[i]);

            final union = Set.union(firstSet, secondSet);
            final expected = expectedSets[i];

            for (value in union) {
                Assert.isTrue(expected.has(value));
            }

            for (value in expected) {
                Assert.isTrue(union.contains(value));
            }
        }
    }

    function testIntersection() {

        final firstSets = [
            [3, 6, 9, 10, 23],
            [5, 23, 44, 0],
            [],
        ];

        final secondSets = [
            [3, 6, 11, 24],
            [5, 23, 44, 0],
            [3, 1, 4, 5],
        ];

        final expectedSets = [
            [3, 6],
            [5, 23, 44, 0],
            [],
        ];

        for (i in 0...3) {
            final firstSet: Set<Int> = Set.from(firstSets[i]);
            final secondSet: Set<Int> = Set.from(secondSets[i]);

            final intersection = Set.intersection(firstSet, secondSet);
            final expected = expectedSets[i];
            
            for (value in intersection) {
                Assert.isTrue(expected.has(value));
            }

            for (value in expected) {
                Assert.isTrue(intersection.contains(value));
            }
        }
    }
}

private class Boi {

    public final name: String;

    public function new(name: String) {
        this.name = name;
    }
}

enum BoiChange {
    add(boi: Boi);
    remove(boi: Boi);
    replace(boi: Boi, index: Int);
}