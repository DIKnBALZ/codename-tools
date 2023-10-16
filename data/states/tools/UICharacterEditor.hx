import funkin.editors.ui.UIButton;
import funkin.editors.ui.UITopMenu;
import funkin.editors.ui.UIState;
import funkin.editors.ui.UIWarningSubstate;
import lime.ui.FileDialog;
import sys.io.File;
import lime.ui.FileDialogType;
import funkin.game.Character;
import StringTools;
import haxe.ds.StringMap;

var charcam:FlxCamera;
var uicam:FlxCamera;
var ghostCharacter:Character;
var character:Character;
var infoText:FlxText;
var offsetText:FlxText;
var nextButton:UIButton;
var prevButton:UIButton;
var globalOffsetText:FlxText;
var cameraPoint:FlxSprite;
var cameraOffsetText:FlxText;

var editingGlobal:Bool = false;
var editingLocal:Bool = true;
var editingCamera:Bool = false;
var dragging:Bool = false;
var animList:Array<String> = [];
var nextScroll = [0, 0];
var nextOffset = [0, 0];
var lastOffset = [0, 0];
var nextGlobalOffset = [0, 0];
var lastGlobalOffset = [0, 0];
var curAnim:Int = 0;
var animXmls:StringMap<Xml>;

function create()
{
	charcam = new FlxCamera(0, 0);
	charcam.bgColor = 0xFF3C353E;
	FlxG.cameras.remove(FlxG.camera, false);
	FlxG.cameras.add(charcam, false);
	FlxG.cameras.add(FlxG.camera, false);
	FlxG.camera.bgColor = 0x00000000;

	uicam = new FlxCamera(0, 0);
	uicam.bgColor = 0x00000000;
	FlxG.cameras.add(uicam, false);

	// FlxG.sound.music.volume = 0;
	FlxG.mouse.enabled = true;
	FlxG.mouse.visible = true;

	var ref = new Character(0, 0, 'dad', false);
	ref.cameras = [charcam];
	ref.color = 0xFF000000;
	ref.alpha = 0.5;
	ref.screenCenter();
	add(ref);

	for (anim in ref.animOffsets.keys())
	{
		var offsets = ref.animOffsets[anim];
		if (offsets == null || !ref.hasAnimation(anim)) continue;
		animList.push(anim);
	}

	ghostCharacter = new Character(ref.x, ref.y, 'dad', false);
	ghostCharacter.cameras = [charcam];
	ghostCharacter.alpha = 0.5;
	ghostCharacter.playAnim('idle', true);
	add(ghostCharacter);

	character = new Character(ref.x, ref.y, 'dad', false);
	character.cameras = [charcam];
	character.playAnim(animList[curAnim], true);
	add(character);

	infoText = new FlxText(FlxG.width-250, 25, 0, 'Editing LOCAL Offset', 25);
	infoText.cameras = [uicam];
	infoText.x = FlxG.width-7-(infoText.width);
	add(infoText);

	offsetText = new FlxText(infoText.x, 75, 0, 'Animation Name [offsetX, offsetY]\n[null out of null]', 25);
	offsetText.cameras = [uicam];
	add(offsetText);

	var topmenu:UITopMenu = new UITopMenu([
		{
			label: "File",
			childs: [
				{
					label: "Open",
					onSelect: () ->
					{
						var fDial = new FileDialog();
						fDial.onSelect.add(function(file){openChar(file);});
						fDial.browse(FileDialogType.OPEN, 'xml', null, 'Open a Codename Engine Character XML.');
					}
				},
				{
					label: "Save",
					onSelect: () ->
					{
						save();
					}
				},
				null,
				{
					label: "Exit",
					onSelect: () ->
					{
						openSubState(new UIWarningSubstate("Warning!", "You may or may not have unsaved changes. Are you sure you exit back to the tool selector?", [
							{
								label: "No",
								onClick: function(t)
								{
								}
							},
							{
								label: "Yes",
								onClick: function(t)
								{
									FlxG.switchState(new UIState(true, 'ToolSelection'));
								}
							}
						]));
					}
				}
			]
		},
		{
			label: "Offsets",
			childs: [
				{
					label: "Edit Global Offset",
					onSelect: () ->
					{
						editingGlobal = true;
						editingLocal = false;
						editingCamera = false;
						infoText.text = 'Editing GLOBAL Offset';
						infoText.x = FlxG.width-7-(infoText.width);
					}
				},
				{
					label: "Edit Local Offset",
					onSelect: () ->
					{
						editingGlobal = false;
						editingLocal = true;
						editingCamera = false;
						infoText.text = 'Editing LOCAL Offset';
						infoText.x = FlxG.width-7-(infoText.width);
					}
				},
				{
					label: "Edit Camera Offset",
					onSelect: () ->
					{
						editingGlobal = false;
						editingLocal = false;
						editingCamera = true;
						infoText.text = 'Editing CAMERA Offset';
						infoText.x = FlxG.width-7-(infoText.width);
					}
				}
			]
		},
		{
			label: "View",
			childs: [
				{
					label: "Reference",
					onSelect: () ->
					{
						ref.visible = !ref.visible;
					}
				},
				{
					label: "Ghost",
					onSelect: () ->
					{
						ghostCharacter.visible = !ghostCharacter.visible;
					}
				}
			]
		},
		{
			label: "Help",
			childs: [
				{
					label: "Controls",
					onSelect: () ->
					{
						openSubState(new UIWarningSubstate("Controls", 
						"Midde Mouse Button or Mouse + Space or WASD - Move Camera
						Mouse Wheel - Zoom Camera

						Arrow Keys - Move Offset
						Control (Hold) - Smaller Offset Movement
						Shift (Hold) - Larger Offset Movement", [
							{
								label: "OK",
								onClick: function(t)
								{
								}
							}
						], false));
					}
				}
			]
		}
	]);
	topmenu.cameras = [uicam];
	add(topmenu);

	nextButton = new UIButton(offsetText.x, offsetText.y+offsetText.height+10, "Next", function(){
		if (curAnim+1 < animList.length)
			curAnim++;character.playAnim(animList[curAnim], true);

        nextOffset = [character.animOffsets[character.getAnimName()].x, character.animOffsets[character.getAnimName()].y];
        lastOffset = nextOffset;
        nextGlobalOffset = [character.globalOffset.x, character.globalOffset.y];
        lastGlobalOffset = [character.globalOffset.x, character.globalOffset.y];
	});
	nextButton.cameras = [uicam];
	add(nextButton);

	prevButton = new UIButton(nextButton.x, nextButton.y+40, "Previous", function(){
		if (curAnim+1 > 1)
			curAnim--;character.playAnim(animList[curAnim], true);

		nextOffset = [character.animOffsets[character.getAnimName()].x, character.animOffsets[character.getAnimName()].y];
        lastOffset = nextOffset;
        nextGlobalOffset = [character.globalOffset.x, character.globalOffset.y];
        lastGlobalOffset = [character.globalOffset.x, character.globalOffset.y];
	});
	prevButton.cameras = [uicam];
	add(prevButton);

	globalOffsetText = new FlxText(infoText.x, prevButton.y+40, 0, 'Global Offset: 0, 0', 25);
	globalOffsetText.cameras = [uicam];
	add(globalOffsetText);

	cameraOffsetText = new FlxText(infoText.x, globalOffsetText.y+globalOffsetText.height, 0, 'Camera Offset: 0, 0', 25);
	cameraOffsetText.cameras = [uicam];
	add(cameraOffsetText);

	var charCameraPos = character.getCameraPosition();
	cameraPoint = new FlxSprite(charCameraPos.x, charCameraPos.y).loadGraphic(Paths.image('dumb'));
	cameraPoint.antialiasing = false;
	cameraPoint.scale.set(9,9);
	cameraPoint.cameras = [charcam];
	add(cameraPoint);

	animXmls = new StringMap();
	for (anim in character.xml.elementsNamed("anim")) {
		animXmls.set(anim.get("name"), anim);
	}
}

function openChar(file) {
	var fileName = file.split('\\');
	fileName = fileName[fileName.length - 1].split('.');
	fileName = fileName[fileName.length - 2];
	remove(ghostCharacter);
	remove(character);
	ghostCharacter = new Character(ghostCharacter.x, ghostCharacter.y, fileName, false);
	ghostCharacter.cameras = [charcam];
	ghostCharacter.playAnim('idle', true);
	ghostCharacter.alpha = 0.5;
	add(ghostCharacter);
	character = new Character(character.x, character.y, fileName, false);
	character.cameras = [charcam];
	add(character);
	animList = [];
	for (anim in character.animOffsets.keys())
	{
		var offsets = character.animOffsets[anim];
		if (offsets == null || !character.hasAnimation(anim)) continue;
		animList.push(anim);
	}
	character.playAnim(animList[curAnim], true);

	animXmls = new StringMap();
	for (anim in character.xml.elementsNamed("anim")) {
		animXmls.set(anim.get("name"), anim);
	}
}

function update(elapsed:Float) {
	if (FlxG.keys.justPressed.EIGHT)
		FlxG.switchState(new UIState(true, 'tools/UICharacterEditor'));

	if (FlxG.keys.pressed.A)
		charcam.scroll.x -= 500 / charcam.zoom * elapsed;
	if (FlxG.keys.pressed.S)
		charcam.scroll.y += 500 / charcam.zoom * elapsed;
	if (FlxG.keys.pressed.W)
		charcam.scroll.y -= 500 / charcam.zoom * elapsed;
	if (FlxG.keys.pressed.D)
		charcam.scroll.x += 500 / charcam.zoom * elapsed;
	if (FlxG.mouse.wheel < 0)
		charcam.zoom -= 4 * elapsed;
	if (FlxG.mouse.wheel > 0)
		charcam.zoom += 4 * elapsed;

	if (FlxG.keys.justPressed.ENTER)
		character.playAnim(character.getAnimName(), true);
	if (FlxG.keys.justPressed.LEFT)
		if (editingGlobal)
			offsetChar(true, false, !character.isPlayer?-1:1);
		else if (editingLocal)
			offsetChar(false, false, !character.isPlayer?1:-1);
		else if (editingCamera) {
			character.cameraOffset.x -= (FlxG.keys.pressed.SHIFT?10:(FlxG.keys.pressed.CONTROL?1:5));
			character.xml.set("camx", character.cameraOffset.x);
		}
	if (FlxG.keys.justPressed.DOWN)
		if (editingGlobal)
			offsetChar(true, true, 1);
		else if (editingLocal)
			offsetChar(false, true, 1);
		else if (editingCamera) {
			character.cameraOffset.y += (FlxG.keys.pressed.SHIFT?10:(FlxG.keys.pressed.CONTROL?1:5));
			character.xml.set("camy", character.cameraOffset.y);
		}
	if (FlxG.keys.justPressed.UP)
		if (editingGlobal)
			offsetChar(true, true, -1);
		else if (editingLocal)
			offsetChar(false, true, -1);
		else if (editingCamera) {
			character.cameraOffset.y -= (FlxG.keys.pressed.SHIFT?10:(FlxG.keys.pressed.CONTROL?1:5));
			character.xml.set("camy", character.cameraOffset.y);
		}
	if (FlxG.keys.justPressed.RIGHT)
		if (editingGlobal)
			offsetChar(true, false, !character.isPlayer?1:-1);
		else if (editingLocal)
			offsetChar(false, false, !character.isPlayer?-1:1);
		else if (editingCamera) {
			character.cameraOffset.x += (FlxG.keys.pressed.SHIFT?10:(FlxG.keys.pressed.CONTROL?1:5));
			character.xml.set("camx", character.cameraOffset.x);
		}
	if (FlxG.keys.justPressed.R)
		if (editingGlobal) {
			character.globalOffset.x = character.globalOffset.y = 0;
			character.xml.set("x", character.globalOffset.x);
			character.xml.set("y", character.globalOffset.y);
			character.playAnim(animList[curAnim], false);
		} else if (editingLocal) {
			character.animOffsets[character.getAnimName()].x = character.animOffsets[character.getAnimName()].y = 0;
			animXmls[animList[curAnim]].set("x", character.animOffsets[animList[curAnim]].x);
			animXmls[animList[curAnim]].set("y", character.animOffsets[animList[curAnim]].y);
			character.playAnim(animList[curAnim], false);
		} else if (editingCamera) {
			character.cameraOffset.x = character.cameraOffset.y = 0;
			character.xml.set("camx", character.cameraOffset.x);
			character.xml.set("camy", character.cameraOffset.y);
		}
	
	offsetText.text = character.getAnimName()+' ['+character.animOffsets[character.getAnimName()].x+', '+character.animOffsets[character.getAnimName()].y+']\n['+(animList.indexOf(character.getAnimName())+1)+' out of '+animList.length+']';
	offsetText.x = FlxG.width-7-(offsetText.width);
	globalOffsetText.text = 'Global Offset: '+character.globalOffset.x+', '+character.globalOffset.y;
	globalOffsetText.x = FlxG.width-7-(globalOffsetText.width);
	var camPos = character.getCameraPosition();
	cameraPoint.setPosition(camPos.x, camPos.y);
	cameraOffsetText.text = 'Camera Offset: '+character.cameraOffset.x+', '+character.cameraOffset.y;
	cameraOffsetText.x = FlxG.width-7-(cameraOffsetText.width);

	if (FlxG.mouse.pressedMiddle || (FlxG.mouse.pressed && FlxG.keys.pressed.SPACE))
        nextScroll = [nextScroll[0] - FlxG.mouse.deltaScreenX, nextScroll[1] - FlxG.mouse.deltaScreenY];

	if (editingLocal) {
		if (FlxG.mouse.pressed && hoveredSprite == null && ![nextButton.hovered, prevButton.hovered].contains(true)) {
			lastOffset = [character.animOffsets[character.getAnimName()].x, character.animOffsets[character.getAnimName()].y];
			dragging = true;
			nextOffset = [nextOffset[0] - (FlxG.mouse.deltaScreenX/charcam.zoom), nextOffset[1] - (FlxG.mouse.deltaScreenY/charcam.zoom)];
		} else {
			dragging = false;
			nextOffset = [character.animOffsets[character.getAnimName()].x, character.animOffsets[character.getAnimName()].y];
		}
	} else if (editingGlobal) {
		if (FlxG.mouse.pressed && hoveredSprite == null && ![nextButton.hovered, prevButton.hovered].contains(true)) {
			lastGlobalOffset = [character.globalOffset.x, character.globalOffset.y];
			dragging = true;
			nextGlobalOffset = [nextGlobalOffset[0] + (FlxG.mouse.deltaScreenX/charcam.zoom), nextGlobalOffset[1] + (FlxG.mouse.deltaScreenY/charcam.zoom)];
		} else {
			dragging = false;
			nextGlobalOffset = [character.globalOffset.x, character.globalOffset.y];
		}
	}

	if (dragging) {
		if (editingLocal) {
			character.animOffsets[character.getAnimName()].x = nextOffset[0]/(character.animOffsets[character.getAnimName()].x == lastOffset[0] ? 1 : charcam.zoom);
			character.animOffsets[character.getAnimName()].y = nextOffset[1]/(character.animOffsets[character.getAnimName()].y == lastOffset[1] ? 1 : charcam.zoom);
			animXmls[animList[curAnim]].set("x", FlxMath.roundDecimal(character.animOffsets[animList[curAnim]].x, 0));
			animXmls[animList[curAnim]].set("y", FlxMath.roundDecimal(character.animOffsets[animList[curAnim]].y, 0));
			character.playAnim(animList[curAnim], true, 'NONE', false, character.animation.numFrames);
		} else if (editingGlobal) {
			character.globalOffset.x = nextGlobalOffset[0]/(character.globalOffset.x == lastGlobalOffset[0] ? 1 : charcam.zoom);
			character.globalOffset.y = nextGlobalOffset[1]/(character.globalOffset.y == lastGlobalOffset[1] ? 1 : charcam.zoom);
			character.xml.set("x", FlxMath.roundDecimal(character.globalOffset.x, 0));
			character.xml.set("y", FlxMath.roundDecimal(character.globalOffset.y, 0));
			character.playAnim(animList[curAnim], true, 'NONE', false, character.animation.numFrames);
		}
	}

	if (FlxG.mouse.justPressedRight) {
		character.cameraOffset.x = FlxMath.roundDecimal(FlxG.mouse.getWorldPosition(charcam).x-(character.getCameraPosition().x-character.cameraOffset.x), 0);
		character.cameraOffset.y = FlxMath.roundDecimal(FlxG.mouse.getWorldPosition(charcam).y-(character.getCameraPosition().y-character.cameraOffset.y), 0);
		character.xml.set("camx", character.cameraOffset.x);
		character.xml.set("camy", character.cameraOffset.y);
	}

    charcam.scroll.set(nextScroll[0]/charcam.zoom, nextScroll[1]/charcam.zoom);
}

function offsetChar(global:Bool, editY:Bool, modifier:Float) {
	if (global) {
		if (editY) {
			character.globalOffset.y -= (FlxG.keys.pressed.SHIFT?10:(FlxG.keys.pressed.CONTROL?1:5))*modifier;
			ghostCharacter.globalOffset.y -= (FlxG.keys.pressed.SHIFT?10:(FlxG.keys.pressed.CONTROL?1:5))*modifier;
			character.xml.set("y", character.globalOffset.y);
		}
		if (!editY) {
			character.globalOffset.x += (FlxG.keys.pressed.SHIFT?10:(FlxG.keys.pressed.CONTROL?1:5))*modifier;
			ghostCharacter.globalOffset.x += (FlxG.keys.pressed.SHIFT?10:(FlxG.keys.pressed.CONTROL?1:5))*modifier;
			character.xml.set("x", character.globalOffset.x);
		}
		ghostCharacter.playAnim(animList[curAnim], false);
	} else {
		if (editY) {
			character.animOffsets[character.getAnimName()].y -= (FlxG.keys.pressed.SHIFT?10:(FlxG.keys.pressed.CONTROL?1:5))*modifier;
			animXmls[animList[curAnim]].set("y", character.animOffsets[animList[curAnim]].y);
		}
		if (!editY) {
			character.animOffsets[character.getAnimName()].x += (FlxG.keys.pressed.SHIFT?10:(FlxG.keys.pressed.CONTROL?1:5))*modifier;
			animXmls[animList[curAnim]].set("x", character.animOffsets[animList[curAnim]].x);
		}
	}
	character.playAnim(animList[curAnim], false);
}

function save() {
	var xmlString = "<!DOCTYPE codename-engine-character> <!-- made with inky's character editor -->\n" + Std.string(character.xml);
	while (StringTools.contains(xmlString, "\n\n"))
		xmlString = StringTools.replace(xmlString, "\n\n", "");
	xmlString = StringTools.replace(xmlString, "/>\n\n</", "/>\n</");

	var fDial = new FileDialog();
	fDial.onSelect.add(function(file) {
		File.saveContent(file, xmlString);
	});
	fDial.browse(FileDialogType.SAVE, 'xml', null, 'Save your Codename Engine Character XML.');
}