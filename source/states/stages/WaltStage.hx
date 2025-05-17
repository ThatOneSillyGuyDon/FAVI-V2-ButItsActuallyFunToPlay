package states.stages;

import states.stages.objects.*;

#if !flash 
import openfl.filters.ShaderFilter;
#end

class WaltStage extends BaseStage
{
	public var waltScreenThing:FlxSprite; // idk, this is needed too for some reason
	public var inkFormWarning:FlxText;
	public var spaceBarCounter:FlxText;
	public var mercyBoostIcon:FlxSprite;
	public var limitThing:Int = 0; // Default Value

	public var shaderAnim:Float = 0;

	public static var waltStatic:FlxRuntimeShader = new FlxRuntimeShader(Shaders.vhsFilter, null, 130);
	public static var dramaticCamMovement:FlxRuntimeShader = new FlxRuntimeShader(Shaders.cameraMovement, null, 150);

	//MERCY
	var pissOfGlory:FlxSprite;
	var greaterPiss:FlxSprite;

	var retardedButPissBehind:FlxSprite;
	var sameAsAdobe:FlxSprite;
	var waltGoop:FlxSprite;

	var mercyTmr:FlxTimer;
	var disabledDrain:Bool = false;
	var initialCount:Int = 0;

	override function create()
	{
		//game.health = 0.5;

		game.defaultCamZoom = 0.75;
	
		if (PlayState.SONG.song == 'Mercy')
		{
			camGame.alpha = 0;
			camHUD.alpha = 0;
			//dadStrums.visible = false;

			pissOfGlory = new FlxSprite(-470, -280);
			pissOfGlory.loadGraphic(Paths.image(PlayState.pathway + 'newWaltBG'));
			pissOfGlory.scale.set(1.7, 1.7);
		}else{
			pissOfGlory = new FlxSprite(-450, -300);
			pissOfGlory.loadGraphic(Paths.image(PlayState.pathway + 'walt-bg'));
			pissOfGlory.scale.set(1, 1);
		}
		pissOfGlory.updateHitbox();
		pissOfGlory.antialiasing = true;
		pissOfGlory.scrollFactor.set(1, 1);
		pissOfGlory.active = false;
		pissOfGlory.blend = ADD;
		//add(pissOfGlory);

		retardedButPissBehind = new FlxSprite().loadGraphicFromSprite(pissOfGlory);
		add(retardedButPissBehind);
		if (PlayState.SONG.song == 'Mercy')
		{
			retardedButPissBehind.scale.set(1.7, 1.7);
			retardedButPissBehind.updateHitbox();
			retardedButPissBehind.setPosition(pissOfGlory.x, pissOfGlory.y);
		}
		else
		{
			retardedButPissBehind.updateHitbox();
			retardedButPissBehind.setPosition(pissOfGlory.x, pissOfGlory.y);
		}

		greaterPiss = new FlxSprite(-60, -70);
		greaterPiss.loadGraphic(Paths.image(PlayState.pathway + 'inkWaltBG'));
		greaterPiss.scale.set(1.7, 1.7);
		greaterPiss.blend = ADD;
		greaterPiss.visible = false;

		sameAsAdobe = new FlxSprite().loadGraphicFromSprite(greaterPiss);
		sameAsAdobe.visible = false;
		sameAsAdobe.setPosition(greaterPiss.x, greaterPiss.y);
		sameAsAdobe.scale.set(1.7, 1.7);
		add(sameAsAdobe);

		waltGoop = new FlxSprite(-800, 410).loadGraphic(Paths.image(PlayState.pathway + 'melted'));
		waltGoop.scale.set(0.3, 0.3);
		//waltGoop.screenCenter();
		waltGoop.alpha = 0.001;

		if(!ClientPrefs.data.lowQuality)
		{
			var vignette:FlxSprite = new FlxSprite(-250, -140).loadGraphic(Paths.image(PlayState.pathway + 'vignetteOverlay'));
			vignette.cameras = [camOther];
			vignette.scale.set(0.75, 0.75);
			vignette.antialiasing = true;
			vignette.scrollFactor.set();
			vignette.active = false;
			add(vignette);
		}
	}
	
	override function createPost()
	{
		add(pissOfGlory);
		add(greaterPiss);

		game.boyfriend.visible = false;
		game.gf.visible = false;
		add(waltGoop);

		var waltInstructionsMain:FlxText = new FlxText(370, 500, 0, "Take Advantage of the SPACEBAR!", 30);
		waltInstructionsMain.cameras = [camOther];
		waltInstructionsMain.setFormat(Paths.font("splatter.otf"), 30);
		waltInstructionsMain.alpha = 0;
		waltInstructionsMain.scrollFactor.set();

		var waltSubTxt:FlxText = new FlxText(waltInstructionsMain.x + 66, waltInstructionsMain.y + 40, 0,
			"(It will help you regain health when critically low)", 15);
		waltSubTxt.setFormat(Paths.font("splatter.otf"), 15);
		waltSubTxt.cameras = [camOther];
		waltSubTxt.alpha = 0;
		waltSubTxt.scrollFactor.set();

		inkFormWarning = new FlxText(0, 0, 0, "PRESS SPACE!", 15);
		inkFormWarning.setFormat(Paths.font("splatter.otf"), 50);
		inkFormWarning.cameras = [camOther];
		inkFormWarning.alpha = 0;
		inkFormWarning.scrollFactor.set();
		inkFormWarning.screenCenter();

		mercyBoostIcon = new FlxSprite(-10, 600);
		mercyBoostIcon.frames = Paths.getSparrowAtlas("favi/ui/mercyIcon");
		mercyBoostIcon.animation.addByPrefix("full", "full", 7, true);
		mercyBoostIcon.animation.addByPrefix("hmm", "hmm", 7, true);
		mercyBoostIcon.animation.addByPrefix("halfway", "halfway", 7, true);
		mercyBoostIcon.animation.addByPrefix("thatsBad", "thatsBad", 7, true);
		mercyBoostIcon.animation.addByPrefix("almostOut", "almostOut", 7, true);
		mercyBoostIcon.animation.addByPrefix("empty", "empty", 7, true);
		mercyBoostIcon.cameras = [camOther];
		mercyBoostIcon.animation.play("full");
		mercyBoostIcon.scale.set(0.75, 0.75);
		mercyBoostIcon.scrollFactor.set();			

		spaceBarCounter = new FlxText(0, 650, 140, '', 15);
		spaceBarCounter.setFormat(Paths.font("splatter.otf"), 30, FlxColor.BLACK, CENTER, OUTLINE, FlxColor.WHITE);
		spaceBarCounter.cameras = [camOther];
		//spaceBarCounter.alpha = 0;
		spaceBarCounter.scrollFactor.set();

		if (ClientPrefs.data.mechanics)
		{
			add(waltInstructionsMain);
			add(waltSubTxt);
			add(mercyBoostIcon);
			add(spaceBarCounter);

			FlxTween.tween(waltInstructionsMain, {alpha: 1}, 1, {ease: FlxEase.quadInOut, startDelay: 1});
			FlxTween.tween(waltInstructionsMain, {alpha: 0}, 1, {ease: FlxEase.quadInOut, startDelay: 8});
			FlxTween.tween(waltSubTxt, {alpha: 1}, 0.7, {ease: FlxEase.quadInOut, startDelay: 3});
			FlxTween.tween(waltSubTxt, {alpha: 0}, 1, {ease: FlxEase.quadInOut, startDelay: 8});
		}

		waltScreenThing = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		waltScreenThing.scrollFactor.set();
		waltScreenThing.cameras = [camOther];
		waltScreenThing.alpha = 0.001;
		add(waltScreenThing);

		if (ClientPrefs.data.shaders)
		{
			if (!ClientPrefs.data.lowQuality)
			{
				camGame.setFilters([
					new ShaderFilter(waltStatic),
					new ShaderFilter(dramaticCamMovement)
				]);
			}
			else
			{
				camGame.setFilters([new ShaderFilter(dramaticCamMovement)]);
			}
			camHUD.setFilters([new ShaderFilter(dramaticCamMovement)]);
		}

		switch(PlayState.SONG.song)
		{
			case 'Mercy Legacy':
				if (ClientPrefs.data.mechanics)
				{
					limitThing += 25;
					initialCount = limitThing;
				}

			case 'Mercy':
				if (ClientPrefs.data.mechanics)
				{
					limitThing += 20;
					initialCount = limitThing;
				}
		}


		switch (game.dad.curCharacter)
		{
			case 'walt-new':
				game.dad.setPosition(220, -50);
			default:
				game.dad.setPosition(0, 0);
		}
		game.boyfriend.setPosition(330, 300);
	}

	override function update(elapsed:Float)
	{
		shaderAnim = Conductor.songPosition / 1000;
		
		waltStatic.setFloat('time', shaderAnim);
		dramaticCamMovement.setFloat('time', shaderAnim);

		pissOfGlory.alpha = FlxMath.lerp(pissOfGlory.alpha, FlxG.random.float(0.01, .37), .2);
		greaterPiss.alpha = FlxMath.lerp(greaterPiss.alpha, FlxG.random.float(0.01, .37), .2);

		if (ClientPrefs.data.mechanics)
		{
			spaceBarCounter.text = '${limitThing}';
		
			/*
			* This set monitors the brightness of the screen based on the percentage of your health
			* The original code was unoptimized asf, you can go see for yourself through the commit
			* history, thx @Wither362 for the more simplified code!
			*
			* -DEMOLITIONDON96
			*/

			var healths:Array<Float> = [for (i in 1...21) i / 10]; // i dont really remember how were this done...
			var alphas:Array<Float> = [
				0.95, 0.90, 0.85, 0.80, 0.75, 0.70, 0.65, 0.60, 0.55, 0.50, 0.45, 0.40, 0.35, 0.30, 0.25, 0.20, 0.15, 0.10, 0.05, 0.0
			];
			var lastOne:Bool = true;
			for (i in 0...healths.length)
			{
				if (lastOne)
				{
					lastOne = tweenWaltScreen(healths[i], alphas[i]);
				}
			}
		}

		game.iconP1.y = game.healthBar.y + (game.healthBar.width * (FlxMath.remapToRange(game.healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * game.iconP1.scale.y - 150) / 2 - game.iconOffset * 11.85;
		game.iconP2.y = game.healthBar.y + (game.healthBar.width * (FlxMath.remapToRange(game.healthBar.percent, 0, 100, 100, 0) * 0.01)) - (150 * game.iconP2.scale.y) / 2 - game.iconOffset * 13.85;

		if (!game.cpuControlled)
		{
			if (FlxG.keys.justPressed.SPACE)
			{
				switch (PlayState.curStage)
				{
					case 'waltRoom':
						if (limitThing > 0)
						{
							if (mercyTmr != null)
								mercyTmr.cancel();

							disabledDrain = true;
							mercyTmr = new FlxTimer().start(1.2, function(tmr:FlxTimer)
							{
								disabledDrain = false;
								mercyTmr = null;
							});
							game.health += 1.25;
							limitThing -= 1;
							var mathShit:Float = limitThing / initialCount;
							switch (mathShit)
							{
								case 0.75: mercyBoostIcon.animation.play("hmm");
								case 0.5: mercyBoostIcon.animation.play("halfway");
								case 0.25: mercyBoostIcon.animation.play("thatsBad");
								case 0.1 | 0.12: mercyBoostIcon.animation.play("almostOut");
								case 0: mercyBoostIcon.animation.play("empty");
							}
						}
					
					default:
						// nothing
				}
			}
		} else {
			switch (PlayState.SONG.song)
			{
				default:
					//nothing
			}
			
			switch (PlayState.curStage)
			{
				case 'waltRoom':
					if (game.health < 0.3 && limitThing > 0)
					{
						if (mercyTmr != null)
							mercyTmr.cancel();

						disabledDrain = true;
						mercyTmr = new FlxTimer().start(1.2, function(tmr:FlxTimer)
						{
							disabledDrain = false;
							mercyTmr = null;
						});
						game.health += 1.25;
						limitThing -= 1;
						var mathShit:Float = limitThing / initialCount;
						switch (mathShit)
						{
							case 0.75: mercyBoostIcon.animation.play("hmm");
							case 0.5: mercyBoostIcon.animation.play("halfway");
							case 0.25: mercyBoostIcon.animation.play("thatsBad");
							case 0.1 | 0.12: mercyBoostIcon.animation.play("almostOut");
							case 0: mercyBoostIcon.animation.play("empty");
						}
					}
					
				default:
					// nothing
			}
		}
	}

	
	override function beatHit()
	{
		// Cam Stuff Handler
		switch (curBeat)
		{
			case 16:
				FlxTween.tween(camGame, {alpha: 1}, 5, {ease: FlxEase.sineInOut});
				FlxTween.tween(camHUD, {alpha: 1}, 5, {ease: FlxEase.sineInOut, startDelay: 1.5});
				game.defaultCamZoom = 1.3;

			case 32: game.defaultCamZoom = 1.2;
			case 40: game.defaultCamZoom = 1.1;
			case 48: game.defaultCamZoom = 1;
			case 56: game.defaultCamZoom = 0.9;
			case 64: game.defaultCamZoom = 0.75;

			case 128: game.tweenCamera(1.1, 9.7, 'quadInOut');

			// Very Spooky Phase 2 Walt (real)
			case 256:
				FlxTween.tween(camHUD, {alpha: 0}, 1, {ease: FlxEase.sineInOut});

			case 468:
				//FlxTween.tween(bfStrums, {alpha: 0}, 4, {ease: FlxEase.sineInOut});
				FlxTween.tween(camHUD, {alpha: 0}, 4, {ease: FlxEase.sineInOut});
				game.dad.setPosition(0, 0);

			case 480:
				FlxTween.tween(game.dad, {alpha: 0}, 5);
				FlxTween.tween(waltGoop, {alpha: 1}, 5);

			// Final Stretch
			case 498:
				camGame.alpha = 0;
				camOther.flash(FlxColor.WHITE, 3);
		}

		if (ClientPrefs.data.mechanics && !disabledDrain)
		{
			// Health Drain Shit
			if (curBeat >= 0 && curBeat <= 63)
				game.health -= 0.005;
			else if (curBeat >= 64 && curBeat <= 79)
				game.health -= 0.025;
			else if (curBeat >= 80 && curBeat <= 87)
				game.health -= 0.055;
			else if (curBeat >= 88 && curBeat <= 95)
				game.health -= 0.015;
			else if (curBeat >= 96 && curBeat <= 127)
				game.health -= 0.036;
			else if (curBeat >= 128 && curBeat <= 159)
				game.health -= 0.14;
			else if (curBeat >= 160 && curBeat <= 191)
				game.health -= 0.031;
			else if (curBeat >= 192 && curBeat <= 207)
				game.health -= 0.015;
			else if (curBeat >= 208 && curBeat <= 239)
				game.health -= 0.03;
			else if (curBeat >= 240 && curBeat <= 255)
				game.health -= 0.005;
			else if (curBeat >= 256 && curBeat <= 291)
				game.health -= 0.02;
			else if (curBeat >= 292 && curBeat <= 307)
				game.health -= 0.03;
			else if (curBeat >= 308 && curBeat <= 339)
				game.health -= 0.04;
			else if (curBeat >= 340 && curBeat <= 371)
				game.health -= 0.055;
			else if (curBeat >= 372 && curBeat <= 387)
				game.health -= 0.078;
			else if (curBeat >= 388 && curBeat <= 403)
				game.health -= 0.09;
			else if (curBeat >= 404 && curBeat <= 451)
				game.health -= 0.1;
			else if (curBeat >= 452 && curBeat <= 467)
				game.health -= 0.115;
		}
	}
	/**
	* The better and simplified Walt gimmick
	*
	* @author Wither362
	*/
	public function tweenWaltScreen(percentage:Float, alpha:Float):Bool {
		if (game.health <= percentage)
			FlxTween.tween(waltScreenThing, {alpha: alpha}, 0.15, {ease: FlxEase.sineInOut});
		else
			return true;
		return false;
	}

	// For events
	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case "Mercy Transition":
				switch (value1.toLowerCase())
				{
					case "start":
						game.defaultCamZoom = 0.75;
						retardedButPissBehind.visible = false;
						sameAsAdobe.visible = false;
						pissOfGlory.visible = false;
						game.dad.setPosition(0, 0);
						greaterPiss.visible = false;
						game.camFlashSystem(CAM_FLASH_FANCY, {alpha: 0.5, ease: FlxEase.sineOut, timer: 0.2, colors: [247, 230, 166]});

					case "finish":
						for (bullshit in [retardedButPissBehind, sameAsAdobe, pissOfGlory, greaterPiss])
							bullshit.visible = true;
						game.camFlashSystem(CAM_FLASH_FANCY, {alpha: 0.5, ease: FlxEase.sineOut, timer: 0.2, colors: [247, 230, 166]});
						game.dad.setPosition(240, -200);
						FlxTween.tween(sameAsAdobe, {alpha: 0}, 0.25, {ease: FlxEase.sineOut});
						FlxTween.tween(camHUD, {alpha: 1}, 0.31, {ease: FlxEase.sineInOut});
				}
		}
	}
}