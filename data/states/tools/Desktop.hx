import Sys;
import openfl.display.BitmapData;
import funkin.editors.ui.UIState;

import Window;

var test:Window;

function create() {
    FlxG.mouse.enabled = true;
	FlxG.mouse.visible = true;

    var wallpaper:FlxSprite = new FlxSprite();
    wallpaper.loadGraphic(BitmapData.fromFile(Sys.getEnv("AppData") + '\\Microsoft\\Windows\\Themes\\TranscodedWallpaper'));
    wallpaper.scrollFactor.set();
    wallpaper.antialiasing = true;
    wallpaper.setGraphicSize(FlxG.width, FlxG.height);
    wallpaper.updateHitbox();
    add(wallpaper);

    test = new Window(0, 0, 1024, 576, 'desktop/window', 'character-editor');
    test.screenCenter();
    test.x -= test.bWidth/2-32;
    test.y -= test.bHeight/2-32;
    add(test);
}

function update(elapsed:Float) {
    if (FlxG.keys.justPressed.EIGHT)
        FlxG.switchState(new UIState(true, 'tools/Desktop'));
    if (FlxG.keys.justPressed.ESCAPE)
        FlxG.switchState(new UIState(true, 'ToolSelection'));

    test.update(elapsed);
}