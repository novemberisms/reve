package reve.util;

import reve.math.Polygon;
import reve.math.Circle;
import reve.math.Rectangle;
import reve.collision.ICollisionShape;
import reve.collision.ShapeType;
import h2d.Graphics;

class GraphicsExtender {

	public static function rectangle(graphics: Graphics, rect: Rectangle, color: Int) {
		graphics.clear();
		graphics.beginFill(color);
		graphics.drawRect(rect.xMin, rect.yMin, rect.width, rect.height);
		graphics.endFill();
	}

	public static function circle(graphics: Graphics, circ: Circle, color: Int) {
		graphics.clear();
		graphics.beginFill(color);
		graphics.drawCircle(circ.cx, circ.cy, circ.radius);
		graphics.endFill();
	}

	public static function polygon(graphics: Graphics, poly: Polygon, color: Int) {
		graphics.clear();
		graphics.beginFill(color);
		final points = poly.points;

		graphics.moveTo(points[0].x, points[0].y);

		for (i in 1...points.length) {
			final point = points[i];
			graphics.lineTo(point.x, point.y);
		}

		graphics.endFill();
	}
    
    public static inline function drawShape(graphics: Graphics, shape: ICollisionShape, color: Int) {

		switch (shape.shapeType) {
			case ShapeType.rectangle(r):
				rectangle(graphics, r.rectangle, color);
			case ShapeType.point(p):
				final representation = new Circle(p.vector, 1);
				circle(graphics, representation, color);
			case ShapeType.circle(c):
				circle(graphics, c.circle, color);
			case ShapeType.polygon(g):
				polygon(graphics, g.polygon, color);
		}
    }
}