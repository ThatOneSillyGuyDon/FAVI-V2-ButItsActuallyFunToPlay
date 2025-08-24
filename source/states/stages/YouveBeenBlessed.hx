package states.stages;

import states.stages.objects.*;
import openfl.display.BlendMode;
#if !flash 
import openfl.filters.ShaderFilter;
#end

class YouveBeenBlessed extends BaseStage
{
	//BLESS
	var vault:FlxSprite;
	var vaultDoor:FlxSprite;
	var chainsBehindLight:FlxSprite;
	var wires:FlxSprite;
	var lights:FlxSprite;
	var chainsFrontofLight:FlxSprite;
	var lightsOverlay:FlxSprite;

	var vaultRoom:FlxSprite;
	var vaultLight:FlxSprite;
	var vaultFore:FlxSprite;

	var theDoor:FlxSprite;
	
	var dropShadowArray:Array<DropShadowShader> = [];

	// SHADER FOR BLESS ONLY CUZ IM DUMBASS - MalyPlus
	var othershader:FlxRuntimeShader = new FlxRuntimeShader(Shaders.blessLightsShit);
	public var shaderAnim:Float = 0;

	override function create()
	{
		vaultRoom = new FlxSprite(300, -350).loadGraphic(Paths.image(PlayState.pathway + "BACKGROUND/VaultBG"));
		add(vaultRoom);

		vaultFore = new FlxSprite(300, -350).loadGraphic(Paths.image(PlayState.pathway + "FOREGROUND/VaultFG"));
		add(vaultFore);

		vault = new FlxSprite(0, 0).loadGraphic(Paths.image(PlayState.pathway + 'BACKGROUND/MainBG'));
		vault.antialiasing = ClientPrefs.data.antialiasing;
		add(vault);

		// SETUP DROP SHADOW SHADER CONFIGS
		for (i in 0...6)
		{
			var shader = new DropShadowShader();
			switch(i)
			{
				case 0:
					shader.setAdjustColor(-40, -23, -9, -20); //VAULT DOOR
					shader.angle = 90;
					shader.distance = 45;
					shader.color = 0xff593d21;
					shader.threshold = 0.2;
				case 4:
					shader.setAdjustColor(-36, -20, 20, -20); //EVERETT
					shader.angle = 90;
					shader.distance = 17;
					shader.color = 0xff614122;
					shader.threshold = 0.15;
					shader.antialiasAmt = 4;
				case 5:
					shader.setAdjustColor(-36, -20, 20, -30); //WHITE NOISE
					shader.angle = 0;
					shader.distance = 0;
					shader.color = 0xff614122;
					shader.threshold = 0.2;
					shader.antialiasAmt = 3;
				case 1 | 2 | 3:
					shader.setAdjustColor(-40, -23, -9, -20); //FOREGROUND OBJECTS
					shader.angle = 270;
					shader.distance = 30;
					shader.color = 0xffa98051;
					shader.threshold = 0.2;
			}
			dropShadowArray.push(shader);
		}

		vaultDoor = new FlxSprite(1750, 340).loadGraphic(Paths.image(PlayState.pathway + 'BACKGROUND/vaultDoor'));
		vaultDoor.antialiasing = ClientPrefs.data.antialiasing;
		vaultDoor.shader = dropShadowArray[0];
		dropShadowArray[0].attachedSprite = vaultDoor;
		add(vaultDoor);
	}
	
	var blendModes:Array<BlendEffect> = [];
	override function createPost()
	{
		game.dad.setPosition(2250, 450);
		game.boyfriend.setPosition(2885, 1450);
		game.gf.visible = false;

		game.camBars.fade(FlxColor.BLACK, 0.0001);
		camHUD.alpha = 0;

		//FOREGROUND ELEMENTS

		chainsBehindLight = new FlxSprite(-50, -150).loadGraphic(Paths.image(PlayState.pathway + 'FOREGROUND/ChainsBehindLight'));
		chainsBehindLight.antialiasing = ClientPrefs.data.antialiasing;
		chainsBehindLight.shader = dropShadowArray[1];
		dropShadowArray[1].attachedSprite = chainsBehindLight;
		chainsBehindLight.scrollFactor.set(0.8, 0.8);
		add(chainsBehindLight);

		wires = new FlxSprite(942, -100).loadGraphic(Paths.image(PlayState.pathway + 'FOREGROUND/WeirdHangingWires'));
		wires.antialiasing = ClientPrefs.data.antialiasing;
		wires.shader = dropShadowArray[2];
		dropShadowArray[2].attachedSprite = wires;
		wires.scrollFactor.set(0.9, 0.9);
		add(wires);

		lights = new FlxSprite(125, 0).loadGraphic(Paths.image(PlayState.pathway + 'FOREGROUND/HangingLights'));
		lights.antialiasing = ClientPrefs.data.antialiasing;
		add(lights);

		chainsFrontofLight = new FlxSprite(0, 0).loadGraphic(Paths.image(PlayState.pathway + 'FOREGROUND/ChainsFrontofLight'));
		chainsFrontofLight.antialiasing = ClientPrefs.data.antialiasing;
		chainsFrontofLight.shader = dropShadowArray[3];
		dropShadowArray[3].attachedSprite = chainsFrontofLight;
		chainsFrontofLight.scrollFactor.set(1.1, 1.1);
		add(chainsFrontofLight);

		//OVERLAY

		var colorDodgeBlend = new BlendEffect();
		colorDodgeBlend.blendMode = 6;
		lightsOverlay = new FlxSprite(0, 0).loadGraphic(Paths.image(PlayState.pathway + 'OVERLAYS/Lights'));
		lightsOverlay.shader = colorDodgeBlend.shader;
		lightsOverlay.alpha = 0.36;
		lightsOverlay.color = 0xffffd9a0;
		add(lightsOverlay);
	
		game.boyfriend.shader = dropShadowArray[4];
		dropShadowArray[4].attachedSprite = game.boyfriend;
		game.boyfriend.animation.onFrameChange.add(function(name, frameNum, frameIndex) {
			dropShadowArray[4].updateFrameInfo(game.boyfriend.frame);
		});

		game.dad.shader = dropShadowArray[5];
		dropShadowArray[5].attachedSprite = game.dad;
		game.dad.animation.onFrameChange.add(function(name, frameNum, frameIndex) {
			dropShadowArray[5].updateFrameInfo(game.dad.frame);
		});
		game.dad.blend = BlendMode.ADD;

		theDoor = new FlxSprite(0, 0).loadGraphic(Paths.image(PlayState.pathway + 'theDoor'));
		theDoor.antialiasing = ClientPrefs.data.antialiasing;
		theDoor.screenCenter();
		theDoor.scale.set(0.25, 0.25);
		theDoor.cameras = [game.camBars];
		add(theDoor);

		if (ClientPrefs.data.shaders)
		{
			camGame.setFilters(
				[
					new ShaderFilter(othershader)
				]
			);
			new flixel.util.FlxTimer().start(1, function(tmr)
				{
					camGame.setFilters([/*that's right, nothing*/]);
				});
		}
	}

	override function update(elapsed:Float)
	{
		shaderAnim = Conductor.songPosition / 1000;
		
		if (ClientPrefs.data.shaders)
			othershader.setFloat('iTime', shaderAnim);

		boyfriend.x = 2885;
	}

	// For events
	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case 'Bless Events':
				switch (flValue1)
				{
					case 0:
						FlxTween.tween(theDoor, {alpha: 0}, 2, {ease: FlxEase.circInOut});
						FlxTween.tween(theDoor.scale, {x: 0.5, y: 0.5}, 2, {ease: FlxEase.circInOut});
					case 1:
						FlxTween.tween(dad, {x: 1050}, 7.5, {ease: FlxEase.sineInOut});
					case 2:
						FlxTween.tween(vaultDoor, {alpha: 0.0001}, 1, {ease: FlxEase.circInOut});
					case 3:
						for (stuff in [vault, vaultDoor, chainsBehindLight, wires, lights, chainsFrontofLight])
						{
							stuff.visible = false;
						}
					case 4:
						for (stuff in [vault, vaultDoor, chainsBehindLight, wires, lights, chainsFrontofLight])
						{
							stuff.visible = true;
						}
						game.boyfriend.setPosition(2885, 1450);
					case 5:
						if (ClientPrefs.data.shaders)
						{
							// We make ur Laptop fry till the end of the song :fire: - MalyPlus
							camGame.setFilters([new ShaderFilter(othershader)]);
						}

				}
			case 'Invert Shit':
				var triggerInfo:Array<String> = value2.split(',');
				if (value1.toLowerCase().trim() == "true")
				{
					AppIcon.changeIcon("blessIcon");
					CppAPI.lightMode();

					dad.shader = null;
					boyfriend.shader = null;

					for (blessableObjects in [dad, boyfriend])
						FlxTween.tween(blessableObjects.colorTransform, {
							redOffset: 255,
							blueOffset: 255,
							greenOffset: 255,
							redMultiplier: -1,
							blueMultiplier: -1,
							greenMultiplier: -1
						}, Std.parseFloat(triggerInfo[0]), {ease: returnTweenEase(triggerInfo[1])
					});
				}
				else
				{
					game.boyfriend.shader = dropShadowArray[4];
					dropShadowArray[4].attachedSprite = game.boyfriend;
					game.boyfriend.animation.onFrameChange.add(function(name, frameNum, frameIndex) {
						dropShadowArray[4].updateFrameInfo(game.boyfriend.frame);
					});

					game.dad.shader = dropShadowArray[5];
					dropShadowArray[5].attachedSprite = game.dad;
					game.dad.animation.onFrameChange.add(function(name, frameNum, frameIndex) {
						dropShadowArray[5].updateFrameInfo(game.dad.frame);
					});

					for (blessableObjects in [dad, boyfriend])
						FlxTween.tween(blessableObjects.colorTransform, {
							redOffset: 0,
							blueOffset: 0,
							greenOffset: 0,
							redMultiplier: 1,
							blueMultiplier: 1,
							greenMultiplier: 1
						}, Std.parseFloat(triggerInfo[0]), {
							ease: returnTweenEase(triggerInfo[1])
						}
					);

					
					AppIcon.changeIcon("newIcon");
					CppAPI.darkMode();
				}
		}
	}

	public static function returnTweenEase(ease:String = '')
	{
		switch (ease.toLowerCase())
		{
			case 'linear':
				return FlxEase.linear;
			case 'backin':
				return FlxEase.backIn;
			case 'backinout':
				return FlxEase.backInOut;
			case 'backout':
				return FlxEase.backOut;
			case 'bouncein':
				return FlxEase.bounceIn;
			case 'bounceinout':
				return FlxEase.bounceInOut;
			case 'bounceout':
				return FlxEase.bounceOut;
			case 'circin':
				return FlxEase.circIn;
			case 'circinout':
				return FlxEase.circInOut;
			case 'circout':
				return FlxEase.circOut;
			case 'cubein':
				return FlxEase.cubeIn;
			case 'cubeinout':
				return FlxEase.cubeInOut;
			case 'cubeout':
				return FlxEase.cubeOut;
			case 'elasticin':
				return FlxEase.elasticIn;
			case 'elasticinout':
				return FlxEase.elasticInOut;
			case 'elasticout':
				return FlxEase.elasticOut;
			case 'expoin':
				return FlxEase.expoIn;
			case 'expoinout':
				return FlxEase.expoInOut;
			case 'expoout':
				return FlxEase.expoOut;
			case 'quadin':
				return FlxEase.quadIn;
			case 'quadinout':
				return FlxEase.quadInOut;
			case 'quadout':
				return FlxEase.quadOut;
			case 'quartin':
				return FlxEase.quartIn;
			case 'quartinout':
				return FlxEase.quartInOut;
			case 'quartout':
				return FlxEase.quartOut;
			case 'quintin':
				return FlxEase.quintIn;
			case 'quintinout':
				return FlxEase.quintInOut;
			case 'quintout':
				return FlxEase.quintOut;
			case 'sinein':
				return FlxEase.sineIn;
			case 'sineinout':
				return FlxEase.sineInOut;
			case 'sineout':
				return FlxEase.sineOut;
			case 'smoothstepin':
				return FlxEase.smoothStepIn;
			case 'smoothstepinout':
				return FlxEase.smoothStepInOut;
			case 'smoothstepout':
				return FlxEase.smoothStepInOut;
			case 'smootherstepin':
				return FlxEase.smootherStepIn;
			case 'smootherstepinout':
				return FlxEase.smootherStepInOut;
			case 'smootherstepout':
				return FlxEase.smootherStepOut;
		}
		return FlxEase.linear;
	}
}