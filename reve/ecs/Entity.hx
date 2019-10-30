package reve.ecs;

import reve.ecs.Component.ComponentID;
import reve.util.Maybe;
import reve.util.Set;

@:final // cannot be extended
class Entity {
    
    /** A flag used by Worlds and Systems to know whether this entity is queued
        for removal this update frame. **/
    public var toRemove(default, null) = false;

    /** The world this entity has been added to. It is necessary to keep this
        data because when adding or removing a component, we need to notify the
        world to tell its systems. **/
    public var world(default, null): Maybe<World> = null;

    private var _components: Map<ComponentID, Component> = [];
    
    public function new() {}

    public inline function allComponents(): Set<ComponentID> {
        final result = new Set<ComponentID>();
        for (componentID in _components.keys()) {
            result.add(componentID);
        }
        return result;
    }

    public inline function addComponent(c: Component) {
        if (hasComponent(c.getComponentID())) return;
        _components[c.getComponentID()] = c;
        world.may(w -> w.onEntityAddedComponent(this));
    }

    public inline function getComponent<T: Component>(id: ComponentID): T{
        return cast _components[id];
    }

    public inline function hasComponent(id: ComponentID): Bool {
        return _components.exists(id);
    } 

    public inline function isInWorld(): Bool {
        return world.exists() && (toRemove == false);
    }

    public inline function removeComponent(id: ComponentID) {
        if (!hasComponent(id)) return;
        /** 
            The reason this looks different from `addComponent` is because
            Systems **must** be able to assume in their `onEntityRemoved`
            callbacks that the component has not yet been removed from the entity.
            
            This allows for example the DrawSystem to still call `e.getSprite()` in
            `onEntityRemoved` so that it can remove the sprite from the scene. 
        **/
        final newComponents = allComponents();
        newComponents.remove(id);
        world.may(w -> w.onEntityRemovedComponent(this, newComponents));
        _components.remove(id);
    }

    public inline function onAddToWorld(w: World) {
        world = w;
        /** NOTE: once an entity has been removed from a world, it can no longer be added back in.
            This is due to component event fields.
            The custom is for Systems to add an event listener to those fields in `onEntityAdded`
            This means that if an entity with components that already have the event listeners subscribed 
            could be re-added back into the world, `onEntityAdded` will trigger again for all systems and
            the event listeners would be duplicated. **/
        toRemove = false;
    }

    public inline function onRemoveFromWorld() {
        world = null;
        toRemove = true;
    }

    @:noCompletion
    public inline function triggerEventsWithInitialValues() {
        for (c in _components) c.triggerEventsWithInitialValues();
    }

    public function toString(): String {
        final componentList = [for (id in _components.keys()) id];
        return 'Entity{$componentList}';
    }
}