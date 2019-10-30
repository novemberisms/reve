package reve;

using Type;

class Exception {

    public final message: String;

    public function new(message: String) {
        this.message = message;
    } 

    public function toString(): String {
        final classPath = this.getClass().getClassName().split(".");
        final className = classPath[classPath.length - 1];
        return '$className: $message';
    }
}