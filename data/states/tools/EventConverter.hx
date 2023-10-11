import funkin.editors.ui.UIState;
import funkin.editors.ui.UIButton;
import funkin.editors.ui.UIFileExplorer;
import funkin.editors.ui.UIText;
import funkin.editors.ui.UITextBox;
import openfl.net.FileReference;
import haxe.crypto.Base64;
import sys.io.File;

var jsonfile:UIFileExplorer;
var hxfile:UIFileExplorer;
var imagefile:UIFileExplorer;
var textbox:UITextBox;
var labels:UIText;
var button:UIButton;

function create() {
    FlxG.camera.bgColor = 0xFF656565;
    FlxG.mouse.visible = true;

    textbox = new UITextBox(0, 0, '');
    add(textbox);

    labels = new UIText(0, 0, 0, 'NAME\n\n\nJSON\n\n\n  HX\n\n\n PNG', 24, 0xFFFFFFFF, true);
    add(labels);

    jsonfile = new UIFileExplorer(475, 275, 'json');
    add(jsonfile);

    labels.x = jsonfile.x - 64;
    textbox.x = jsonfile.x;
    textbox.y = jsonfile.y - 64;
    labels.y = textbox.y;

    hxfile = new UIFileExplorer(jsonfile.x, jsonfile.y + 65, 'hx');
    add(hxfile);

    imagefile = new UIFileExplorer(hxfile.x, hxfile.y + 65, 'png');
    add(imagefile);

    button = new UIButton(imagefile.x, imagefile.y + 65, 'Convert Event', convert, 320, 64);
    add(button);
}

function update(elapsed) {
    if (FlxG.keys.justPressed.EIGHT)
        FlxG.switchState(new UIState(true, 'tools/EventConverter'));

    if (FlxG.keys.justPressed.ESCAPE)
        FlxG.switchState(new UIState(true, 'ToolSelection'));
}

function convert() {
    var hscriptText:String = StringTools.replace(hxfile.file, '\n\n', '');
    var imageText:String = Base64.encode(imagefile.file, true);
    var separator:String = '________PACKSEP________';

    var packText:String = textbox.label.text + '.hx' + separator + hscriptText + separator + jsonfile.file + separator + imageText;
    new FileReference().save(packText, textbox.label.text + '.pack');
}