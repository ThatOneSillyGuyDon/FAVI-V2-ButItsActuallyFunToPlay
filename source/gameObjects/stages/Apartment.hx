package gameObjects.stages;

#if !flash 
import openfl.filters.ShaderFilter;
#end

class Apartment extends BaseStage
{
	var glitchBG:FlxRuntimeShader;
	public static var chromZoomShader:FlxRuntimeShader = new FlxRuntimeShader(Shaders.aberration, null, 150);
	public static var redVignette:FlxRuntimeShader = new FlxRuntimeShader(Shaders.redFromAngryBirds, null, 120);
	public static var dramaticCamMovement:FlxRuntimeShader = new FlxRuntimeShader(Shaders.cameraMovement, null, 150);
	public static var staticEffect:FlxRuntimeShader = new FlxRuntimeShader(Shaders.tvStatic, null, 120);
	public static var grayScale:FlxRuntimeShader = new FlxRuntimeShader(Shaders.grayScale, null, 120);

	//OLD CYCLED SINS
	var bg1:FlxSprite;
	var bg2:FlxSprite;
	var void:FlxSprite;

	public var relapseIconLol:HealthIcon;

	//RELAPSE GIMMICK
	var dodgeWarning:FlxSprite;
	public var dodged:Bool;
	public var shootin:Bool;

	public var shaderAnim:Float = 0;

	var relapseEndNotes:Array<String> = [
		"ah",
		"eh",
		"ah",
		"eh",
		"oo",
		"o",
		"o",
		"ah",
		"ehh",
		"ooo",
		"ahh",
		"eee",
		"ah",
		"ah",
		"e",
		"ah",
		"ah",
		"ah",
		"ee",
		"o",
		"eh",
		"o",
		"e",
		"oh",
		"e",
		"oh",
		"e",
		"ah",
		"ehh",
		"ahh",
		"ahh",
		"ee",
		"ohhh"
	];
	var theFireRises:FlxSprite; // OHHHHHH SINISTER MINDS REFRENCE!!! -- (malyplus)
	var sinsEnd:Bool = false;
	var blackScreen:FlxSprite; // for cool efect trust
	var staticg:FlxSprite;
	override function create()
	{
		game.defaultCamZoom = PlayState.SONG.song == "Cycled Sins" ? 0.46 : 0.6;
		game.cameraSpeed = 0.9;
		PlayState.isGreyscale = false; // FIRE
		game.camGame.pixelPerfectRender = true; // positions of the objects rendered on this camera are rounded

		//Phase 2 shaders
		glitchBG = new FlxRuntimeShader(Shaders.vignetteGlitch, null, 130);

		if (!ClientPrefs.data.lowQuality && PlayState.SONG.song != "Cycled Sins Legacy"){
			void = new FlxSprite(0, 50).loadGraphic(Paths.image(PlayState.pathway + 'void'));
			add(void);
			void.scale.set(7, 7);
			void.antialiasing = false;

			theFireRises = new FlxSprite(0,50);
			theFireRises.frames = Paths.getSparrowAtlas(PlayState.pathway + 'fire');
			theFireRises.animation.addByPrefix('idle', 'fire idle', 4, true);
			theFireRises.scale.set(7, 7);
			theFireRises.antialiasing = false;
			theFireRises.animation.play('idle');
			theFireRises.visible = false;
			add(theFireRises);
		}
		bg1 = new FlxSprite(0, 50);
		if (PlayState.SONG.song == "Cycled Sins Legacy") 
		{
			bg1.frames = Paths.getSparrowAtlas(PlayState.pathway + 'relapse1');
			bg1.animation.addByPrefix('idle', 'Bg bg', 10, true);
		}
		else
			bg1.loadGraphic(Paths.image(PlayState.pathway + (ClientPrefs.data.lowQuality ? 'relapseBG-nominnie' : 'frontBG') /*'relapseBG-nominnie'*/)); 
		bg1.scale.set(7, 7);
		bg1.antialiasing = false;
		if (PlayState.SONG.song == "Cycled Sins Legacy") bg1.animation.play('idle');
		add(bg1);

		bg2 = new FlxSprite(0, 50).loadGraphic(Paths.image(PlayState.pathway + 'relapse2'));
		bg2.scale.set(7, 7);
		bg2.antialiasing = false;
		bg2.visible = false;
		add(bg2);

		// optimization? or no idek
		if (PlayState.SONG.song != "Cycled Sins Legacy"){
			remove(bg2);
			bg2 = null;
		}  
		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(blackScreen);
		blackScreen.scrollFactor.set(0,0);
		blackScreen.alpha = 0;
		blackScreen.visible = true;
		blackScreen.scale.set(4, 4);
		blackScreen.screenCenter();

		staticg = new FlxSprite(0,50);
		staticg.frames = Paths.getSparrowAtlas(PlayState.pathway + 'TVstatic');
		staticg.animation.addByPrefix('idle', 'TVstatic idle', 24, true);
		staticg.antialiasing = false;
		staticg.animation.play('idle');
		staticg.visible = false;
		staticg.alpha = 0.1;
		staticg.scale.set(1.1, 1.1);
		staticg.screenCenter();
		add(staticg);
		staticg.cameras = [game.camOther];
		game.camGame.pixelPerfectRender = true;
		camGame.pixelPerfectRender = true;
	}

	override function createPost()
	{
		if (PlayState.SONG.song == "Cycled Sins Legacy") game.gf.visible = false;
		game.dad.setPosition(-1000, 270);
    	game.boyfriend.setPosition(590, 250);

		dodgeWarning = new FlxSprite(1080, 540).loadGraphic(Paths.image('favi/ui/dodgeSins/cycledWarn' + (FlxG.random.bool(2) ? "-alt" : "")));
		dodgeWarning.antialiasing = false;
		dodgeWarning.scale.set(4, 4);
		dodgeWarning.cameras = [camOther];
		dodgeWarning.screenCenter();
		dodgeWarning.alpha = 0.001;
		if (PlayState.curStage == "apartment")
		{
			if (PlayState.SONG.song == "Cycled Sins")
			{
				dodgeWarning.scale.set(3, 3);
				dodgeWarning.x += 450;
			}
			add(dodgeWarning);
		}

		if (PlayState.SONG.song == "Cycled Sins")
		{
			relapseIconLol = new HealthIcon('relapse2NEW-pixel', false, false, false, false);
			relapseIconLol.scale.set(0.85, 0.85);
			relapseIconLol.alpha = 0.001;
			add(relapseIconLol);
		}

		if (PlayState.SONG.song == "Cycled Sins")
		{
			game.camBars.fade(FlxColor.BLACK, 0.0001);
			camHUD.alpha = 0.001;
		}

		switch (PlayState.SONG.song)
		{
			case 'Cycled Sins Legacy':
				chromZoomShader.setFloat('aberration', 0.12);
				chromZoomShader.setFloat('effectTime', 0.24);
				camGame.setFilters(
				[
					new ShaderFilter(dramaticCamMovement)
				]);
				camHUD.setFilters([new ShaderFilter(grayScale)]);
		}
	}

	override function opponentNoteHit(note:Note)
	{
		if (sinsEnd && !note.isSustainNote)
		{
			var text:FlxText = new FlxText(-750, 490, 150, relapseEndNotes[0]);
			text.setFormat(Paths.font("freeplayDisneyFont.ttf"), 70, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			//trace(relapseEndNotes);
			addBehindDad(text);
			FlxTween.tween(text, {x: text.x - FlxG.random.int(-150, 150), y: text.y - 700, alpha: 0, angle: FlxG.random.int(-20, 20)}, 2, {ease: FlxEase.sineOut});
			relapseEndNotes.shift();
		}
	}

	override function update(elapsed:Float)
	{
		shaderAnim = Conductor.songPosition / 1000;
		
		if (PlayState.SONG.song == "Cycled Sins")
		{
			relapseIconLol.x = game.iconP2.x;
			relapseIconLol.y = game.iconP2.y;
		}

		detectSpace(game.cpuControlled);

		switch (PlayState.SONG.song)
		{
			case 'Cycled Sins Legacy':
				if (ClientPrefs.data.shaders)
				{
					redVignette.setFloat('time', shaderAnim);
					dramaticCamMovement.setFloat('time', shaderAnim);
					staticEffect.setFloat('uTime', shaderAnim);
					staticEffect.setFloat('iTime', shaderAnim);
				}
		}
	}
	public function detectSpace(isAutoplay:Bool = false)
	{
		if (!game.cpuControlled)
		{
			if (FlxG.keys.justPressed.SPACE)
			{
				switch (PlayState.SONG.song)
				{
					default:
						// nothing
				}

				switch (PlayState.curStage)
				{
					case 'apartment':
						if (shootin)
							dodged = true;

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
				case 'apartment':
					if (shootin)
						dodged = true;
				
				default:
					// nothing
			}
		}
	}

	public var uhhTurnBackNormalOrSmth:Void->Void;
	/**
		* # **The Cycled Sins Gimmick**
		*
		* As you can see, it's different than how it was before, it can actually be
		* used now without the need of a fucking event or some shit, so, have fun lol
		*
		* @param reactionTime - Amount of time you have to react before he shoots you
		* @param damageAmount - how much health it'll remove if you fail to dodge
		*  @param doubleBarrel - if Relapse Mouse shoots twice instead of once
		*
		* @author DEMOLITIONDON96
		*/
	public function relapseGimmick(reactionTime:Float = 2, damageAmount:Float = 0.4, ?doubleBarrel:Bool = false)
	{
		dodged = false;
		shootin = true;
		FlxG.sound.play(Paths.sound('funkinAVI/relapseMechs/Reload'), 0.4);
		dodgeWarning.visible = true;
		if (PlayState.SONG.song == "Cycled Sins Legacy") game.dad.playAnim("reload", true);
		game.dad.specialAnim = true;
		FlxTween.color(dodgeWarning, reactionTime - 0.2, FlxColor.WHITE, (doubleBarrel ? FlxColor.YELLOW : FlxColor.RED));

		new FlxTimer().start(reactionTime, function(tmr:FlxTimer)
		{
			FlxG.sound.play(Paths.sound('funkinAVI/relapseMechs/Shoot'), 0.4);
			game.dad.playAnim("attack", true);
			game.dad.specialAnim = true;
			if (!doubleBarrel) dodgeWarning.visible = false;
			new FlxTimer().start(0.1, function(tmr:FlxTimer)
			{
				if(dodged)
				{
					game.boyfriend.playAnim('dodge');
					game.healthThing += 0.05;
				}
				else
				{
					FlxG.camera.shake(0.05, 0.05);
					game.healthThing -= damageAmount;
				}

				if(doubleBarrel)
				{
					FlxTween.color(dodgeWarning, 0.12, FlxColor.YELLOW, FlxColor.RED);
					new FlxTimer().start(0.275, function(tmr:FlxTimer)
					{
						dodgeWarning.visible = false;
						FlxG.sound.play(Paths.sound('funkinAVI/relapseMechs/Shoot'), 0.4);
						game.dad.playAnim("attack", true);
						game.dad.specialAnim = true;
						if(dodged)
						{
							game.boyfriend.playAnim('dodge');
							game.healthThing += 0.05;
						}
						else
						{
							FlxG.camera.shake(0.05, 0.05);
							game.healthThing -= damageAmount / 2;
						}
						dodged = false;
						shootin = false;
						dodgeWarning.color = FlxColor.WHITE;
					});
				}
				else
				{
					dodged = false;
					shootin = false;
					dodgeWarning.color = FlxColor.WHITE;
				}
			});
		});
	}

	public function autoRelapseGimmick(reactionTime:Float = 2, damageAmount:Float = 0.4, ?doubleBarrel:Bool = false)
	{
		dodged = true;
		shootin = true;
		FlxG.sound.play(Paths.sound('funkinAVI/relapseMechs/Reload'), 0.4);
		if (PlayState.SONG.song == "Cycled Sins Legacy") game.dad.playAnim("reload", true);
		game.dad.specialAnim = true;
		
		new FlxTimer().start(reactionTime, function(tmr:FlxTimer)
		{
			FlxG.sound.play(Paths.sound('funkinAVI/relapseMechs/Shoot'), 0.4);
			game.dad.playAnim("attack", true);
			game.dad.specialAnim = true;
			new FlxTimer().start(0.1, function(tmr:FlxTimer)
			{
				game.boyfriend.playAnim('dodge');
				
				dodged = false;
				shootin = false;
			});
		});
	}
	var staticShit:Float = 0.1;
	// For events
	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case 'Relapse Gimmick':
				var triggerInfo:Array<String> = value1.split(',');
				if (ClientPrefs.data.mechanics)
				{
					relapseGimmick(Std.parseFloat(triggerInfo[0]), Std.parseFloat(triggerInfo[1]), value2 == "true" ? true : false);
				}
				else
				{
					if (game.gf.idleSuffix != '-alt')
						autoRelapseGimmick(Std.parseFloat(triggerInfo[0]), Std.parseFloat(triggerInfo[1]), value2 == "true" ? true : false);
				}
			case 'Relapse Events':
				var eventData:Float = Std.parseFloat(value1);
				switch (eventData)
				{
					case 1:
						var warningTxt = new FlxText(0, 0, 1280, "Use the SPACEBAR to dodge\nwhen you see this warning\nappear on your screen.\nGood Luck.", 0);
						warningTxt.setFormat(Paths.font("randomNameToGetPlaceHolderFont.ttf"), 32, FlxColor.WHITE, CENTER);
						warningTxt.alpha = 0.001;
						warningTxt.screenCenter();
						warningTxt.x -= 200;
						warningTxt.cameras = [camOther];
						add(warningTxt);
						game.uiGroup.add(relapseIconLol);
						for (i in [warningTxt, dodgeWarning])
							FlxTween.tween(i, {alpha: 1}, 1.5, {onComplete: function(twn:FlxTween)
							{
								new FlxTimer().start(3.2, function(tmr:FlxTimer)
								{
									FlxTween.tween(i, {alpha: 0.001}, 1.5, {onComplete: function(twn:FlxTween)
									{
										dodgeWarning.visible = false;
										dodgeWarning.alpha = 1;
									}});
								});
							}});
					case 2:
						if (!ClientPrefs.data.lowQuality) theFireRises.visible = true;
						blackScreen.visible = false;
						FlxTween.tween(game.boyfriend, {alpha:1}, 0.001,{ease: FlxEase.sineInOut});
						FlxTween.tween(game.iconP2, {alpha: 0}, 1, {ease: FlxEase.sineOut});
						FlxTween.tween(relapseIconLol, {alpha: 1}, 1, {ease: FlxEase.sineOut});
					case 3:
						sinsEnd = true;
					case 4:
						if (blackScreen.visible){
							blackScreen.alpha = 0;
							FlxTween.tween(blackScreen, {alpha:1}, 0.4,{ease: FlxEase.sineInOut});
							FlxTween.tween(game.boyfriend, {alpha:0.3}, 0.4,{ease: FlxEase.sineInOut});
						}
					case 5:
						if (!staticg.visible){
							staticg.visible = true;
							return;
						}
						staticShit = staticShit + 0.2;
						staticg.alpha = staticShit;
					case 18:
						FlxTween.tween(game, {healthThing: 0.1}, 1, {ease: FlxEase.sineInOut});
						bg1.visible = false;
						bg2.visible = true;
						camGame.visible = true;
						if (ClientPrefs.data.shaders)
						{
							bg2.shader = glitchBG;
							camGame.setFilters(
							[
								new ShaderFilter(staticEffect),
								new ShaderFilter(redVignette),
								new ShaderFilter(chromZoomShader),
								new ShaderFilter(dramaticCamMovement),
							]);
						}
					case 19:
						FlxTween.tween(game, {healthThing: 0.1}, 20, {ease: FlxEase.quartInOut});
				}
		}
	}
}