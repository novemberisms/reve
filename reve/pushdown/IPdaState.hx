package reve.pushdown;

interface IPdaState {
    public function onEnter(): Void;
    public function onExit(): Void;
    public function onPause(): Void;
    public function onResume(): Void;
}
