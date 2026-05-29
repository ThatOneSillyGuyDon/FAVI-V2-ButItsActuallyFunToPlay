import openfl.filters.ShaderFilter;

import funkin.game.shaders.DropShadowShader;

var vault;
var vaultDoor;
var chainsBehindLight;
var wires;
var lights;
var chainsFrontofLight;
var lightsOverlay;
var vaultRoom;
var vaultLight;
var vaultFore;
var theDoor;
var overlay1;
var overlay2;
var overlay3;
var overlay4;
var path = "stages/vault/";
var subpath = 'vaultRoom/';
var dropShadowArray:Array<DropShadowShader> = [];
var shader1 = newShader('adjustColor');
var shaderAnim:Float = 0;

function onLoad()
{
	vaultRoom = new FlxSprite(250, 0).loadGraphic(Paths.image(path + subpath + "VaultBG"));
	vault = new FlxSprite(0, 0).loadGraphic(Paths.image(path + 'MainBG'));
	vaultDoor = new FlxSprite(1750, 340).loadGraphic(Paths.image(path + 'vaultDoor'));
	chainsBehindLight = new FlxSprite(-50, -150).loadGraphic(Paths.image(path + 'ChainsBehindLight'));
	wires = new FlxSprite(942, -100).loadGraphic(Paths.image(path + 'WeirdHangingWires'));
	lights = new FlxSprite(125, 0).loadGraphic(Paths.image(path + 'HangingLights'));
	chainsFrontofLight = new FlxSprite(0, 0).loadGraphic(Paths.image(path + 'ChainsFrontofLight'));
	lightsOverlay = new FlxSprite(0, 0).loadGraphic(Paths.image(path + 'Lights'));
	vaultFore = new FlxSprite(250, 0).loadGraphic(Paths.image(path + subpath + "VaultFG"));
	overlay1 = new FlxSprite(0, 0).loadGraphic(Paths.image(path + 'BlackOverlay'));
	overlay2 = new FlxSprite(0, 0).makeGraphic(vault.frameWidth, vault.frameHeight, 0xFFFFC05C, true, 'OrangeOverlay');
	overlay3 = new FlxSprite(0, 0).loadGraphic(Paths.image(path + 'ScribbleOverlay'));
	overlay4 = new FlxSprite(0, 0).loadGraphic(Paths.image(path + 'EverettOverlay'));
	
	if (ClientPrefs.shaders)
	{
		for (i in 0...6)
		{
			var shader = new DropShadowShader();
			switch (i)
			{
				case 0:
					shader.setAdjustColor(-40, -23, -9, -20); // VAULT DOOR
					shader.angle = 90;
					shader.distance = 45;
					shader.color = 0xff593d21;
					shader.threshold = 0.2;
				case 4:
					shader.setAdjustColor(-88, -20, -30, -25); // EVERETT
					shader.angle = 90;
					shader.distance = 17;
					shader.color = 0xffb88c60;
					shader.threshold = 0.15;
					shader.antialiasAmt = 4;
				case 5:
					shader.setAdjustColor(-36, -20, 20, -30); // WHITE NOISE
					shader.angle = 0;
					shader.distance = 0;
					shader.color = 0xff614122;
					shader.threshold = 0.2;
					shader.antialiasAmt = 3;
				case 1 | 2 | 3:
					shader.setAdjustColor(-40, -23, -9, -20); // FOREGROUND OBJECTS
					shader.angle = 270;
					shader.distance = 30;
					shader.color = 0xffa98051;
					shader.threshold = 0.2;
			}
			dropShadowArray.push(shader);
		}
	}
	
	for (i in [vaultRoom, vault, vaultDoor])
		add(i);
}

function onCreatePost()
{
	chainsBehindLight.scrollFactor.set(0.8, 0.8);
	wires.scrollFactor.set(0.9, 0.9);
	chainsFrontofLight.scrollFactor.set(1.1, 1.1);
	
	vaultFore.visible = false;
	
	for (i in [chainsBehindLight, wires, lights, chainsFrontofLight, overlay4, overlay3, lightsOverlay, overlay1, overlay2, vaultFore])
		add(i);
		
	overlay4.blend = 14;
	overlay3.blend = 2;
	overlay1.alpha = 9;
	overlay2.alpha = 11;
	
	overlay4.alpha = .27;
	overlay3.alpha = .41;
	overlay1.alpha = .17;
	overlay2.alpha = .14;
	
	lightsOverlay.blend = 0;
	lightsOverlay.alpha = .43;
	lightsOverlay.color = 0xffffd9a0;
	
	if (ClientPrefs.shaders)
	{
		shader1.setFloat('brightness', -45);
		shader1.setFloat('hue', -10);
		shader1.setFloat('contrast', -10);
		shader1.setFloat('saturation', -20);
		
		vault.shader = shader1;
		
		vaultDoor.shader = dropShadowArray[0];
		dropShadowArray[0].attachedSprite = vaultDoor;
		
		chainsBehindLight.shader = dropShadowArray[1];
		dropShadowArray[1].attachedSprite = chainsBehindLight;
		
		wires.shader = dropShadowArray[2];
		dropShadowArray[2].attachedSprite = wires;
		
		chainsFrontofLight.shader = dropShadowArray[3];
		dropShadowArray[3].attachedSprite = chainsFrontofLight;
		
		boyfriend.shader = dropShadowArray[4];
		dropShadowArray[4].attachedSprite = boyfriend;
		boyfriend.animation.onFrameChange.add(function(name, frameNum, frameIndex) {
			dropShadowArray[4].updateFrameInfo(boyfriend.frame);
		});
		
		dad.shader = dropShadowArray[5];
		dropShadowArray[5].attachedSprite = dad;
		dad.animation.onFrameChange.add(function(name, frameNum, frameIndex) {
			dropShadowArray[5].updateFrameInfo(dad.frame);
		});
	}
	
	dad.blend = 0;
	iconP2.blend = 0;
}
