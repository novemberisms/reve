package reve.util;

import haxe.macro.Context;
import haxe.macro.Expr;

using Type;
using haxe.macro.TypeTools;

class Compiler {

    macro public static function check(): Array<Field> {
        final fields = Context.getBuildFields();

        return fields;
    }

}