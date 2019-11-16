package reve.collision.shapes;

import reve.collision.shapes.CollisionRectangle;

enum ShapeType {
    rectangle(rectangle: CollisionRectangle);
    circle(circle: CollisionCircle);
}