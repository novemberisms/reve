package reve.util;

import haxe.io.Path;

class PathExtender {

    /** Given a path, returns a new path that is the result if you apply the relative path to it.
        Example, given `tiled/maps/overworld/my_map.json`, and the relative path `../../tilesets/hello.json`,
        this will spit out a path pointing to `tiled/tilesets/hello.json` **/
    public static inline function applyRelative(start: Path, relative: Path): Path {
        final resultPath = Path.join([start.dir, relative.toString()]);

        // Path.normalize turns tiled/maps/overworld/../../tilesets/hello.json 
        // into tiled/tilesets/hello.json
        return new Path(Path.normalize(resultPath));
    }

    /** Given a path, returns a new path that is the result if you apply the relative path to it.
        Example, given `tiled/maps/overworld/my_map.json`, and the relative path `../../tilesets/hello.json`,
        this will spit out a path pointing to `tiled/tilesets/hello.json`.
        
        Same functionality as `PathExtender.applyRelative`, but taking in and returning strings instead. **/
    public static inline function applyRelativeString(start: String, relative: String): String {
        return applyRelative(new Path(start), new Path(relative)).toString();
    }
}