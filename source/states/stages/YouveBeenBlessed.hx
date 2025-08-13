package states.stages;

import states.stages.objects.*;

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

	// SHADER FOR BLESS ONLY CUZ IM DUMBASS - MalyPlus
	var othershader:FlxRuntimeShader = new FlxRuntimeShader(Shaders.blessLightsShit);
	public var shaderAnim:Float = 0;

	override function create()
	{
		vault = new FlxSprite(0, 0).loadGraphic(Paths.image(PlayState.pathway + 'BACKGROUND/MainBG'));
		vault.antialiasing = ClientPrefs.data.antialiasing;
		add(vault);

		var vaultShader = new DropShadowShader();
		vaultShader.setAdjustColor(-40, -23, -9, -20);
		vaultShader.angle = 90;
		vaultShader.distance = 45;
		vaultShader.color = 0xff593021;
		vaultShader.threshold = 0.2;
		vaultDoor = new FlxSprite(1750, 340).loadGraphic(Paths.image(PlayState.pathway + 'BACKGROUND/vaultDoor'));
		vaultDoor.antialiasing = ClientPrefs.data.antialiasing;
		vaultDoor.shader = vaultShader;
		vaultShader.attachedSprite = vaultDoor;
		add(vaultDoor);
	}
	
	override function createPost()
	{
		game.dad.setPosition(2250, 450);
		game.boyfriend.setPosition(2885, 1450);
		game.gf.visible = false;

		game.camBars.fade(FlxColor.BLACK, 0.0001);
		camHUD.alpha = 0.001;

		//FOREGROUND ELEMENTS
		
		chainsBehindLight = new FlxSprite(0, 0).loadGraphic(Paths.image(PlayState.pathway + 'FOREGROUND/ChainsBehindLight'));
		chainsBehindLight.antialiasing = ClientPrefs.data.antialiasing;
		add(chainsBehindLight);

		wires = new FlxSprite(942, 0).loadGraphic(Paths.image(PlayState.pathway + 'FOREGROUND/WeirdHangingWires'));
		wires.antialiasing = ClientPrefs.data.antialiasing;
		add(wires);

		lights = new FlxSprite(125, 0).loadGraphic(Paths.image(PlayState.pathway + 'FOREGROUND/HangingLights'));
		lights.antialiasing = ClientPrefs.data.antialiasing;
		add(lights);

		chainsFrontofLight = new FlxSprite(0, 0).loadGraphic(Paths.image(PlayState.pathway + 'FOREGROUND/ChainsFrontofLight'));
		chainsFrontofLight.antialiasing = ClientPrefs.data.antialiasing;
		add(chainsFrontofLight);

		//OVERLAYS

		var colorDodgeBlend = new BlendEffect();
		colorDodgeBlend.blendMode = 6;
		lightsOverlay = new FlxSprite(0, 0).loadGraphic(Paths.image(PlayState.pathway + 'OVERLAYS/Lights'));
		lightsOverlay.shader = colorDodgeBlend.shader;
		lightsOverlay.alpha = 0.36;
		lightsOverlay.color = 0xffffd9a0;
		add(lightsOverlay);

		//CHARACTER SHADER
		
		var dropShader = new DropShadowShader();
		dropShader.setAdjustColor(-40, -23, -3, -20);
		dropShader.angle = 90;
		dropShader.distance = 17;
		dropShader.color = 0xfffbbc82;
		dropShader.threshold = 0.15;
		dropShader.antialiasAmt = 4;
		game.boyfriend.shader = dropShader;
		dropShader.attachedSprite = game.boyfriend;
		game.boyfriend.animation.onFrameChange.add(function(name, frameNum, frameIndex) {
			dropShader.updateFrameInfo(game.boyfriend.frame);
		});


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
	}

	// For events
	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case 'Bless Events':
				switch (flValue1)
				{
					case 1:
						FlxTween.tween(dad, {x: 1050}, 7.5, {ease: FlxEase.sineInOut});

				}
			
			/* Gonna Revamp This Later
			case 'Bless Events':
				switch (flValue1)
				{
					case 1:
						FlxTween.tween(light, {alpha: .37}, 2, {ease: FlxEase.circOut});
						FlxTween.tween(flair, {alpha: .6}, 2, {ease: FlxEase.circOut});
					case 2:
						FlxTween.tween(light, {alpha: 0}, .3, {ease: FlxEase.circOut});
						FlxTween.tween(flair, {alpha: 0}, .3, {ease: FlxEase.circOut});
					case 3:
						FlxTween.tween(light, {alpha: .37}, .2, {ease: FlxEase.circOut});
						FlxTween.tween(flair, {alpha: .6}, .2, {ease: FlxEase.circOut});
					case 4:
						AppIcon.changeIcon("blessIcon");
						CppAPI.lightMode();
						for (blessableObjects in [game.dad, game.boyfriend, vault, chains, thingy, chains, chains2, chains3, game.iconP1, game.iconP2, game.healthBar, game.healthBarBG, game.fancyBarOverlay])
							blessableObjects.setColorTransform(-1, -1, -1, 1, 255, 255, 255, 0);
						for (textShit in [game.songTxt, game.watermarkTxt, game.scoreTxt])
						{
							textShit.color = FlxColor.BLACK;
							textShit.borderColor = FlxColor.WHITE;
						}
						light.visible = false;
						flair.visible = false;
						lightI.visible = true;
						flairI.visible = true;
						game.playfieldRenderer.isInvertColors = true;
					case 5:
						light.visible = true;
						flair.visible = true;
						lightI.visible = false;
						flairI.visible = false;
						game.playfieldRenderer.isInvertColors = false;
						FlxTween.tween(camHUD, {alpha: 1}, 3);
						for (blessableObjects in [game.dad, game.boyfriend, vault, chains, thingy, chains, chains2, chains3, game.iconP1, game.iconP2, game.healthBar, game.healthBarBG, game.fancyBarOverlay])
							blessableObjects.setColorTransform(1, 1, 1, 1, 0, 0, 0, 0);
						for (textShit in [game.songTxt, game.watermarkTxt, game.scoreTxt])
						{
							textShit.color = FlxColor.WHITE;
							textShit.borderColor = FlxColor.BLACK;
						}
						AppIcon.changeIcon("newIcon");
						CppAPI.darkMode();
					case 6:
						AppIcon.changeIcon("blessIcon");
						CppAPI.lightMode();
						for (blessableObjects in [game.dad, game.boyfriend, vault, chains, thingy, chains, chains2, chains3, game.iconP1, game.iconP2, game.healthBar, game.healthBarBG, game.fancyBarOverlay])
							blessableObjects.setColorTransform(-1, -1, -1, 1, 255, 255, 255, 0);
						for (textShit in [game.songTxt, game.watermarkTxt, game.scoreTxt])
						{
							textShit.color = FlxColor.BLACK;
							textShit.borderColor = FlxColor.WHITE;
						}
						light.visible = false;
						flair.visible = false;
						lightI.visible = true;
						flairI.visible = true;
						game.playfieldRenderer.isInvertColors = true;
					case 7:
						AppIcon.changeIcon("newIcon");
						CppAPI.darkMode();
						for (blessableObjects in [game.dad, game.boyfriend, vault, chains, thingy, chains, chains2, chains3, game.iconP1, game.iconP2, game.healthBar, game.healthBarBG, game.fancyBarOverlay])
							FlxTween.tween(blessableObjects.colorTransform, {
								redOffset: 0,
								blueOffset: 0,
								greenOffset: 0,
								redMultiplier: 1,
								blueMultiplier: 1,
								greenMultiplier: 1
							}, 2, {ease: FlxEase.quartOut});
						for (textShit in [game.songTxt, game.watermarkTxt, game.scoreTxt])
						{
							textShit.color = FlxColor.WHITE;
							textShit.borderColor = FlxColor.BLACK;
							textShit.alpha = 0;
							FlxTween.tween(textShit, {alpha: 1}, 2, {ease: FlxEase.quartOut});
						}
					case 8:
						if (ClientPrefs.data.shaders)
						{
							// We make ur Laptop fry till the end of the song :fire: - MalyPlus
							camGame.setFilters([new ShaderFilter(othershader)]);
						}
					case 9:
						lightI.visible = false;
						thingy.visible = false;
						flairI.visible = false;
						game.playfieldRenderer.isInvertColors = false;
						if (ClientPrefs.data.shaders)
						{
							camGame.setFilters([]);
						}
				}
			*/
		}
	}
}