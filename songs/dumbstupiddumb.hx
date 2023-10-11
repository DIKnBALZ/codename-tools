import funkin.editors.ui.UIState;

function update(elapsed)
    if (FlxG.keys.justPressed.HOME)
        FlxG.switchState(new UIState(true, 'ToolSelection'));