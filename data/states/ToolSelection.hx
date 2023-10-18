import funkin.editors.ui.UIState;
import funkin.editors.ui.UIButton;
import sys.FileSystem;

var buttons:FlxGroup;

function create() {
    buttons = new FlxGroup();
    
    FlxG.camera.bgColor = 0xFF656565;
    FlxG.mouse.visible = true;

    for (i in FileSystem.readDirectory('addons/codename-tools/data/states/tools')) {
        if (StringTools.endsWith(i, 'hx')) {
            var button = new UIButton(0, 52, i, function() {FlxG.switchState(new UIState(true, 'tools/' + StringTools.replace(i, '.hx', '')));}, 320, 64);
            button.screenCenter(FlxAxes.X);
            button.setPosition(button.x - 160, button.y - 16 + (96*buttons.members.length));
            buttons.add(button);
        }
    }

    add(buttons);
}

var penis:Float = 0;
function update(elapsed) {
    penis += FlxG.mouse.wheel * -50;
    FlxG.camera.scroll.y = CoolUtil.fpsLerp(FlxG.camera.scroll.y, penis, 0.5);

    if (FlxG.keys.justPressed.EIGHT)
        FlxG.switchState(new UIState(true, 'ToolSelection'));

    if (FlxG.keys.justPressed.ESCAPE)
        FlxG.switchState(new PlayState());
}