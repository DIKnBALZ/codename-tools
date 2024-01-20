import funkin.editors.ui.UIState;

function update(elapsed)
    if (FlxG.keys.justPressed.F9)
        FlxG.switchState(new UIState(true, 'ToolSelection'));