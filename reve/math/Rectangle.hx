package reve.math;

import h2d.col.Bounds;

@:forward(xMin, yMin, xMax, yMax, width, height)
abstract Rectangle(Bounds) from Bounds to Bounds {

    /** Setting `topleft` will move the rectangle without modifying its size. **/
    public var topleft(get, set): Vector;
    /** Setting `bottomright` will move the rectangle without modifying its size. **/
    public var bottomright(get, set): Vector;
    /** Setting `topright` will move the rectangle without modifying its size. **/
    public var topright(get, set): Vector;
    /** Setting `bottomleft` will move the rectangle without modifying its size. **/
    public var bottomleft(get, set): Vector;

    /** Setting `size` will increase the size of the rectangle but keep it anchored around the top left. **/
    public var size(get, set): Vector;
    /** Setting `center` will change the position of the rectangle but keep its size. **/
    public var center(get, set): Vector;
    /** Creates a copy of this rectangle. **/
    public var copy(get, never): Rectangle;
    /** Returns the area of this rectangle. This may be negative if size is negative. **/
    public var area(get, never): Float;

    public inline function new(topleft: Vector, size: Vector) {
        this = Bounds.fromPoints(topleft, topleft + size);
    }

    public static inline function withCenter(center: Vector, size: Vector): Rectangle {
        final result = new Rectangle(Vector.zero, size);
        result.center = center;
        return result;
    }

    public static inline function from(x: Float, y: Float, width: Float, height: Float): Rectangle {
        return new Rectangle(new Vector(x, y), new Vector(width, height));
    }

    //=========================================================================
    // PUBLIC METHODS
    //=========================================================================
    
    /** Changes the size of the rectangle while keeping the center fixed. **/
    public inline function resizeFromCenter(v: Vector) {
        topleft = center - v / 2;
        size = v;
    }

    /** Returns a new rectangle whose size is scaled component-wise by `v`. **/
    public inline function scaled(v: Vector): Rectangle {
        return new Rectangle(topleft, size * v);
    }

    public function intersects(r: Rectangle): Bool {
        if (r.xMin >= this.xMax) return false;
        if (r.yMin >= this.yMax) return false;
        if (r.xMax <= this.xMin) return false;
        if (r.yMax <= this.yMin) return false;
        return true;
    }

    public inline function getIntersection(r: Rectangle): Rectangle {
        return this.intersection(r);
    }

    public function contains(point: Vector): Bool {
        if (point.x <= this.xMin) return false;
        if (point.x >= this.xMax) return false;
        if (point.y <= this.yMin) return false;
        if (point.y >= this.yMax) return false;
        return true;
    }

    public function encloses(other: Rectangle): Bool {
        if (other.xMin < this.xMin) return false;
        if (other.xMax > this.xMax) return false;
        if (other.yMin < this.yMin) return false;
        if (other.yMax > this.yMax) return false;
        return true;
    }

    /** Returns a rectangle representing where this rectangle would be if it were to be
        fit inside a containing rectangle. If this rectangle cannot fit within the container,
        then this will throw an exception string. **/
    public function fitInside(container: Rectangle): Rectangle {
#if !skipAsserts
        if (area > container.area + 1) throw '${toString()} cannot fit inside $container. Insufficient area.';
        if (this.width > container.width + 1) throw '${toString()} cannot fit inside $container. Insufficient width.';
        if (this.height > container.height + 1) throw '${toString()} cannot fit inside $container. Insufficient height.';
#end
        final result = copy;

        if (result.xMin < container.xMin) {
            result.topleft = new Vector(container.xMin, result.yMin);
        }
        if (result.yMin < container.yMin) {
            result.topleft = new Vector(result.xMin, container.yMin);
        }
        if (result.xMax > container.xMax) {
            result.bottomright = new Vector(container.xMax, result.yMax);
        }
        if (result.yMax > container.yMax) {
            result.bottomright = new Vector(result.xMax, container.yMax);
        }

        return result;
    }

    public function canFitInside(container: Rectangle): Bool {
        if (area > container.area) return false;
        if (this.width > container.width) return false;
        if (this.height > container.height) return false;
        return true;
    }

    /** Shrinks or stretches the rectangle to fit within `container` while *still maintaining
        the same aspect ratio*. Returns a new rectangle with the result. **/
    public function scaleToFit(container: Rectangle): Rectangle {
        final result = copy;

        final ratio = container.width < this.width 
            ? container.width / this.width
            : container.height / this.height;
        
        result.resizeFromCenter(result.size * ratio);

        return result.fitInside(container);
    }

    public function getClosestPointOnEdgeTo(point: Vector): Vector {
        if (point.x <= this.xMin) {
            // left side of the rectangle
            if (point.y <= this.yMin) {
                return topleft;
            } else if (point.y >= this.yMax) {
                return bottomleft;
            } else {
                return new Vector(this.xMin, point.y);
            }
        } else if (point.x >= this.xMax) {
            // right side of the rectangle
            if (point.y <= this.yMin) {
                return topright;
            } else if (point.y >= this.yMax) {
                return bottomright;
            } else {
                return new Vector(this.xMax, point.y);
            }
        } else {
            // between the left and right sides
            if (point.y <= this.yMin) {
                return new Vector(point.x, this.yMin);
            } else if (point.y >= this.yMax) {
                return new Vector(point.x, this.yMax);
            } else {
                // the test point is within the rectangle.

                // code derived from PenetrationAlgorithms.vecRect
                final distToLeft = point.x - this.xMin;
                final distToRight = this.xMax - point.x;
                final distToTop = point.y - this.yMin;
                final distToBottom = this.yMax - point.y;

                final lowest = Math.min(
                    Math.min(distToLeft, distToRight),
                    Math.min(distToTop, distToBottom)
                );

                if (lowest == distToTop) return new Vector(point.x, this.yMin);
                if (lowest == distToBottom) return new Vector(point.x, this.yMax);
                if (lowest == distToLeft) return new Vector(this.xMin, point.y);

                return new Vector(this.xMax, point.y);
            }
        }
    }

    public function corners(): Array<Vector> {
        return [topleft, topright, bottomright, bottomleft];
    }

    public function toString(): String {
        return 'Rectangle{From: $topleft, To: $bottomright, Size: $size}';
    }

    //=========================================================================
    // GETTERS AND SETTERS
    //=========================================================================

    private inline function get_topleft(): Vector {
        return new Vector(this.xMin, this.yMin);
    }

    private inline function set_topleft(v: Vector): Vector {
        final currSize = size;
        this.xMin = v.x;
        this.yMin = v.y;
        this.xMax = v.x + currSize.x;
        this.yMax = v.y + currSize.y;
        return v;
    }

    private inline function get_bottomright(): Vector {
        return new Vector(this.xMax, this.yMax);
    }

    private inline function set_bottomright(v: Vector): Vector {
        final currSize = size;
        this.xMax = v.x;
        this.yMax = v.y;
        this.xMin = v.x - currSize.x;
        this.yMin = v.y - currSize.y;
        return v;
    }

    private inline function get_topright(): Vector {
        return new Vector(this.xMax, this.yMin);
    }

    private inline function set_topright(v: Vector): Vector {
        final currSize = size;
        this.xMax = v.x;
        this.yMin = v.y;
        this.xMin = v.x - currSize.x;
        this.yMax = v.y + currSize.y;
        return v;
    }

    private inline function get_bottomleft(): Vector {
        return new Vector(this.xMin, this.yMax);
    }

    private inline function set_bottomleft(v: Vector): Vector {
        final currSize = size;
        this.xMin = v.x;
        this.yMax = v.y;
        this.xMax = v.x + currSize.x;
        this.yMin = v.y - currSize.y;
        return v;
    } 

    private inline function get_size(): Vector {
        return new Vector(this.xMax - this.xMin, this.yMax - this.yMin);
    }

    private inline function set_size(v: Vector): Vector {
        this.xMax = this.xMin + v.x;
        this.yMax = this.yMin + v.y;
        return v;
    }

    private inline function get_center(): Vector {
        return new Vector(
            (this.xMin + this.xMax) / 2, 
            (this.yMin + this.yMax) / 2
        );
    }

    private inline function set_center(v: Vector): Vector {
        topleft = v - size / 2;
        return v;
    }

    private inline function get_copy(): Rectangle {
        return new Rectangle(topleft, size);
    }

    private inline function get_area(): Float {
        return (this.xMax - this.xMin) * (this.yMax - this.yMin);
    }

    //=========================================================================
    // OPERATORS
    //=========================================================================

    @:op(A == B)
    private static inline function equals(a: Rectangle, b: Rectangle): Bool {
        if (a == null && b == null) return true;
        if (a == null) return false;
        if (b == null) return false;
        return a.topleft == b.topleft && a.bottomright == b.bottomright;
    }

    @:op(A != B)
    private static inline function notEquals(a: Rectangle, b: Rectangle): Bool {
        return !equals(a, b);
    }
}