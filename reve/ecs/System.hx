package reve.ecs;

import reve.util.Set;
import reve.ecs.Component.ComponentID;

using Lambda;

enum OrderingConstraint {
    after(label: String);
    before(label: String);
}

class System {

    public final world: World;
    public final requiredComponents: Array<ComponentID>;
    public final exceptComponents: Array<ComponentID>;
    public final orderingLabels = new Set<String>();
    public final orderingConstraints = new Set<OrderingConstraint>();
    
    private var _entities: Array<Entity> = [];

    /** Even though System is supposed to be an abstract class, this should be public or else 
        we would need to define a constructor for all Systems. Otherwise they could not be 
        constructed. **/
    public function new(world: World) {
        this.world = world;
        requiredComponents = getRequiredComponents();
        exceptComponents = getExceptComponents();
        for (label in getOrderingLabels()) orderingLabels.add(label);
        for (constraint in getOrderingConstraints()) orderingConstraints.add(constraint);
    }

    //=========================================================================
    // VIRTUAL FUNCTIONS
    //=========================================================================

    /** Called every frame. **/
    @virtual public function update(dt: Float) {}
    /** Called when an entity is spawned into a world and all other systems have called `onEntityAdded`. **/
    @virtual public function onEntitySpawned(e: Entity) {}
    /** Called when an entity is despawned from a world and all other systems have called `onEntityRemoved`. **/
    @virtual public function onEntityDespawned(e: Entity) {}
    /** Called when an entity is first added to the system. There is no guarantee over the order in which
        systems call this. **/
    @virtual private function onEntityAdded(e: Entity) {}
    /** Called when an entity is removed from the system. There is no guarantee over the order in which 
        systems call this. **/
    @virtual private function onEntityRemoved(e: Entity) {}
    /** This is meant to be overriden by any System. Must return an array
        of ComponentIDs corresponding to the required components of this 
        system. **/
    @virtual private function getRequiredComponents(): Array<ComponentID> { return []; }
    /** This is meant to be overriden by any System. Must return an array
        of ComponentIDs corresponding to components that, if present in an
        entity, will except it from being included in this system. **/
    @virtual private function getExceptComponents(): Array<ComponentID> { return []; }
    /** **/
    @virtual private function getOrderingLabels(): Array<String> { return []; }
    /** **/
    @virtual private function getOrderingConstraints(): Array<OrderingConstraint> { return []; }

    //=========================================================================
    // PUBLIC FUNCTIONS
    //=========================================================================

    /** Checks whether the entity meets the criteria for inclusion in this
        system and adds it if it does. Otherwise, nothing happens. **/
    public inline function addEntity(e: Entity): Bool {
        onEntityAdded(e);
        _entities.push(e);
        return true;
    }

    /** Checks whether the entity meets the criteria for inclusion in this
        system and removes it if it does not. Otherwise, nothing happens.
    
        This will always remove an entity that has had its `toRemove` flag
        set. **/
    public inline function removeEntity(e: Entity): Bool {
        onEntityRemoved(e);
        _entities.remove(e);
        return true;
    }

    /** Returns whether a set of component IDs would meet this system's criteria. **/
    public function accepts(components: Set<ComponentID>): Bool {

        for (exception in exceptComponents) {
            if (components.contains(exception)) return false;
        }

        for (required in requiredComponents) {
            if (!components.contains(required)) return false;
        }

        return true;
    }

    public inline function has(e: Entity): Bool {
        return _entities.has(e);
    }

    //=========================================================================
    // PRIVATE FUNCTIONS
    //=========================================================================

    /** Returns a cached list of all entities that meet this system's 
        criteria. Use this when updating entities in a callback. **/
    private inline function getEntities(): Array<Entity> {
        return _entities;
    }
}

class OrderingConstraintViolatedException extends Exception {

    public function new(system: System, constraint: OrderingConstraint, otherSystem: System) {

        final systemClass = getClassName(system);
        final otherSystemClass = getClassName(otherSystem);

        var position = "";
        var orderingLabel = "";

        switch (constraint) {
        case after(label): 
            position = "after";
            orderingLabel = label;
        case before(label): 
            position = "before";
            orderingLabel = label;
        }

        super('[$systemClass] must execute $position [$otherSystemClass] due to ordering constraint [$position($orderingLabel)].');
    }

    private function getClassName(s: System): String {
        final cls = Type.getClass(s);
        final classPath = Type.getClassName(cls).split(".");
        return classPath[classPath.length - 1];
    }
}