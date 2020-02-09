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

	public static function rectangleLine(graphics: Graphics, rect: Rectangle, color: Int, lineWidth = 1) {
		graphics.clear();
		graphics.lineStyle(lineWidth, color, 1);
		graphics.drawRect(rect.xMin, rect.yMin, rect.width, rect.height);
	}

	public static function circleLine(graphics: Graphics, circ: Circle, color: Int, lineWidth = 1) {
		graphics.clear();
		graphics.lineStyle(lineWidth, color, 1);
		graphics.drawCircle(circ.cx, circ.cy, circ.radius);
	}

	public static function polygonLine(graphics: Graphics, poly: Polygon, color: Int, lineWidth = 1) {
		graphics.clear();
		graphics.lineStyle(lineWidth, color, 1);
		
		final firstPoint = poly.points[0];
		graphics.moveTo(firstPoint.x, firstPoint.y);

		for (i in 1...poly.points.length) {
			final p = poly.points[i];
			graphics.lineTo(p.x, p.y);
		}

		graphics.lineTo(firstPoint.x, firstPoint.y);
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