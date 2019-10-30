package reve.ecs.systems;

import reve.ecs.SystemPhase.PhysicsPhase;
using reve.ecs.components.Position;
using reve.ecs.components.Velocity;

class VelocitySystem extends System {

    private inline override function getOrderingLabels(): Array<String> return [
        PhysicsPhase.velocity, 
        SystemPhase.physics
    ];

    private inline override function getRequiredComponents() {
        return [
            Position.id,
            Velocity.id,
        ];
    }

    public override function onEntitySpawned(e: Entity) {
        e.setPreviousPosition(e.getPosition());
    }

    public override function update(dt: Float) {
        final entities = getEntities();

        for (e in entities) {
            final velocity = e.getVelocity();
            final previous = e.getPosition();

            e.setPosition(previous + velocity * dt);
            e.setPreviousPosition(previous);
        }
    }
}