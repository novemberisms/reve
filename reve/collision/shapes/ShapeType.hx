package reve.collision.shapes;

enum ShapeType {
    rectangle(rectangle: CollisionRectangle);
    circle(circle: CollisionCircle);
    point(point: CollisionPoint);
}