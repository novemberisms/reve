package reve.console;

import reve.game.EngineScene;

private typedef TemporaryMessage = {
    public final html: String;
    public final duration: Float;
    public var timeLeft: Float;
}

class DebugConsole {

    public static var instance(get, null): DebugConsole;

    private static final _defaultWidth = 400.0;
    private static final _defaultHeight = 400.0;
    private static final _defaultTemporaryMessageDuration = 1.0;
    private static final _temporaryMessageBufferCount = 10;

    public var focused(get, never): Bool;
    public var visible(get, never): Bool;

    private final _view = new DebugConsoleView(_defaultWidth, _defaultHeight);
    private var _persistentMessages: Array<String> = [];
    private var _temporaryMessages: Array<TemporaryMessage> = [];

    private function new() {
        _view.onInput = handleInput;
    }

    public function attach(scene: EngineScene) {
        scene.guiLayers.addChild(_view);
        
    }

    public function temp(message: String, duration: Float = 0.5) {

    }

    public function print(message: String) {
        // TODO: you can use something like <font opacity=0.5> to fade out older messages
    }

    public function update(dt: Float) {
        _view.clear();

        for (message in _persistentMessages) _view.sendHtml(message);

        for (message in _temporaryMessages) _view.sendHtml(message.html);
    }

    public inline function show() {
        _view.show();
    }

    public inline function hide() {
        _view.hide();
    }

    private function queueTemporaryMessage(html: String) {
        final message: TemporaryMessage = {
            html: html,
            duration: _defaultTemporaryMessageDuration,
            timeLeft: _defaultTemporaryMessageDuration,
        };
        _temporaryMessages.insert(0, message);
        if (_temporaryMessages.length <= _temporaryMessageBufferCount) return;
        _temporaryMessages.resize(_temporaryMessageBufferCount); 
    }

    private function handleInput(inputText: String) {
        _view.sendColoredLine("Unrecognized command: " + inputText, 0xff00ff);
    }

    private inline function get_focused(): Bool {
        return _view.focused;
    }

    private inline function get_visible(): Bool {
        return _view.visible;
    }

    private static inline function get_instance(): DebugConsole {
        if (instance == null) {
            instance = new DebugConsole();
        }
        return instance;
    }

}
