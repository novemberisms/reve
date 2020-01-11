package reve.camera;

import haxe.ds.GenericStack;
import hxd.Window;
import reve.camera.PointOfInterest;
import reve.math.Extrapolators;
import reve.math.Rectangle;
import reve.math.Vector;

using Lambda;
using reve.util.GenericStackExtender;

class CameraDirector {

    public final camera: Camera;
    
    public var settlingTime = 1.0;
    public var minimumPositionSpeed = 40.0;
    public var minimumSizeSpeed = 40.0;
    public var limits = new Rectangle(Vector.zero, 5000 * Vector.one);

    private final _pointsOfInterest = new Array<PointOfInterest>();
    private final _targetStack = new GenericStack<CameraTarget>();
    /** Holds all the zones that the camera should try to avoid seeing.

        TODO: not implemented yet

        TODO: for now this is an array, but maybe in the future if there would be a lot of them, then it could
        be turned into a spatialhash or quadtree **/
    private final _hiddenZones = new Array<Rectangle>(); 

    private final _window = Window.getInstance();

    private var _extrapolator: RectangleExponentialExtrapolator;
    private var _desiredViewport: Rectangle;
    private var _relativeScaleToWindow = 1.0;

    public function new(camera: Camera) {
        this.camera = camera;
        _desiredViewport = camera.getViewport();
        _extrapolator = makeExtrapolator();
        _window.addResizeEvent(onWindowResize);
    }

    /** Creates a new CameraDirector with its own default camera. **/
    public static function withCamera(): CameraDirector {
        return new CameraDirector(new Camera());
    }

    //=========================================================================
    // PUBLIC METHODS
    //=========================================================================

    //-------------------------------------------------------------------------
    // METHODS TO MODIFY INTERNAL COMPONENTS

    public inline function pushTarget(target: CameraTarget) {
        if (_targetStack.has(target)) return;
        _targetStack.add(target);
    }

    public inline function popTarget(target: CameraTarget) {
        _targetStack.remove(target);
    }

    public inline function addPointOfInterest(point: PointOfInterest) {
        if (_pointsOfInterest.has(point)) return;
        _pointsOfInterest.push(point);
    }

    public inline function removePointOfInterest(point: PointOfInterest) {
        _pointsOfInterest.remove(point);
    }

    public inline function addHiddenZone(area: Rectangle) {
        if (_hiddenZones.has(area)) return;
        _hiddenZones.push(area);
    }
   
    public inline function removeHiddenZone(area: Rectangle) {
        _hiddenZones.remove(area);
    }

    /** Sets the desired camera scaling relative to the window's size. For instance, if the desired scale is 
        0.5, then the camera's viewport will always update its size to be half the window's size, even when the
        window is resized. **/
    public function setRelativeScaleToWindow(scale: Float) {
        _relativeScaleToWindow = scale;
        _desiredViewport.resizeFromCenter(getWindowSize() * scale);
        _extrapolator = makeExtrapolator();
    }

    //-------------------------------------------------------------------------
    // COMMANDS

	public function jumpToDesiredViewport() {
		final target = _targetStack.peek();
		if (target.exists()) followTarget(target.sure());

        camera.setViewport(_desiredViewport.copy);
        _extrapolator = makeExtrapolator();
    }

    /** Moves the assigned camera in such a way that it follows the current target while taking into consideration 
        the points of interest and hidden zones. NOTE that you still need to call camera.apply for the changes to be 
        seen. **/
    public function update(dt: Float) {
        final target = _targetStack.peek();
        if (target.exists()) followTarget(target.sure());
        
        _extrapolator.update(dt);
        camera.setViewport(_extrapolator.value);
    }

    //-------------------------------------------------------------------------
    // GETTERS AND SETTERS

    public inline function getDesiredViewport(): Rectangle {
        return _desiredViewport;
    }

    //=========================================================================
    // CALLBACKS
    //=========================================================================

    private function onWindowResize() {
        _desiredViewport.resizeFromCenter(getWindowSize() * _relativeScaleToWindow);
        jumpToDesiredViewport();
    }

    //=========================================================================
    // PRIVATE METHODS
    //=========================================================================
    
    /** Moves the desired viewport's center to align with the target's center, taking into consideration
        the nearby points of interest, the camera boundary limits, and any hidden zones. This then updates
        the extrapolator if necessary. **/
    private function followTarget(target: CameraTarget) {
        _desiredViewport = calculateDesiredViewport(target);
        _extrapolator = makeExtrapolator();
    }

    private function calculateDesiredViewport(target: CameraTarget): Rectangle {
        // without any points of interest, limits, or hidden zones, this is where to point the camera
        final initialFocusPoint = target.position + target.lookOffset;
        
        // take into consideration nearby points of interest
        final pointsOfInterestOffset = calculatePointsOfInterestOffset(target);

        // the ideal camera center if we didn't take into consideration the camera limits and hidden zones
        final idealCenter = initialFocusPoint + pointsOfInterestOffset;

        // find the ideal viewport
        final idealViewport = Rectangle.withCenter(idealCenter, getWindowSize() * _relativeScaleToWindow);

        // determine if the corrected viewport would be out of bounds, and if so, adjust it.
        // if not, then we should shrink the camera viewport to fit within the bounds while keeping the
        // same aspect ratio
        final limitCorrectedViewport = idealViewport.canFitInside(limits)
            ? idealViewport.fitInside(limits)
            : idealViewport.scaleToFit(limits);

        return limitCorrectedViewport;
    }

    private inline function makeExtrapolator(): RectangleExponentialExtrapolator {
        return new RectangleExponentialExtrapolator(
            camera.getViewport(),
            _desiredViewport.copy,
            false,
            settlingTime,
            minimumPositionSpeed,
            minimumSizeSpeed
        );
    }

    private inline function getWindowSize(): Vector {
        return new Vector(_window.width, _window.height);
    }

    /** Given a target, calculates the total offset produced by all the points of interest 
        in range based on their cumulative influence. **/
    private function calculatePointsOfInterestOffset(target: CameraTarget): Vector {
        var result = Vector.zero;
        for (point in _pointsOfInterest) {
            final influenceFactor = point.getInfluenceFactor(target.position);

            if (influenceFactor == 0) continue;

            // this has to be from (target.position + target.lookOffset) instead of from target.position.
            // otherwise, when influenceFactor is 1, the camera still would jump around
            // if target.lookOffset is changed

            final toPoint = point.center - (target.position + target.lookOffset);

            result += toPoint * influenceFactor;
        }
        return result;
    }

    private function calculateHiddenZoneOffset(viewport: Rectangle): Vector {
        var result = Vector.zero;

        for (zone in _hiddenZones) {
            final intersection = viewport.getIntersection(zone);

            // TODO

        }

        return result;
    }
}