package reve.console;

import hxd.Key;
import h2d.Object;
import h2d.TextInput;
import h2d.HtmlText;
import h2d.Graphics;
import hxd.res.DefaultFont;

using StringTools;

class DebugConsoleView extends Object {

    public var focused(default, null) = false;
    public dynamic function onInput(inputText: String): Void {}

    private final _background: Graphics;
    private final _text: HtmlText;
    private final _input: TextInput;

    public function new(width: Float, height: Float) {
        super();
        _background = new Graphics(this);
        _text = new HtmlText(DefaultFont.get(), this);
        _input = new TextInput(DefaultFont.get(), this);

        setupInput(width, height);
        setupBackground(width, height);
        setupText(width, height);
    }

    public inline function sendHtml(html: String) {
        _text.text += html;
    }

    public inline function sendLine(text: String) {
        _text.text += '${text.htmlEscape()}<br/>';
    }

    public inline function clear() {
        _text.text = "";
    }

    public inline function sendColoredLine(text: String, color: Int) {
        final colorString = (color & 0xffffff).hex(6);
        final escapedText = text.htmlEscape(true);
        _text.text += '<font color="#$colorString">$escapedText</font><br/>';
    }

    public inline function show() {
        visible = true;
    }

    public inline function hide() {
        visible = false;
    }

    private function setupBackground(width: Float, height: Float) {
        _background.clear();

        // draw the background
        _background.beginFill(0x000000, 0.5);
        _background.drawRect(0, 0, width, height);

        // draw a divider between the text input and the log area
        _background.lineStyle(1, 0xffffff, 0.5);
        _background.moveTo(10, _input.y);
        _background.lineTo(width - 10, _input.y);

        _background.endFill();
    }

    private function setupInput(width: Float, height: Float) {
        final lineHeight = _input.font.lineHeight;
        _input.y = height - lineHeight;
        _input.maxWidth = width;
        _input.canEdit = true;
        _input.text = "";
        _input.onKeyDown = handleInputKeyDown;
        _input.onFocus = handleInputFocus;
        _input.onFocusLost = handleInputFocusLost;
    }

    private function setupText(width: Float, height: Float) {
        _text.text = "";
        _text.maxWidth = width;
    }

    private function handleInputKeyDown(e: hxd.Event): Void {
        if (e.keyCode != Key.ENTER) return;
        onInput(_input.text);
        _input.text = "";
    }

    private function handleInputFocus(e: hxd.Event): Void {
        focused = true;
    }

    private function handleInputFocusLost(e: hxd.Event): Void {
        focused = false;
    }
}