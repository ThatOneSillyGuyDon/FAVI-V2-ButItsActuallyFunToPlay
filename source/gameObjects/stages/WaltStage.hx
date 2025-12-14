package gameObjects.stages;

#if !flash 
import openfl.filters.ShaderFilter;
#end

class HealthBoostIcon extends FlxSprite
{
	public function new(x:Float, y:Float)
	{
		super(x, y);
		
		frames = Paths.getSparrowAtlas("favi/ui/mercyIcon");
		animation.addByPrefix("phase1-idle", "phase1", 24, true);
		animation.addByPrefix("phase2-transition", "phase20", 24, false);
		animation.addByPrefix("phase2-idle", "phase2-loop", 24, true);
		animation.addByPrefix("phase3-transition", "phase30", 24, false);
		animation.addByPrefix("phase3-idle", "phase3-loop", 24, true);
		animation.addByPrefix("phase4-transition", "phase40", 24, false);
		animation.addByPrefix("phase4-idle", "phase4-loop", 24, true);
		animation.play("phase1-idle");
		scrollFactor.set();	
	}
	
	override function update(elapsed:Float) 
	{
		if(animation.curAnim != null && animation.curAnim.name == 'phase2-transition') {
			if(animation.curAnim.finished) 
				animation.play('phase2-idle', true);
		}

		if(animation.curAnim != null && animation.curAnim.name == 'phase3-transition') {
			if(animation.curAnim.finished) 
				animation.play('phase3-idle', true);
		}

		if(animation.curAnim != null && animation.curAnim.name == 'phase4-transition') {
			if(animation.curAnim.finished) 
				animation.play('phase4-idle', true);
		}
		
		super.update(elapsed);
	}
}

class WaltStage extends BaseStage
{
	public var waltScreenThing:FlxSprite; // idk, this is needed too for some reason
	public var inkFormWarning:FlxText;
	public var spaceBarCounter:FlxText;
	public var mercyBoostIcon:HealthBoostIcon;
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
		waltInstructionsMain.cameras = [game.fakeCam];
		waltInstructionsMain.setFormat(Paths.font("splatter.otf"), 30);
		waltInstructionsMain.alpha = 0;
		waltInstructionsMain.scrollFactor.set();

		var waltSubTxt:FlxText = new FlxText(waltInstructionsMain.x + 66, waltInstructionsMain.y + 40, 0,
			"(It will help you regain health when critically low)", 15);
		waltSubTxt.setFormat(Paths.font("splatter.otf"), 15);
		waltSubTxt.cameras = [game.fakeCam];
		waltSubTxt.alpha = 0;
		waltSubTxt.scrollFactor.set();

		inkFormWarning = new FlxText(0, 0, 0, "PRESS SPACE!", 15);
		inkFormWarning.setFormat(Paths.font("splatter.otf"), 50);
		inkFormWarning.cameras = [game.fakeCam];
		inkFormWarning.alpha = 0;
		inkFormWarning.scrollFactor.set();
		inkFormWarning.screenCenter();

		mercyBoostIcon = new HealthBoostIcon(-10, 600);
		mercyBoostIcon.cameras = [game.fakeCam];
		mercyBoostIcon.alpha = 0;

		spaceBarCounter = new FlxText(0, 640, 140, '', 15);
		spaceBarCounter.setFormat(Paths.font("Black-Ground.otf"), 50, FlxColor.BLACK, CENTER, OUTLINE, FlxColor.WHITE);
		spaceBarCounter.cameras = [game.fakeCam];
		spaceBarCounter.alpha = 0;
		spaceBarCounter.scrollFactor.set();

		if (ClientPrefs.data.mechanics)
		{
			add(waltInstructionsMain);
			add(waltSubTxt);

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
					limitThing += 10; //you people wanted a buff, so here ya go lmfao!!!!!
					initialCount = limitThing;
				}
		}
	}

	override function update(elapsed:Float)
	{	
		switch (game.dad.curCharacter)
		{
			case 'walt-new':
				game.dad.setPosition(220, -50);
			case 'walt-true':
				game.dad.setPosition(240, -200);
			default:
				game.dad.setPosition(0, 0);
		}
		game.boyfriend.setPosition(330, 300);
		
		shaderAnim = Conductor.songPosition / 1000;
		
		if (ClientPrefs.data.shaders)
		{
			waltStatic.setFloat('time', shaderAnim);
			dramaticCamMovement.setFloat('time', shaderAnim);
		}

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
							game.healthThing += PlayState.SONG.song == "Mercy" ? 0.13*limitThing : 1.25; //you people wanted a buff, so here ya go lmfao!!!!!
							limitThing -= 1;
							var mathShit:Float = limitThing / initialCount;
							switch (mathShit)
							{
								case 0.75 | 0.8: 
									mercyBoostIcon.animation.play("phase2-transition");
								case 0.35 | 0.3: 
									mercyBoostIcon.animation.play("phase3-transition");
								case 0: 
									mercyBoostIcon.animation.play("phase4-transition");
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
					if (game.healthThing < 0.25 && limitThing > 0)
					{
						if (mercyTmr != null)
							mercyTmr.cancel();

						disabledDrain = true;
						mercyTmr = new FlxTimer().start(1.2, function(tmr:FlxTimer)
						{
							disabledDrain = false;
							mercyTmr = null;
						});
						game.healthThing += PlayState.SONG.song == "Mercy" ? 0.13*limitThing : 1.25; //you people wanted a buff, so here ya go lmfao!!!!!
						limitThing -= 1;
						var mathShit:Float = limitThing / initialCount;
						switch (mathShit)
						{
							case 0.75 | 0.8: 
								mercyBoostIcon.animation.play("phase2-transition");
							case 0.35 | 0.3: 
								mercyBoostIcon.animation.play("phase3-transition");
							case 0: 
								mercyBoostIcon.animation.play("phase4-transition");
						}
					}
					
				default:
					// nothing
			}
		}
	}

	/**
	* The better and simplified Walt gimmick
	*
	* @author Wither362
	*/
	public function tweenWaltScreen(percentage:Float, alpha:Float):Bool {
		if (game.healthThing <= percentage)
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
						game.backgroundControls(CAM_FLASH_FANCY, {alpha: 0.5, ease: FlxEase.sineOut, timer: 0.2, colors: [247, 230, 166]});

					case "finish":
						for (bullshit in [retardedButPissBehind, sameAsAdobe, pissOfGlory, greaterPiss])
							bullshit.visible = true;
						game.backgroundControls(CAM_FLASH_FANCY, {alpha: 0.5, ease: FlxEase.sineOut, timer: 0.2, colors: [247, 230, 166]});
						game.dad.setPosition(240, -200);
						FlxTween.tween(sameAsAdobe, {alpha: 0}, 0.25, {ease: FlxEase.sineOut});
						FlxTween.tween(camHUD, {alpha: 1}, 0.31, {ease: FlxEase.sineInOut});
				}
			case 'Mercy Stuff idk':
				switch (value1.toLowerCase())
				{
					case 'tweenicons' | 'tween icons':
						if (ClientPrefs.data.mechanics)
						{
							add(mercyBoostIcon);
							add(spaceBarCounter);
							FlxTween.tween(mercyBoostIcon, {alpha: 1}, 2, {ease: FlxEase.sineInOut});
							FlxTween.tween(spaceBarCounter, {alpha: 1}, 3, {ease: FlxEase.sineInOut});
						}
					case 'tweenwaltgoop' | 'tween walt goop':
						FlxTween.tween(game.dad, {alpha: 0}, 5);
						FlxTween.tween(waltGoop, {alpha: 1}, 5);
				}
			case 'Remove Health':
				if (ClientPrefs.data.mechanics && !disabledDrain)
					game.healthThing -= Std.parseFloat(value1);
		}
	}
}