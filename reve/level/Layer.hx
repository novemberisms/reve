package reve.level;

import reve.util.Set;
import reve.level.Types;

import h2d.Object;
import h2d.TileGroup;

enum LayerKind {
    tile(layer: TileLayer);
    object(layer: ObjectLayer);
}

enum AnimationChange {
    add(animation: Animation, index: Int);
    remove(index: Int);
}

/** An abstract class meant to unify both types of layers. **/
class Layer {

    //-------------------------------------------------------------------------
    // public interface
    
    public final name: String;
    /** The actual `h2d.Object` depicting this layer's current content. This must be added
        to the scene for the layer to draw.
    
        Don't try to access this from within `Factory`, since it is not 
        available yet at that point. **/
    public final sprite: h2d.Object;
    /** This layer's index in the level's list of layers. A higher index will be displayed
        over a lower index. **/
    public final index: Int;
    public final properties: Properties;

    /** Whether the layer is a Tile Layer or an Object Layer **/
    public var kind(default, null): LayerKind;

    //-------------------------------------------------------------------------
    // internal state

    /** A bottom-up reference to the level containing this layer **/
    private final _level: Level;

    /** Map of image paths (relative to src/) to their corresponding tilegroup for this layer **/
    private final _tilegroupsPerImage: Map<String, TileGroup> = [];

    /** Map of animation indexes to animations. For TileLayers, the index is the index of the tile
        in its big array of data values. For ObjectLayers, the index is the index of the TiledObject
        in its list of TiledObjects. **/
    private final _animations: Map<Int, Animation> = [];

    //-------------------------------------------------------------------------
    // tracker variables

    private var _needsRedraw = false;
    private final _tilegroupsToRedraw = new Set<TileGroup>();
    private final _animationChanges = new Set<AnimationChange>();

    private function new(index: Int, layerData: TiledLayer, level: Level) {
        this.index = index;

        name = layerData.name;
        properties = layerData.properties;
        _level = level;
        
        sprite = createSprite();
    }

    //=========================================================================
    // PUBLIC FUNCTIONS
    //=========================================================================

    public function update(dt: Float) {
        for (animation in _animations) animation.update(dt);
    }

    public function redraw() {
        if (!_needsRedraw) return;
        _needsRedraw = false;

        // clear all the tilegroups that need to be redrawn, since we need to create them from 
        // scratch later on.
        for (group in _tilegroupsToRedraw) {
            group.clear();
            // new tiles that have not appeared in any of the tilegroups this layer has
            // will not appear unless we embed a new tilegroup into the container sprite.
            if (sprite.getChildIndex(group) == -1) sprite.addChild(group);
        }

        // update the animations in the container sprite.

        // remember that _animationChanges is a Set, and so iteration order is not
        // guaranteed.
        // therefore we have to do the removals first, since when replacing an animated
        // tile with another animated tile, there's a chance we could add the new
        // tile and immediately remove it.

        for (animationChange in _animationChanges) {
            switch (animationChange) {
            case remove(index):
                final old = _animations[index];
                _animations.remove(index);
                sprite.removeChild(old);
            default:
            }
        }

        for (animationChange in _animationChanges) {
            switch (animationChange) {
            case add(animation, index):
                _animations[index] = animation;
                sprite.addChild(animation);
            default:
            }
        }

        // allow the subclasses to dictate how they redraw their tilegroups
        redrawTileGroups();

        // empty out the tracker vars
        _tilegroupsToRedraw.empty();
        _animationChanges.empty();
    }

    //=========================================================================
    // VIRTUAL FUNCTIONS
    //=========================================================================

    @virtual private function redrawTileGroups() {}

    /** This is meant to be overriden by derived classes. This creates an h2d Object that contains
        a static image of all the contents of this layer. 
        
        (The @virtual does nothing btw. It just reminds me this is a virtual method. **/
    @virtual private function createSprite(): Object {
        return new Object();
    }

    //=========================================================================
    // HELPER FUNCTIONS
    //=========================================================================

    private inline function getTileGroupFor(tile: MapTile): TileGroup {

        final tileset = tile.tileset;

        final imageOrAtlasPath = tileset.getSourceImagePath(tile.id).sure();

        if (_tilegroupsPerImage[imageOrAtlasPath] == null) {
            _tilegroupsPerImage[imageOrAtlasPath] = tileset.isAtlas
                ? new TileGroup(tileset.atlas.sure())
                : new TileGroup(tile.tile);
        }

        return _tilegroupsPerImage[imageOrAtlasPath];
    }

    private inline function embedTilegroups(container: Object) {
        // the order of these shouldn't matter as they are all supposed to be 
        // in the same layer anyways
        for (tilegroup in _tilegroupsPerImage) {
            container.addChild(tilegroup);
        }
    }

    private inline function embedAnimations(container: Object) {
        // the transforms of the animations should already be set immediately after they are created
        for (animation in _animations) {
            container.addChild(animation);
        }
    }

    /** Queues up a change order for an animation. The order of execution of the changes
        is unpredictable, since the changes are stored in a `Set` **/
    private inline function markAnimationChange(change: AnimationChange) {
        _animationChanges.add(change);
        _needsRedraw = true;
    }

    private inline function markTileChange(tile: MapTile) {
        final tilegroup = getTileGroupFor(tile);
        _tilegroupsToRedraw.add(tilegroup);
        _needsRedraw = true;
    }


}
