import funkin.editors.ui.UIState;
import funkin.editors.ui.UIButtonList;
import funkin.editors.ui.UIButton;
import funkin.editors.ui.UICheckbox;
import funkin.editors.ui.UIText;
import funkin.editors.character.CharacterAnimButtons;
import openfl.net.FileReference;
import haxe.ds.StringMap;

// VARIABLES
var character:Character;
var ghostCharacter:Character;
var currentCharacter:String = 'bf';
var cameraPoint:FlxSprite;
var charcam:FlxCamera;
var uicam:FlxCamera;
var characterAnimsWindow:UIButtonList;
var curAnim:Int = 0;
var nextScroll:Array<Float> = [0, 0];
var animList;
var draggingProperties = {
	lastOffset: [0, 0],
	nextOffset: [0, 0]
};

// UI VARIABLES
var saveButton:UIButton;
var frameCheck:UICheckbox;
var globalCheck:UICheckbox;
var cameraOffsetText:UIText;

function create() {
	FlxG.mouse.enabled = true;
	FlxG.mouse.visible = true;

	currentCharacter = stupidShit;

	charcam = new FlxCamera(0, 0);
	charcam.bgColor = 0xFF656565;
	FlxG.cameras.remove(FlxG.camera, false);
	FlxG.cameras.add(charcam, false);
	FlxG.cameras.add(FlxG.camera, false);
	FlxG.camera.bgColor = 0x00000000;

	uicam = new FlxCamera(0, 0);
	uicam.bgColor = 0x00000000;
	FlxG.cameras.add(uicam, false);

	var ref = new Character(0, 0, 'dad');
    ref.cameras = [charcam];
	ref.screenCenter();
	ref.color = 0xFF000000;
	ref.alpha = 0.5;
    add(ref);
	ref.playAnim('idle', true);
	ref.animation.paused = true;
	ref.animation.curAnim.curFrame = 0;

	ghostCharacter = new Character(0, 0, currentCharacter);
	ghostCharacter.isPlayer = ghostCharacter.xml.get('isPlayer') == 'true';
	ghostCharacter.fixChar();
    ghostCharacter.cameras = [charcam];
	ghostCharacter.screenCenter();
	ghostCharacter.alpha = 0.5;
    add(ghostCharacter);
	ghostCharacter.playAnim(ghostCharacter.isGF ? 'danceLeft' : 'idle', true);
	ghostCharacter.animation.paused = true;
	ghostCharacter.animation.curAnim.curFrame = 0;

	character = new Character(0, 0, currentCharacter);
	character.isPlayer = character.xml.get('isPlayer') == 'true';
	character.fixChar();
    character.cameras = [charcam];
	character.screenCenter();
    add(character);

	if (character.isPlayer) {
		for (i in [character, ghostCharacter]) {
			CoolUtil.switchAnimFrames(i.animation.getByName('singRIGHT'), i.animation.getByName('singLEFT'));
			CoolUtil.switchAnimFrames(i.animation.getByName('singRIGHTmiss'), i.animation.getByName('singLEFTmiss'));
			i.switchOffset('singLEFT', 'singRIGHT');
			i.switchOffset('singLEFTmiss', 'singRIGHTmiss');
		}
	}

	animList = character.getAnimOrder();

	charcam.scroll.x = -character.x + 250;
	charcam.scroll.y = character.y;
	nextScroll = [charcam.scroll.x, charcam.scroll.y];

	ref.setPosition(0, 0);
	character.setPosition(0, 0);
	ghostCharacter.setPosition(0, 0);

	var charCameraPos = character.getCameraPosition();
	cameraPoint = new FlxSprite(charCameraPos.x, charCameraPos.y).loadGraphic(Paths.image('dumb'));
	cameraPoint.antialiasing = false;
	cameraPoint.scale.set(9,9);
	cameraPoint.cameras = [charcam];
	add(cameraPoint);

	characterAnimsWindow = new UIButtonList(FlxG.width - 483, FlxG.height - 498, 473, 488, "Character Animations", FlxPoint.get(429, 32));
	characterAnimsWindow.cameras = [uicam];
	for (i in animList) {
		var stupid = new CharacterAnimButtons(0, 0, i, character.getAnimOffset(i));

		stupid.callback = function () {
			character.playAnim(stupid.anim, true);
		};

		stupid.ghostButton.callback = function() {
			ghostCharacter.playAnim(stupid.anim, true);
			ghostCharacter.animation.paused = true;
			ghostCharacter.animation.curAnim.curFrame = frameCheck.checked ? ghostCharacter.animation.numFrames : 0;
		};

		characterAnimsWindow.add(stupid);
	}
	add(characterAnimsWindow);

	frameCheck = new UICheckbox(characterAnimsWindow.x, characterAnimsWindow.y, 'Ghosts use the Last Frame', false, 0);
	frameCheck.cameras = [uicam];
	frameCheck.x = FlxG.width - frameCheck.width - frameCheck.field.width - 15;
	frameCheck.y -= frameCheck.height;
	frameCheck.onChecked = function() {
		ghostCharacter.animation.curAnim.curFrame = frameCheck.checked ? ghostCharacter.animation.numFrames : 0;
	};
	add(frameCheck);

	globalCheck = new UICheckbox(frameCheck.x, frameCheck.y, 'Edit Global Offset', false, 0);
	globalCheck.cameras = [uicam];
	globalCheck.x = FlxG.width - globalCheck.width - globalCheck.field.width - 15;
	globalCheck.y -= globalCheck.height;
	add(globalCheck);

	saveButton = new UIButton(0, 0, "Save", save);
	saveButton.cameras = [uicam];
	saveButton.setPosition(FlxG.width - saveButton.bWidth - 10, 10);
	add(saveButton);

	cameraOffsetText = new UIText(0, 0, 0, 'boobies');
	cameraOffsetText.cameras = [uicam];
	cameraOffsetText.x = FlxG.width - cameraOffsetText.width - 10;
	cameraOffsetText.y = saveButton.y + cameraOffsetText.height + 15;
	add(cameraOffsetText);
}

function boolToInt(bool, values)
	return bool ? values[1] : values[0];

function update(elapsed:Float) {
	// DEBUG STUFF
	if (FlxG.keys.justPressed.EIGHT) FlxG.switchState(new UIState(true, 'tools/NewCharacterEditor'));
	if (FlxG.keys.justPressed.ESCAPE) FlxG.switchState(new UIState(true, 'tools/CharacterSelector'));

	if (FlxG.keys.justPressed.ENTER) trace(charcam.scroll.x + ', ' + charcam.scroll.y);

	// CAMERA MOVEMENT
	if (FlxG.mouse.pressedMiddle || (FlxG.mouse.pressed && FlxG.keys.pressed.SPACE))
        nextScroll = [nextScroll[0] - (FlxG.mouse.deltaScreenX/charcam.zoom), nextScroll[1] - (FlxG.mouse.deltaScreenY/charcam.zoom)];

	if (FlxG.mouse.wheel != 0 && !characterAnimsWindow.hovered)
		charcam.zoom += (4 * FlxG.mouse.wheel) * elapsed;

	charcam.scroll.set(nextScroll[0], nextScroll[1]);

	// KEYBIND STUFF
	if (FlxG.keys.justPressed.SPACE) character.playAnim(character.getAnimName(), true);

	// OFFSET STUFF
	var curEditing = globalCheck.checked ? character.globalOffset : character.animOffsets[character.getAnimName()];
	if (FlxG.mouse.pressed && hoveredSprite == null && ![characterAnimsWindow.hovered, frameCheck.hovered, globalCheck.hovered, saveButton.hovered].contains(true)) {
		draggingProperties.lastOffset = [curEditing.x, curEditing.y];
		dragging = true;
		draggingProperties.nextOffset = [
			draggingProperties.nextOffset[0] - ((FlxG.mouse.deltaScreenX/charcam.zoom) * boolToInt(globalCheck.checked, [1, -1])),
			draggingProperties.nextOffset[1] - ((FlxG.mouse.deltaScreenY/charcam.zoom) * boolToInt(globalCheck.checked, [1, -1]))
		];
	} else {
		dragging = false;
		draggingProperties.nextOffset = [curEditing.x, curEditing.y];
	}

	if (dragging) {
		if (!globalCheck.checked) {
			character.animOffsets[character.getAnimName()].x = Std.int(draggingProperties.nextOffset[0]/(character.animOffsets[character.getAnimName()].x == draggingProperties.lastOffset[0] ? 1 : charcam.zoom));
			character.animOffsets[character.getAnimName()].y = Std.int(draggingProperties.nextOffset[1]/(character.animOffsets[character.getAnimName()].y == draggingProperties.lastOffset[1] ? 1 : charcam.zoom));
			ghostCharacter.animOffsets[character.getAnimName()].x = character.animOffsets[character.getAnimName()].x;
			ghostCharacter.animOffsets[character.getAnimName()].y = character.animOffsets[character.getAnimName()].y;
	
			for (i in characterAnimsWindow.buttons.members)
				if (i.anim == character.getAnimName())
					i.field.text = character.getAnimName() + ' (' + character.animOffsets[character.getAnimName()].x + ', ' + character.animOffsets[character.getAnimName()].y + ')';
	
			character.frameOffset.set(character.getAnimOffset(character.getAnimName()).x, character.getAnimOffset(character.getAnimName()).y);
			if (character.getAnimName() == ghostCharacter.getAnimName()) ghostCharacter.frameOffset.set(ghostCharacter.getAnimOffset(ghostCharacter.getAnimName()).x, ghostCharacter.getAnimOffset(ghostCharacter.getAnimName()).y);
		} else {
			character.globalOffset.x = Std.int(draggingProperties.nextOffset[0]/(character.globalOffset.x == draggingProperties.lastOffset[0] ? 1 : charcam.zoom));
			character.globalOffset.y = Std.int(draggingProperties.nextOffset[1]/(character.globalOffset.y == draggingProperties.lastOffset[1] ? 1 : charcam.zoom));
			character.playAnim(character.getAnimName(), true);

			ghostCharacter.globalOffset.x = character.globalOffset.x;
			ghostCharacter.globalOffset.y = character.globalOffset.y;
			ghostCharacter.playAnim(ghostCharacter.getAnimName(), true);
			ghostCharacter.animation.paused = true;
			ghostCharacter.animation.curAnim.curFrame = frameCheck.checked ? ghostCharacter.animation.numFrames : 0;
		}
	}

	if (FlxG.mouse.justPressedRight) {
		character.cameraOffset.x = Std.int(FlxG.mouse.getWorldPosition(charcam).x-(character.getCameraPosition().x-character.cameraOffset.x));
		character.cameraOffset.y = Std.int(FlxG.mouse.getWorldPosition(charcam).y-(character.getCameraPosition().y-character.cameraOffset.y));
	}

	// UI STUFF
	for (i in characterAnimsWindow.buttons.members) {
		i.ghostIcon.animation.play(i.anim == ghostCharacter.getAnimName() ? "alive" : "dead");
		i.ghostIcon.alpha = i.anim == ghostCharacter.getAnimName() ? 1 : 0.5;
	}

	var camPos = character.getCameraPosition();
	cameraPoint.setPosition(camPos.x, camPos.y);
	cameraOffsetText.text = 'Camera Offset: '+character.cameraOffset.x+', '+character.cameraOffset.y;
	cameraOffsetText.x = FlxG.width - cameraOffsetText.width - 10;
}

function save() {
	if (character.isPlayer) character.flipX = !character.flipX;

	var finalString:String = StringTools.replace(character.buildXML(animList).toString(), '><', '>\n<');
	for (line in finalString.split('\n'))
		if (StringTools.startsWith(line, '<anim'))
			finalString = StringTools.replace(finalString, line, '	' + line);
    new FileReference().save(finalString, currentCharacter + '.xml');

	if (character.isPlayer) character.flipX = !character.flipX;
}