package reve.collision;

enum ShapeType {
    rectangle(rectangle: CollisionRectangle);
    circle(circle: CollisionCircle);
    point(point: CollisionPoint);
}