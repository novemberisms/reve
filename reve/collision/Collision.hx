package reve.collision;

import reve.collision.shapes.CollisionShape;
import reve.math.Vector;

typedef Collision = {
    public final shape: CollisionShape;
    public final collidingWith: CollisionShape;
    public final penetration: Vector;
}