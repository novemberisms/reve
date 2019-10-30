package reve.ecs.systems;

import h2d.Layers;
import reve.game.EngineScene;
import reve.ecs.SystemPhase;
import reve.ecs.System;
using reve.ecs.components.Drawable;
using reve.ecs.components.Position;
using reve.util.ObjectExtender;

class DrawSystem extends System {

    private final _root: Layers;

    public function new(world: World, scene: EngineScene) {
        super(world);
        _root = scene.gameLayers;
    }

    private inline override function getOrderingLabels(): Array<String> return [
        SystemPhase.display,
        DisplayPhase.present, // the final phase
    ];

    private inline override function getOrderingConstraints() return [
        after(SystemPhase.physics), // display systems must trigger after all other systems are done
    ];
    
    private inline override function getRequiredComponents() {
        return [
            Position.id,
            Drawable.id,
        ];
    }

    private override function onEntityAdded(e: Entity) {
        e.getSpriteEvent().add(newSprite -> {
            final oldSprite = e.getSprite();
            if (newSprite == oldSprite) return;

            removeSpriteFromSceneIfExists(e);

            if (newSprite.exists()) {
                final layer = e.getDrawLayer();
                _root.addChildAt(newSprite.sure(), layer);
            }
        });
        
        e.getDrawLayerEvent().add(newLayer -> {
            if (!e.getSprite().exists()) return;
            _root.addChildAt(e.getSprite().sure(), newLayer);
        });
    }

    private inline override function onEntityRemoved(e: Entity) {
        removeSpriteFromSceneIfExists(e);
    }

    public override function update(dt: Float) {
        final entities = getEntities();

        for (e in entities) {

            final spriteMaybe = e.getSprite();
            if (!spriteMaybe.exists()) continue;

            final sprite = spriteMaybe.sure();
            final scale = e.getDrawScale();
            final position = e.getPosition();
            final drawPos = position + e.getDrawOffset();

            sprite.setScaleV(scale);
            sprite.setPositionV(drawPos);
        }
    }

    private function removeSpriteFromSceneIfExists(e: Entity) {
        if (!e.getSprite().exists()) return;
        final sprite = e.getSprite().sure();
        _root.removeChild(sprite);
    }

}