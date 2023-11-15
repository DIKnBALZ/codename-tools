import flixel.FlxG;
import flixel.FlxBasic;
import flixel.group.FlxTypedGroup;
import funkin.backend.assets.Paths;
import funkin.editors.ui.UIText;
import funkin.backend.scripting.Script;
import funkin.backend.assets.ModsFolder;

class Window extends funkin.editors.ui.UISliceSprite {
    public var windowContent:FlxTypedGroup<FlxBasic>;
    public var windowCam:FlxCamera;
    public var windowTitle:UIText;

    public var windowScript:Script;

    public override function new(xPos:Float, yPos:Float, wWidth:Int, hHeight:Int, skin:String = 'desktop/window', scriptName:String) {
        frames = Paths.getFrames(skin);
		resize(wWidth, hHeight);

        windowContent = new FlxTypedGroup();
        members.push(windowContent);

        windowCam = new FlxCamera(x + 8, y + 23, bWidth-16, bHeight-31);
        FlxG.cameras.add(windowCam, false);

        windowContent.cameras = [windowCam];

        windowScript = Script.create(Paths.script('data/desktop/windows/' + scriptName));
        windowScript.setParent(this);
        windowScript.load();
        windowScript.set('windowContent', windowContent);
        windowScript.set('title', 'Window Name');
        windowScript.call('create');

        windowTitle = new UIText(x + 4, y + 11, 0, windowScript.get('title'));
        members.push(windowTitle);
    }

    public override function update(elapsed:Float) {
        windowScript.call('update', [elapsed]);
        updatePosition();
    }

    public function updatePosition() {
        windowCam.setPosition(x + 8, y + 23);
        windowTitle.setPosition(x + 4, y + 3);
    }
}