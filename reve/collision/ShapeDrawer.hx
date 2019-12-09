package reve.collision;

import h2d.Graphics;

class ShapeDrawer {

    public static function drawShape(graphics: Graphics, shape: ICollisionShape, color: Int) {
        graphics.clear();
		graphics.beginFill(color);

		switch (shape.shapeType) {
			case ShapeType.rectangle(r):
				graphics.drawRect(r.rectangle.xMin, r.rectangle.yMin, r.rectangle.width, r.rectangle.height);
			case ShapeType.point(p):
				graphics.drawCircle(p.vector.x, p.vector.y, 1);
			case ShapeType.circle(c):
				graphics.drawCircle(c.circle.cx, c.circle.cy, c.circle.radius);
			case ShapeType.polygon(g):
				final points = g.polygon.points;

				graphics.moveTo(points[0].x, points[0].y);

				for (i in 1...points.length) {
					final point = points[i];
					graphics.lineTo(point.x, point.y);
				}

				graphics.endFill();
		}
    }
}