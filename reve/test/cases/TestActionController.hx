package reve.test.cases;

import utest.Test;
import utest.Assert;
import reve.input.ActionController;

private class Entity {

    public function new() {}

    public var down: Int;
    public var left: Int;
    public var right: Int;
    public var up: Int;

}

class TestActionController extends Test {

    function testBasic() {

        final controller = new ActionController<Entity>();
        final entity = new Entity();

        controller.addListenerDown("joey", function (e) {
            e.down = 444;
        });

        controller.queueAction("joey");

        controller.update(entity);

        Assert.equals(444, entity.down);
    }
}