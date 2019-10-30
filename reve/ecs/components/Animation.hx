package reve.ecs.components;

/** This component does not store anything; it only indicates
    that the entity's sprite may be an animation and should be 
    updated every frame.  **/
@:build(reve.ecs.ComponentBuilder.build())
class Animation extends Component {
}