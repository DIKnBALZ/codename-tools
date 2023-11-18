import funkin.backend.assets.ModsFolder;
import funkin.editors.ui.UIState;
import funkin.editors.ui.UIButton;
import sys.FileSystem;

var buttons:FlxGroup;

function create() {
    buttons = new FlxGroup();
    
    FlxG.camera.bgColor = 0xFF656565;
    FlxG.mouse.visible = true;

    var path = ModsFolder.currentModFolder == '' || ModsFolder.currentModFolder == null ? 'assets/' : 'mods/' + ModsFolder.currentModFolder;
    for (i in Paths.getFolderContent('data/characters', false, false)) {
        var button = new UIButton(0, 52, i, function() {
            stupidShit = StringTools.replace(i, '.xml', '');
		    FlxG.switchState(new UIState(true, 'tools/character-editor/NewCharacterEditor'));
        }, 320, 64);
        button.screenCenter(FlxAxes.X);
        button.setPosition(button.x - 160, button.y - 16 + (96*buttons.members.length));
        buttons.add(button);
    }

    add(buttons);
}

var penis:Float = 0;
function update(elapsed) {
    penis += FlxG.mouse.wheel * -50;
    FlxG.camera.scroll.y = CoolUtil.fpsLerp(FlxG.camera.scroll.y, penis, 0.5);

    if (FlxG.keys.justPressed.EIGHT)
        FlxG.switchState(new UIState(true, 'CharacterSelector'));

    if (FlxG.keys.justPressed.ESCAPE)
        FlxG.switchState(new UIState(true, 'ToolSelection'));
}