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

	var moodyLighting:FlxSprite;
	var lightsOverlay:FlxSprite;
	var darkness:FlxSprite;
	var overlayBehindBF:FlxSprite;
	var randomColorBullshitIDK:FlxSprite;

	// SHADER FOR BLESS ONLY CUZ IM DUMBASS - MalyPlus
	var othershader:FlxRuntimeShader = new FlxRuntimeShader(Shaders.blessLightsShit);
	public var shaderAnim:Float = 0;

	override function create()
	{
		vault = new FlxSprite(0, 0).loadGraphic(Paths.image(PlayState.pathway + 'BACKGROUND/MainBG'));
		vault.antialiasing = ClientPrefs.data.antialiasing;
		add(vault);

		vaultDoor = new FlxSprite(1750, 340).loadGraphic(Paths.image(PlayState.pathway + 'BACKGROUND/vaultDoor'));
		vaultDoor.antialiasing = ClientPrefs.data.antialiasing;
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

		moodyLighting = new FlxSprite(0, 0).loadGraphic(Paths.image(PlayState.pathway + 'OVERLAYS/MoodyLighting'));
		moodyLighting.blend = "overlay";
		moodyLighting.alpha = 0.37;
		add(moodyLighting);

		overlayBehindBF = new FlxSprite(0, 0).loadGraphic(Paths.image(PlayState.pathway + 'OVERLAYS/DarknessBehindEverett'));
		overlayBehindBF.blend = "darken";
		overlayBehindBF.alpha = 0.57;
		add(overlayBehindBF);

		lightsOverlay = new FlxSprite(0, 0).loadGraphic(Paths.image(PlayState.pathway + 'OVERLAYS/Lights'));
		lightsOverlay.blend = "add";
		lightsOverlay.alpha = 0.51;
		add(lightsOverlay);

		darkness = new FlxSprite(0, 0).loadGraphic(Paths.image(PlayState.pathway + 'OVERLAYS/Darkness'));
		darkness.blend = "overlay";
		darkness.alpha = 0.77;
		add(darkness);

		randomColorBullshitIDK = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(255, 192, 92), false);
		randomColorBullshitIDK.blend = "overlay";
		randomColorBullshitIDK.alpha = 0.22;
		randomColorBullshitIDK.scrollFactor.set(0, 0);
		randomColorBullshitIDK.cameras = [camHUD];
		add(randomColorBullshitIDK);
		
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