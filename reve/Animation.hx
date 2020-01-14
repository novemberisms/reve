package reve;

import h2d.Drawable;
import h2d.RenderContext;
import h2d.Tile;
import h2d.Object;
import reve.util.Timer;

class Animation extends Drawable {

    public var ongoing(get, never): Bool;
    public var currentFrame(get, never): Tile;

    private final frames: Array<Tile>;
    private final timer: Timer;
    private final looping: Bool;

    private var frameIndex = 0;

    public function new(frames: Array<Tile>, fps: Float, looping: Bool = true, ?parent: Object) {
        super(parent);
        this.frames = frames;
        this.looping = looping;

        timer = new Timer(1 / fps);
        timer.start();
    }

    public inline function clone(): Animation {
        
        return new Animation(frames, timer.frequency, looping);
    }

    public function update(dt: Float) {
        final elapsed = timer.update(dt);
        if (!elapsed) return;

        frameIndex++;
        if (frameIndex < frames.length) return;

        if (!looping) {
            timer.pause();
            frameIndex = frames.length - 1;
        } else {
            frameIndex = 0;
        }
    }

    public inline function pause() {
        timer.pause();
    }

    public inline function unpause() {
        timer.unpause();
    }

    private override function draw(ctx: RenderContext) {
        emitTile(ctx, currentFrame);
    }

    private override function getBoundsRec(
        relativeTo: Object,
        out: h2d.col.Bounds,
        forSize: Bool
    ) {
        super.getBoundsRec(relativeTo, out, forSize);
        addBounds(
            relativeTo, 
            out, 
            currentFrame.dx, 
            currentFrame.dy, 
            currentFrame.width, 
            currentFrame.height
        );
    }

    private inline function get_currentFrame(): Tile {
        return frames[frameIndex];
    }

    private inline function get_ongoing(): Bool {
        return timer.ongoing;
    }
}

class FadeBetweenAnimation extends Animation {

    private override function draw(ctx: RenderContext) {
        if (!ongoing) {
            emitTile(ctx, currentFrame);
            return;
        }

        // draw a fading image of last frame
        var lastIndex = frameIndex - 1;
        if (lastIndex < 0) {
            if (looping) {
                lastIndex = frames.length - 1;
            } else {
                // not looping, so don't draw a ghost image if it's the very first frame
                emitTile(ctx, currentFrame);
                return;
            }
        }

        final lastFrame = frames[lastIndex];

        final oldAlpha = ctx.globalAlpha;

        ctx.globalAlpha = timer.remaining * oldAlpha;

        emitTile(ctx, lastFrame);

        ctx.globalAlpha = oldAlpha;

        emitTile(ctx, currentFrame);
    }
}