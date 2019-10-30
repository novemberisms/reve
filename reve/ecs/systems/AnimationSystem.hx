package reve.ecs.systems;

import reve.ecs.SystemPhase;
import reve.ecs.System;
using reve.ecs.components.Drawable;
using reve.ecs.components.Animation;

class AnimationSystem extends System {

    private inline override function getOrderingLabels(): Array<String> {
        return [SystemPhase.display, DisplayPhase.animation];
    }

    private inline override function getOrderingConstraints() return [
        before(DisplayPhase.present), 
    ];

    private inline override function getRequiredComponents() {
        return [
            Animation.id,
            Drawable.id,
        ];
    }

    public override function update(dt: Float) {
        final entities = getEntities();

        for (e in entities) {
            final sprite = e.getSprite();
            if (!sprite.exists()) continue;
            if (Std.is(sprite.sure(), reve.Animation)) {
                final animation: reve.Animation = cast sprite.sure();
                animation.update(dt);
            }
        }
    }
}