package reve.collision;

enum ShapeType {
    rectangle(r: CollisionRectangle);
    circle(c: CollisionCircle);
    point(p: CollisionPoint);
    polygon(g: CollisionPolygon);
}