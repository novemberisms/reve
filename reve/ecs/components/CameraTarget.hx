package reve.ecs.components;

import reve.math.Vector;

@:build(reve.ecs.ComponentBuilder.build())
class CameraTarget extends Component {

    // NOTE that when annotating event, you need to explicitly state the type. You cannot rely on type inference
    @:event public var requestsFocus: Bool = false;

    public var cameraTarget = new engine.camera.CameraTarget(Vector.zero, Vector.zero);

    public static function getLookOffset(e: Entity): Vector {
        final targetComponent: CameraTarget = e.getComponent(CameraTarget.id);
        return targetComponent.cameraTarget.lookOffset;
    }

    public static function setLookOffset(e: Entity, value: Vector) {
        final targetComponent: CameraTarget = e.getComponent(CameraTarget.id);
        targetComponent.cameraTarget.lookOffset = value;
    }

    public static function getCameraTargetPosition(e: Entity): Vector {
        final targetComponent: CameraTarget = e.getComponent(CameraTarget.id);
        return targetComponent.cameraTarget.position;
    }

    public static function setCameraTargetPosition(e: Entity, value: Vector) {
        final targetComponent: CameraTarget = e.getComponent(CameraTarget.id);
        targetComponent.cameraTarget.position = value;
    }
}