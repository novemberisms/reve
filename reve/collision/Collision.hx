package reve.collision;

import reve.collision.shapes.ICollisionShape;
import reve.math.Vector;

typedef Collision = {
    public final shape: ICollisionShape;
    public final collidingWith: ICollisionShape;
    public final penetration: Vector;
}