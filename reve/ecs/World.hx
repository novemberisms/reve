package reve.ecs;

import reve.util.Maybe;
import reve.util.Set;
import reve.ecs.System.OrderingConstraintViolatedException;
import reve.ecs.Component.ComponentID;

using Lambda;

class World {

    private final _systems: Array<System> = [];

    /** A master list of all added entities in the world. This may
        be necessary because if an entity does not match any systems, it
        would otherwise cease to exist. A system can be added dynamically
        later on that would match the entity. 
        
        However, the maintaining of this array can cause some performance
        problems, and so I should think about removing this if I don't need it
        at all. **/
    private var _entities: Array<Entity> = [];

    /** A flag that is set whenever any entity needs to be removed from the world. **/
    private var _removeFlag: Bool = false;
    private var _entitiesToRemove: Array<Entity> = [];

    /** A flag that is set whenever an entity is to be added to the world. **/
    private var _addFlag: Bool = false;
    private var _entitiesToAdd: Array<Entity> = [];

    public function new() {}

    //=========================================================================
    // PUBLIC FUNCTIONS
    //=========================================================================

    public function addEntity(e: Entity) {
#if !skipAsserts
        if (e.toRemove) throw 'Entity cannot be added back into a world once it has been removed: $e';
        if (e.isInWorld()) throw 'Cannot re-add an entity that has already been added to the world : $e';
#end
        _addFlag = true;
        _entitiesToAdd.push(e);
        e.onAddToWorld(this);
    }

    public function removeEntity(e: Entity) {
        _removeFlag = true;
        _entitiesToRemove.push(e);
        e.onRemoveFromWorld();
    }

    /** Adds a system to the world. 
    
        Note that *the order systems are added determines the order in which callbacks like `update` and `onEntityAdded` execute.* **/
    public inline function addSystem(s: System) {
#if !skipAsserts
        if (s.world != this) throw "The system to be added does not have the correct world set.";
#end        
        _systems.push(s);
    }

    public inline function removeSystem(s: System) {
        _systems.remove(s);
        // no need to remove entities from a system that is removed
    }

    public function update(dt: Float) {
        for (system in _systems) {
            // TODO only update systems that need to be updated
            system.update(dt);
        }
        performRemoveEntityLoop();
        performAddEntityLoop();
    }

    public function validateSystemOrderingConstraints() {
#if !skipAsserts
        final systemsBefore = new Array<System>();

        for (i in 0..._systems.length) {
            final system = _systems[i];

            for (constraint in system.orderingConstraints) {
                switch (constraint) {
                case after(label):
                    // check all the systems that come after this, since after() means this should come after all
                    // systems with the label. If any of them have the label, then the constraint is not met
                    for (j in i+1..._systems.length) {
                        final afterSystem = _systems[j];
                        if (afterSystem.orderingLabels.contains(label)) {
                            throw new OrderingConstraintViolatedException(system, constraint, afterSystem);
                        }
                    }
                case before(label):
                    // check all the systems that came before this, since before() means this system should come before all
                    // systems with the label. If any of them have the label, then the constraint is not met.
                    for (prevSystem in systemsBefore) {
                        if (prevSystem.orderingLabels.contains(label)) {
                            throw new OrderingConstraintViolatedException(system, constraint, prevSystem);
                        }
                    }
                }
            }

            systemsBefore.push(system);
        }
#end
    }

    public function getSystem(systemClass: Any): Maybe<System> {
        for (system in _systems) {
            if (Std.is(system, systemClass)) return system;
        }
        return null;
    }

    //=========================================================================
    // CALLBACKS
    //=========================================================================

    /** Called when an entity has added a component after it has been added to
        this world. This means we have some bookkeeping to do. 
        
        When an entity adds a component, not only do we have to check all
        systems if they can now accept the entity, we also have to check if
        the systems the entity is already in do not want it anymore due to the
        component being an excepted component in that system. **/
    public function onEntityAddedComponent(e: Entity) {
        final components = e.allComponents();
        for (system in _systems) {
            if (system.has(e)) {
                if (!system.accepts(components)) {
                    system.removeEntity(e);
                }
            } else {
                if (system.accepts(components)) {
                    system.addEntity(e);
                }
            }
        }
    }

    /** Called when an entity has removed a component after it has been added to 
        the world. 
        
        This works a little bit differently than `onEntityAddedComponent`
        because systems in their `onEntityRemoved` callbacks
        **must** be able to assume the entity still contains the component that will 
        be removed. 
        
        This is why we need to accept `newComponents`, which is a set that describes 
        what the entity's components are going to be after the removal. This is only used
        to determine which systems should add or remove the entity. At the time this function
        is called from 'Entity.hx', it still has the removed component, which would allow
        for example the DrawSystem to still use `e.getSprite()` in its `onEntityRemoved` 
        callback. **/
    public function onEntityRemovedComponent(e: Entity, newComponents: Set<ComponentID>) {
        for (system in _systems) {
            if (system.has(e)) {
                if (!system.accepts(newComponents)) {
                    system.removeEntity(e);
                }
            } else {
                if (system.accepts(newComponents)) {
                    system.addEntity(e);
                }
            }
        }
    }

    //=========================================================================
    // PRIVATE FUNCTIONS
    //=========================================================================

    /** **/
    private function performRemoveEntityLoop() {
        if (!_removeFlag) return;
        _removeFlag = false;
   
        for (e in _entitiesToRemove) {
            final updatedSystems: Array<System> = [];
            for (system in _systems) {
                if (!system.has(e)) continue;
                system.removeEntity(e);
                updatedSystems.push(system);
            }
            for (system in updatedSystems) {
                system.onEntityDespawned(e);
            }

            _entities.remove(e);
        }

        _entitiesToRemove = [];
    }

    /** **/
    private function performAddEntityLoop() {
        if (!_addFlag) return;
        _addFlag = false;

        for (e in _entitiesToAdd) {
            final components = e.allComponents();
            final updatedSystems: Array<System> = [];
            for (system in _systems) {
                if (!system.accepts(components)) continue;
                system.addEntity(e);
                updatedSystems.push(system);
            }
            for (system in updatedSystems) {
                system.onEntitySpawned(e);
            }
            _entities.push(e);
            e.triggerEventsWithInitialValues();
        }

        _entitiesToAdd = [];
    }
}