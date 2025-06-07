package states.stages;

import states.stages.objects.*;

#if !flash 
import openfl.filters.ShaderFilter;
#end

class ShotgunMick extends BaseStage
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

	public var relapseIconLol:HealthIcon;

	//RELAPSE GIMMICK
	var dodgeWarning:FlxSprite;
	public var dodged:Bool;
	public var shootin:Bool;

	public var shaderAnim:Float = 0;

	override function create()
	{
		game.defaultCamZoom = PlayState.SONG.song == "Cycled Sins" ? 0.46 : 0.6;
		game.cameraSpeed = 0.9;

		//Phase 2 shaders
		glitchBG = new FlxRuntimeShader(Shaders.vignetteGlitch, null, 130);

		bg1 = new FlxSprite(0, 50);
		if (PlayState.SONG.song == "Cycled Sins Legacy") 
		{
			bg1.frames = Paths.getSparrowAtlas(PlayState.pathway + 'relapse1');
			bg1.animation.addByPrefix('idle', 'Bg bg', 10, true);
		}
		else
			bg1.loadGraphic(Paths.image(PlayState.pathway + 'relapseBG-nominnie'));
		bg1.scale.set(7, 7);
		bg1.antialiasing = false;
		if (PlayState.SONG.song == "Cycled Sins Legacy") bg1.animation.play('idle');
		add(bg1);

		bg2 = new FlxSprite(0, 50).loadGraphic(Paths.image(PlayState.pathway + 'relapse2'));
		bg2.scale.set(7, 7);
		bg2.antialiasing = false;
		bg2.visible = false;
		add(bg2);
	}
	
	override function createPost()
	{

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

/*
	override function beatHit()
	{
		switch (PlayState.SONG.song)
		{
			case 'Cycled Sins Legacy':
				switch (curBeat)
				{
					case 272:
						FlxTween.tween(game, {healthThing: 0.1}, 20, {ease: FlxEase.quartInOut});
				}
		}
	}
*/
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
				redVignette.setFloat('time', shaderAnim);
				dramaticCamMovement.setFloat('time', shaderAnim);
				staticEffect.setFloat('uTime', shaderAnim);
				staticEffect.setFloat('iTime', shaderAnim);
		}

		if (PlayState.SONG.song == "Cycled Sins Legacy") game.gf.visible = false;
		game.dad.setPosition(-1000, 270);
    	game.boyfriend.setPosition(590, 250);
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
						FlxTween.tween(game.iconP2, {alpha: 0}, 1, {ease: FlxEase.sineOut});
						FlxTween.tween(relapseIconLol, {alpha: 1}, 1, {ease: FlxEase.sineOut});
					case 3:
						game.sinsEnd = true;

					//Putting the lyrics stuff here because for some reson it's not working in the chart editor	
					case 4: game.manageLyrics('relapse2NEW-pixel', 'You REALLY think this is...', 'freeplayDisneyFont.ttf', 30, 1.1, 'sineInOut');
					case 5: game.manageLyrics('relapse2NEW-pixel', '...some kind of...', 'freeplayDisneyFont.ttf', 30, 1.4, 'sineInOut');
					case 6: game.manageLyrics('relapse2NEW-pixel', '...silly little GAME?', 'freeplayDisneyFont.ttf', 30, 1.15, 'sineInOut');
					case 7: game.manageLyrics('relapse2NEW-pixel', 'Soon enough...', 'freeplayDisneyFont.ttf', 30, 1.3, 'sineInOut');
					case 8: game.manageLyrics('relapse2NEW-pixel', "...you'll understand what ME...", 'freeplayDisneyFont.ttf', 30, 1.5, 'sineInOut');
					case 9: game.manageLyrics('relapse2NEW-pixel', '...AND MY FRIENDS...', 'freeplayDisneyFont.ttf', 30, 1.6, 'sineInOut');
					case 10: game.manageLyrics('relapse2NEW-pixel', '...HAVE TO GO THROUGH!', 'freeplayDisneyFont.ttf', 30, 1.1, 'sineInOut');
					case 11: game.manageLyrics('relapse2NEW-pixel', 'Sooner or later...', 'freeplayDisneyFont.ttf', 30, 1.1, 'sineInOut');
					case 12: game.manageLyrics('relapse2NEW-pixel', '...your DEATH will be nothing...', 'freeplayDisneyFont.ttf', 30, 1.1, 'sineInOut');
					case 13: game.manageLyrics('relapse2NEW-pixel', '...BUT CYCLED SINS!', 'freeplayDisneyFont.ttf', 30, 1.1, 'sineInOut');

					case 14: game.manageLyrics('relapse2NEW-pixel', 'Why doesn\'t my torturous ways travail...', 'freeplayDisneyFont.ttf', 30, 5, 'sineInOut');
					case 15: game.manageLyrics('relapse2NEW-pixel', 'I\'m mental, indisposed and ill...', 'freeplayDisneyFont.ttf', 30, 5, 'sineInOut');
					case 16: game.manageLyrics('relapse2NEW-pixel', 'I\'m deranged, full of hatred...', 'freeplayDisneyFont.ttf', 30, 5, 'sineInOut');
					case 17: game.manageLyrics('relapse2NEW-pixel', 'This should\'ve been your termination... isn\'t it?', 'freeplayDisneyFont.ttf', 30, 5, 'sineInOut');
					
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