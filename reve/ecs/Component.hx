package reve.ecs;

typedef ComponentID = String;

class Component {

    public static inline final id: ComponentID = "Component";
    
    public function new() {}

    @virtual public function getComponentID(): ComponentID {
        return "Component";
    }

    @virtual public function toString(): String {
        return "BaseComponent{}";
    }

    @virtual public function triggerEventsWithInitialValues() {}
}
