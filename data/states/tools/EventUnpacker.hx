import funkin.editors.ui.UIState;
import funkin.editors.ui.UIButton;
import funkin.editors.ui.UIFileExplorer;
import funkin.editors.ui.UIText;
import openfl.display.BitmapData;
import openfl.net.FileReference;
import openfl.display.PNGEncoderOptions;
import haxe.io.Path;

var packfile:UIFileExplorer;
var label:UIText;
var button:UIButton;

function create() {
    FlxG.camera.bgColor = 0xFF656565;
    FlxG.mouse.visible = true;

    label = new UIText(0, 0, 0, 'PACK', 24, 0xFFFFFFFF, true);
    add(label);

    packfile = new UIFileExplorer(475, 275, 'pack');
    add(packfile);

    label.x = packfile.x - 64;
    label.y = packfile.y;

    button = new UIButton(packfile.x, packfile.y + 65, 'Unpack Event', convert, 320, 64);
    add(button);
}

function update(elapsed) {
    if (FlxG.keys.justPressed.EIGHT)
        FlxG.switchState(new UIState(true, 'tools/EventUnpacker'));

    if (FlxG.keys.justPressed.ESCAPE)
        FlxG.switchState(new UIState(true, 'ToolSelection'));
}

function convert() {
    var shit = packfile.file.toString().split("________PACKSEP________");
	var eventName = Path.withoutExtension(shit[0]);
    new FileReference().save(shit[1], eventName + '.hx');
    new FileReference().save(shit[2], eventName + '.json');

    var ass = BitmapData.fromBase64(shit[3], 'UTF8');
    var shitass = ass.encode(ass.rect, new PNGEncoderOptions());
    shitass.position = 0;

    new FileReference().save(shitass, eventName + '.png');
}