package reve;

using Type;

class Exception {

    public final message: String;

    public function new(message: String) {
        this.message = message;
    } 

    public function toString(): String {
        final className = getClassName(this);
        return '$className: $message';
    }

    public static function getClassName<T>(d: T): String {
        final classPath = d.getClass().getClassName().split(".");
        final className = classPath[classPath.length - 1];
        return className;
    }
}