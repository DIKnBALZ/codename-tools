import funkin.editors.ui.UIState;
import funkin.editors.ui.UIButton;
import funkin.editors.ui.UIFileExplorer;
import funkin.editors.ui.UIText;
import openfl.net.FileReference;
import flixel.util.FlxColor;

var jsonfile:UIFileExplorer;
var label:UIText;
var button:UIButton;

function create() {
    FlxG.camera.bgColor = 0xFF656565;
    FlxG.mouse.visible = true;

    label = new UIText(0, 0, 0, 'JSON', 24, 0xFFFFFFFF, true);
    add(label);

    jsonfile = new UIFileExplorer(475, 275, null, null, 'json');
    add(jsonfile);

    label.x = jsonfile.x - 64;
    label.y = jsonfile.y;

    button = new UIButton(jsonfile.x, jsonfile.y + 65, 'Convert Character', convert, 320, 64);
    add(button);
}

function update(elapsed) {
    if (FlxG.keys.justPressed.EIGHT)
        FlxG.switchState(new UIState(true, 'tools/CharacterConverter'));

    if (FlxG.keys.justPressed.ESCAPE)
        FlxG.switchState(new UIState(true, 'ToolSelection'));
}

function convert() {
    var json = CoolUtil.parseJsonString(jsonfile.file);
    var xmlNew = '<!DOCTYPE codename-engine-character> <!-- Made with WizardMantis\'s Character Converter that was modified by inky lol -->\n<character isPlayer="false" x="'+json.position[0]+'" y="'+json.position[1]+'" icon="'+json.healthicon+'" flipX="'+json.flip_x+'" camx="'+json.camera_position[0]+'" camy="'+json.camera_position[1]+'" holdTime="'+json.sing_duration+'" scale="'+json.scale+'" color="'+toHexString(json)+'">\n';
    for (i in 0...json.animations.length) {
        xmlNew += '\t<anim name="'+json.animations[i].anim+'" anim="'+json.animations[i].name+'" fps="'+json.animations[i].fps+'" loop="'+json.animations[i].loop+'" x="'+(json.animations[i].offsets[0])+'" y="'+(json.animations[i].offsets[1])+'"';
        if (json.animations[i].indices.length > 0) xmlNew += ' indices="'+StringTools.replace(StringTools.replace(json.animations[i].indices, '[', ''), ']', '')+'"/>\n';
        else xmlNew += '/>\n';
    }
    xmlNew += '</character>';
    new FileReference().save(xmlNew, 'character.xml');
}

function toHexString(json)
    return "#" + StringTools.hex(json.healthbar_colors[0], 2) + StringTools.hex(json.healthbar_colors[1], 2) + StringTools.hex(json.healthbar_colors[2], 2);