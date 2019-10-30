package reve.util;

import haxe.Json;
import hxd.res.Resource;

/**
    Use it like the following: 

    ```haxe
    typedef Response = {
        var status: Bool;
        var data: Array<String>;
    }

    override function init() {
        // assuming we have a file called test.json in the Res folder
        final r: Response = JsonReader.load(hxd.Res.test);
        
        trace(r.status);
        for (d in r.data) trace(d);
    }
    ```
**/
class JsonReader {
    public static inline function load<T>(file: Resource): T {
        final text = file.entry.getText();
        return Json.parse(text);
    }
}