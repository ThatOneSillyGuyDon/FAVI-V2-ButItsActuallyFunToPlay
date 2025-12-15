package gameObjects.stages;

#if !flash 
import openfl.filters.ShaderFilter;
#end

import lime.app.Application;

class GrassNation extends BaseStage
{
	var staticSpr:FlxSprite;
	var fuckedBG:FlxSprite;
	var noSignalBG:FlxSprite;
	var noSignalLogo:FlxSprite;

	//MALFUNCTION
	var mickeyEmitter:FlxEmitter;
	var whiteBG:FlxSprite;

	public var crashLives:FlxText;
	public var crashLivesIcon:FlxSprite;

	public var crashLivesCounter:Int = 0;

	var heartTween:FlxTween;
	var malfunctionTxt:FlxTween;

	//SHADERS WOOOOOOOOOOOOOOOOO
	public static var chromZoomShader:FlxRuntimeShader = new FlxRuntimeShader(Shaders.aberration, null, 150);
	public static var chromNormalShader:FlxRuntimeShader = new FlxRuntimeShader(Shaders.aberrationDefault, null, 150);
	public static var malFreakG:FlxRuntimeShader = new FlxRuntimeShader(Shaders.freakyGlitch, null, 120);
	public static var malBG:FlxRuntimeShader = new FlxRuntimeShader(Shaders.malfunctionBGEffect, null, 120);
	public static var blurShader:FlxRuntimeShader = new FlxRuntimeShader(Shaders.tiltShift, null, 120);

	public static var blurEffect:Float = 0;
	public var shaderAnim:Float = 0;

	public static var blurTween:FlxTween;

	override function create()
	{	
		if (!ClientPrefs.data.lowQuality)
		{
			var white:FlxSprite = new FlxSprite().makeGraphic(FlxG.width*5, FlxG.height*5, FlxColor.WHITE);
			white.scrollFactor.set(0, 0);
			white.antialiasing = ClientPrefs.data.antialiasing;
			white.screenCenter();
			add(white);

			var grass1:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image(PlayState.pathway + 'grass4'));
			grass1.scrollFactor.set(0.45, 0.45);
			grass1.antialiasing = false;
			if (ClientPrefs.data.shaders && !ClientPrefs.data.lowQuality)
				grass1.shader = malBG;
			add(grass1);

			var grass2:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image(PlayState.pathway + 'grass3'));
			grass2.scrollFactor.set(0.57, 0.57);
			grass2.antialiasing = false;
			if (ClientPrefs.data.shaders && !ClientPrefs.data.lowQuality)
				grass2.shader = malBG;
			add(grass2);

			var grass3:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image(PlayState.pathway + 'grass2'));
			grass3.scrollFactor.set(0.65, 0.65);
			grass3.antialiasing = false;
			if (ClientPrefs.data.shaders && !ClientPrefs.data.lowQuality)
				grass3.shader = malBG;
			add(grass3);

			var grass4:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image(PlayState.pathway + 'grass1'));
			grass4.scrollFactor.set(0.75, 0.75);
			grass4.antialiasing = false;
			if (ClientPrefs.data.shaders && !ClientPrefs.data.lowQuality)
				grass4.shader = malBG;
			add(grass4);

			var ground:FlxBackdrop = new FlxBackdrop(Paths.image(PlayState.pathway + 'ground'), X, 0, 0);
			ground.antialiasing = false;
			add(ground);

			var cloudClutters:FlxBackdrop = new FlxBackdrop(Paths.image(PlayState.pathway + 'cloudClutters'), X, 0, 0);
			cloudClutters.antialiasing = false;
			cloudClutters.scrollFactor.set(0.92, 0.92);
			cloudClutters.velocity.set(100, 0);
			add(cloudClutters);

			whiteBG = new FlxSprite().makeGraphic(1, 1, 0xFFFFFFFF);
			whiteBG.scale.set(FlxG.width*5, FlxG.height*5);
			whiteBG.scrollFactor.set(0, 0);
			whiteBG.screenCenter();
			whiteBG.alpha = 0.001;
			whiteBG.active = false;
			add(whiteBG);

			if (ClientPrefs.data.epilepsy)
			{
				fuckedBG = new FlxSprite();
				fuckedBG.frames = Paths.getSparrowAtlas(PlayState.pathway + 'screenFucker/fuckedUpBG');
				fuckedBG.animation.addByPrefix('bg1', 'bg1', 24, true);
				fuckedBG.animation.addByPrefix('bg2', 'bg2', 24, true);
				fuckedBG.animation.addByPrefix('bg3', 'bg3', 24, true);
				fuckedBG.animation.addByPrefix('bg4', 'bg4', 24, true);
				fuckedBG.animation.play('bg1');
				fuckedBG.antialiasing = false;
				fuckedBG.alpha = 0.0001;
				fuckedBG.scale.set(1.75, 1.75);
				fuckedBG.x -= 250;
				fuckedBG.y += 50;
				add(fuckedBG);
			}

			var fog1:FlxBackdrop = new FlxBackdrop(Paths.image(PlayState.pathway + 'fogBack'), X, 0, 0);
			fog1.antialiasing = false;
			fog1.scrollFactor.set(1.1, 1.1);
			fog1.velocity.set(87, 0);
			add(fog1);

			for (shit in [grass1, grass2, grass3, grass4, ground, cloudClutters, fog1])
			{
				shit.scale.set(1.75, 1.75);
				shit.x -= 250;
				shit.y += 50;
			}

			if (ClientPrefs.data.epilepsy)
			{
				noSignalBG = new FlxSprite();
				noSignalBG.frames = Paths.getSparrowAtlas(PlayState.pathway + 'screenFucker/noSignalBG');
				noSignalBG.animation.addByPrefix('signal1', 'signal1', 24, true);
				noSignalBG.animation.addByPrefix('signal2', 'signal2', 24, true);
				noSignalBG.animation.addByPrefix('signal3', 'signal3', 24, true);
				noSignalBG.animation.addByPrefix('signal4', 'signal4', 24, true);
				noSignalBG.animation.play('signal1');

				staticSpr = new FlxSprite();
				staticSpr.frames = Paths.getSparrowAtlas(PlayState.pathway + 'screenFucker/TVstatic');
				staticSpr.animation.addByPrefix('TVstatic idle', 'TVstatic idle', 20, true);
				staticSpr.animation.play('TVstatic idle');

				noSignalLogo = new FlxSprite().loadGraphic(Paths.image(PlayState.pathway + 'screenFucker/noSignalLogo'));

				for (screenShit in [noSignalBG, staticSpr, noSignalLogo])
				{
					screenShit.cameras = [camHUD];
					screenShit.screenCenter();
					screenShit.alpha = 0.001;
					screenShit.antialiasing = false;
				}
			}
		}
		else
		{
			var white:FlxSprite = new FlxSprite().makeGraphic(FlxG.width*5, FlxG.height*5, FlxColor.WHITE);
			white.scrollFactor.set(0, 0);
			white.antialiasing = ClientPrefs.data.antialiasing;
			white.screenCenter();
			add(white);
			
			var lowQualityBG:FlxSprite = new FlxSprite(-250, 50).loadGraphic(Paths.image('favi/stages/grassNation/bgLowQuality'));
			lowQualityBG.antialiasing = false;
			lowQualityBG.scale.set(1.75, 1.75);
			add(lowQualityBG);

			if (ClientPrefs.data.epilepsy)
			{
				fuckedBG = new FlxSprite(-250, 50).loadGraphic(Paths.image(PlayState.pathway + 'fuckedBGLow'));
				fuckedBG.antialiasing = false;
				fuckedBG.scale.set(1.75, 1.75);
				fuckedBG.alpha = 0.001;
				add(fuckedBG);
			}

			whiteBG = new FlxSprite(-800, -200).makeGraphic(1, 1, 0xFFFFFFFF);
			whiteBG.scale.set(FlxG.width*5, FlxG.height*5);
			whiteBG.scrollFactor.set(0, 0);
			whiteBG.screenCenter();
			whiteBG.alpha = 0.001;
			whiteBG.active = false;
			add(whiteBG);

			if (ClientPrefs.data.epilepsy)
			{
				noSignalBG = new FlxSprite().loadGraphic(Paths.image(PlayState.pathway + 'screenFucker/noSignalLow'));
				staticSpr = new FlxSprite().loadGraphic(Paths.image(PlayState.pathway + 'screenFucker/staticLow'));
				noSignalLogo = new FlxSprite().loadGraphic(Paths.image(PlayState.pathway + 'screenFucker/noSignalLogo'));

				for (screenShit in [noSignalBG, staticSpr, noSignalLogo])
				{
					screenShit.cameras = [camHUD];
					screenShit.screenCenter();
					screenShit.alpha = 0.001;
					screenShit.antialiasing = false;
				}
			}
		}

		if (ClientPrefs.data.epilepsy)
		{
			for (stuf in [noSignalBG, staticSpr, noSignalLogo])
				add(stuf);
		}
		game.camBars.fade(FlxColor.BLACK, 0.0001);
		camHUD.alpha = 0.001;
	}

	override function createPost()
	{
		game.defaultCamZoom = 0.8;
		
		var fog2:FlxBackdrop = new FlxBackdrop(Paths.image(PlayState.pathway + 'fogFore'), X, 0, 0);
		fog2.antialiasing = false;
		fog2.scrollFactor.set(1.32, 1.32);
		fog2.velocity.set(-173, 0);
		add(fog2);

		for (shit in [fog2])
		{
			shit.scale.set(1.75, 1.75);
			shit.x -= 250;
			shit.y += 50;
		}

		game.gf.visible = false;

		if (ClientPrefs.data.shaders)
		{
			if(!ClientPrefs.data.lowQuality)
			{
				camGame.setFilters(
				[
					new ShaderFilter(chromZoomShader),
					new ShaderFilter(blurShader),
				]);
				camHUD.setFilters(
				[
					new ShaderFilter(chromNormalShader),
					new ShaderFilter(blurShader)
				]);
				
				new flixel.util.FlxTimer().start(5, function(tmr)
				{
					camGame.setFilters([new ShaderFilter(chromZoomShader)]);
					camHUD.setFilters([new ShaderFilter(chromNormalShader)]);
				});
			}
		}

		if (ClientPrefs.data.downScroll)
		{
			crashLives = new FlxText(600, 170, 0, "", 20);
			crashLivesIcon = new FlxSprite(550, 170);
		}
		else
		{
			crashLives = new FlxText(600, 500, 0, "", 20);
			crashLivesIcon = new FlxSprite(550, 500);
		}

		crashLives.setFormat(Paths.font("Retro Gaming.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		crashLives.borderSize = 2;
		crashLives.borderQuality = 2;
		crashLives.antialiasing = false;
		crashLives.scrollFactor.set();
		crashLives.cameras = [camHUD];

		crashLivesIcon.frames = Paths.getSparrowAtlas('favi/ui/malfunctionGimmickIcon');
		crashLivesIcon.animation.addByPrefix('idle', 'lives-icon idle', 15);
		crashLivesIcon.animation.addByPrefix('OMFG IT GLITCHES', 'lives-icon glitchin', 15);
		crashLivesIcon.animation.play('idle');
		crashLivesIcon.scale.set(2.2, 2.2);
		crashLivesIcon.antialiasing = false;
		crashLivesIcon.cameras = [camHUD];
		add(crashLives);
		add(crashLivesIcon);
		crashLivesCounter += 25;
		crashLives.text = 'Lives: ${crashLivesCounter}';
	}

	override function update(elapsed:Float)
	{
		shaderAnim = Conductor.songPosition / 1000;
		
		if (ClientPrefs.data.shaders)
		{
			chromNormalShader.setFloat('rOffset', game.chromEffect / 20);
			chromNormalShader.setFloat('bOffset', -game.chromEffect / 20);
			if (!ClientPrefs.data.lowQuality)
			{
				chromZoomShader.setFloat('aberration', game.chromEffect);
				chromZoomShader.setFloat('effectTime', game.chromEffect);
				malFreakG.setFloat("iTime", shaderAnim);
				malBG.setFloat("iTime", shaderAnim);
				if (ClientPrefs.data.epilepsy)
				{
					blurShader.setFloat('bluramount', blurEffect);
				}
			}
		}
	}
	
	var staticTwn:FlxTween;
	var staticTmr:Float = 1;
	
	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case 'Change Dads Cam Offset':
				if (!game.cpuControlled)
				{
					game.opponentCameraOffset[0] += flValue1;
					game.opponentCameraOffset[1] += flValue2;
				}
			case 'Add Mal Shaders':
				if (ClientPrefs.data.shaders)
				{
					if (!ClientPrefs.data.lowQuality && ClientPrefs.data.epilepsy)
					{
						camGame.setFilters(
							[
								new ShaderFilter(chromZoomShader), 
								new ShaderFilter(blurShader)
							]);
						camHUD.setFilters([new ShaderFilter(chromNormalShader), new ShaderFilter(blurShader)]);
					}
				}
			case 'Malfunction Countdown':
				switch(flValue1)
				{
					case 3:
						var count:FlxSprite = new FlxSprite().loadGraphic(Paths.image('favi/countdown/mal-prepare'));
						count.scrollFactor.set();
						count.updateHitbox();
						count.setGraphicSize(Std.int(count.width * 6));
						count.antialiasing = false;
						count.screenCenter();
						add(count);
						FlxTween.tween(count, {y: count.y += 50, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								count.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro3-glitch'), 2);
					case 2:
						var count:FlxSprite = new FlxSprite().loadGraphic(Paths.image('favi/countdown/mal-ready'));
						count.scrollFactor.set();
						count.updateHitbox();
						count.setGraphicSize(Std.int(count.width * 6));
						count.screenCenter();
						count.antialiasing = false;
						add(count);
						FlxTween.tween(count, {y: count.y += 50, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								count.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro2-glitch'), 2);
					case 1:
						var count:FlxSprite = new FlxSprite().loadGraphic(Paths.image('favi/countdown/mal-set'));
						count.scrollFactor.set();
						count.updateHitbox();
						count.setGraphicSize(Std.int(count.width * 6));
						count.screenCenter();
						count.antialiasing = false;
						add(count);
						FlxTween.tween(count, {y: count.y += 50, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								count.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro1-glitch'), 2);
					case 0:
						var count:FlxSprite = new FlxSprite().loadGraphic(Paths.image('favi/countdown/mal-go'));
						count.scrollFactor.set();
						count.updateHitbox();
						count.setGraphicSize(Std.int(count.width * 6));
						count.screenCenter();
						count.antialiasing = false;
						add(count);
						FlxTween.tween(count, {y: count.y += 50, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								count.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('introGo-glitch'), 2);
				}
			case 'Static Event':
				if (ClientPrefs.data.epilepsy)
				{
					switch(value1.toLowerCase().trim())
					{
						case 'togglevis':
							staticSpr.visible = !staticSpr.visible;
						case 'setalpha':
							staticSpr.alpha = Std.parseFloat(value2);
						case 'twnalpha':
							if (staticTwn != null)
								staticTwn.cancel();
							staticTwn = FlxTween.tween(staticSpr, {alpha: Std.parseFloat(value2)}, staticTmr, {ease: FlxEase.circIn});
						case 'settime':
							staticTmr = Std.parseFloat(value2);
					}
				}
		
			case 'Change Mal BG':
				if (ClientPrefs.data.epilepsy)
				{
					switch(value1.toLowerCase().trim())
					{
						case 'togglevis':
							fuckedBG.visible = !fuckedBG.visible;
						case 'setalpha':
							fuckedBG.alpha = Std.parseFloat(value2);
						case 'changebg':
							if (!ClientPrefs.data.lowQuality) fuckedBG.animation.play('bg${Std.parseFloat(value2)}');
					}
				}

			case 'No Signal Event':
				if (ClientPrefs.data.epilepsy)
				{
					switch(value1.toLowerCase().trim())
					{
						case 'togglevis':
							noSignalBG.visible = !noSignalBG.visible;
							noSignalLogo.visible = !noSignalLogo.visible;
						case 'setalpha':
							noSignalLogo.alpha = Std.parseFloat(value2);
							noSignalBG.alpha = Std.parseFloat(value2);
						case 'changebg':
							if (!ClientPrefs.data.lowQuality) noSignalBG.animation.play('signal${Std.parseFloat(value2)}');
					}
				}	
		}
	}

	var malfunctionComboCheck:Int = 0;
	
	override function noteMiss(note:Note)
	{
		malfunctionComboCheck = 0;
	}

	override function goodNoteHit(note:Note)
	{
		if (note.noteType == "Error Note")
		{
			game.healthThing += note.hitHealth * 3.8;
			crashLivesCounter -= 1;

			crashLives.text = 'Lives: ${crashLivesCounter}';

			if (malfunctionTxt != null)
				malfunctionTxt.cancel();
	
			if (heartTween != null)
				heartTween.cancel();
	
			malfunctionTxt = FlxTween.tween(crashLives, {alpha: 1}, 0.6, {
				ease: FlxEase.sineOut,
				onComplete: function(twn:FlxTween)
				{
					malfunctionTxt = FlxTween.tween(crashLives, {alpha: 0.3}, 2, {
						ease: FlxEase.quartInOut,
						startDelay: 5,
						onComplete: function(twn:FlxTween)
						{
							malfunctionTxt = null;
						}
					});
				}
			});
	
			heartTween = FlxTween.tween(crashLivesIcon, {alpha: 1}, 0.6, {
				ease: FlxEase.sineOut,
				onComplete: function(twn:FlxTween)
				{
					heartTween = FlxTween.tween(crashLivesIcon, {alpha: 0.3}, 2, {
						ease: FlxEase.quartInOut,
						startDelay: 5,
						onComplete: function(twn:FlxTween)
						{
							heartTween = null;
						}
					});
				}
			});
	
			// to be honest we can just use shake
			//                                - jason
	
			FlxTween.tween(crashLives, {x: 620}, 0.01);
			FlxTween.tween(crashLivesIcon, {x: 570}, 0.01);
			FlxTween.tween(crashLives, {x: 585}, 0.01, {startDelay: 0.1});
			FlxTween.tween(crashLivesIcon, {x: 535}, 0.01, {startDelay: 0.1});
			FlxTween.tween(crashLives, {x: 610}, 0.01, {startDelay: 0.2});
			FlxTween.tween(crashLivesIcon, {x: 560}, 0.01, {startDelay: 0.2});
			FlxTween.tween(crashLives, {x: 595}, 0.01, {startDelay: 0.3});
			FlxTween.tween(crashLivesIcon, {x: 545}, 0.01, {startDelay: 0.3});
			FlxTween.tween(crashLives, {x: 600}, 0.01, {startDelay: 0.4});
			FlxTween.tween(crashLivesIcon, {x: 550}, 0.01, {startDelay: 0.4});
	
			crashLivesIcon.animation.play("OMFG IT GLITCHES");
	
			new FlxTimer().start(0.25, function(tmr:FlxTimer)
			{
				crashLivesIcon.animation.play('idle');
			});
	
			if (crashLivesCounter == -1)
			{
				game.finishSong();
				trace('0 lives left, closing game...');
				FlxG.sound.play(Paths.sound('funkinAVI/wiiCrash'), 1);
	
				if (FlxG.random.bool(10))
																																																							
					Application.current.window.alert("You Suck LMAO\n\n\nmaybe actually be good at the game for once instead of killing yourself so many times bro.", 'Note About Your Skill:'); // 10% of probability
				else																																																																					/**corny ass shit no offense**/
					Application.current.window.alert("<Message Log>\n========================                                                                                        \n\nPlayState.hx (7504):\n   if(crashLivesCounter == -1)\n   {trace('0 lives left, closing game...')}\n\n\njust give up, you stand no chance against me, everett.",
						'Error On Funkin.avi.exe!:');
	
				Sys.exit(0);
			}
		}

		if (!note.isSustainNote)
		{
			if (PlayState.SONG.song == "Malfunction") malfunctionComboCheck += 1;
			
			if (malfunctionComboCheck == 100 && PlayState.SONG.song == "Malfunction")
			{
				malfunctionComboCheck = 0;
				if (game.ratingPercent == 1)
					crashLivesCounter += 5;
				else if (game.ratingPercent >= 0.9)
					crashLivesCounter += 3;
				else
					crashLivesCounter += 1;
				crashLives.text = 'Lives: ${crashLivesCounter}';
				crashLivesIcon.y -= 20;
				FlxTween.tween(crashLivesIcon, {y: crashLivesIcon.y + 20}, 0.3, {ease: FlxEase.sineOut});
			}
		}
	}

	override function opponentNoteHit(note:Note)
	{
		if (dad.curCharacter == 'glitched-mickey-new-pixel')
		{
			if (game.healthThing > 0.05)
				game.healthThing -= 0.01;
			if (ClientPrefs.data.shaking)
			{
				camGame.shake(0.008, 0.07);
				camHUD.shake(0.015, 0.07);
			}
			if (ClientPrefs.data.shaders)
			{			
				if(!ClientPrefs.data.lowQuality && ClientPrefs.data.epilepsy)
				{
					camGame.setFilters([
						new ShaderFilter(chromZoomShader),
						new ShaderFilter(chromNormalShader),
						new ShaderFilter(blurShader)
					]);
					camHUD.setFilters([
						new ShaderFilter(chromNormalShader),
						new ShaderFilter(blurShader)
					]);
				}
				
				game.chromEffect += 0.2;
				blurEffect += 2.5;
				
				if (game.chromTween != null)
					game.chromTween.cancel();
				if (blurTween != null)
					blurTween.cancel();

				game.chromTween = FlxTween.tween(
					game,
					{
						chromEffect: 0.0001
					},
					0.1,
					{
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							game.chromTween = null;
						}
					}
				);
				blurTween = FlxTween.tween(
					GrassNation,
					{
						blurEffect: 0.0
					},
					0.1,
					{
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
						
							if(!ClientPrefs.data.lowQuality)
							{
								camGame.setFilters([new ShaderFilter(chromZoomShader), new ShaderFilter(chromNormalShader)]);
								camHUD.setFilters([new ShaderFilter(chromNormalShader)]);
							}
							blurTween = null;
						}
					}
				);
			}
		}
		else if (dad.curCharacter == 'malsquare-withFace')
		{
			if (game.healthThing > 0.05)
				game.healthThing -= 0.015;
			if (ClientPrefs.data.shaking)
			{
				camGame.shake(0.01, 0.07);
				camHUD.shake(0.018, 0.07);
			}
			if (ClientPrefs.data.shaders)
			{
				if(!ClientPrefs.data.lowQuality && ClientPrefs.data.epilepsy)
				{
					camGame.setFilters([
						new ShaderFilter(chromZoomShader),
						new ShaderFilter(chromNormalShader),
						new ShaderFilter(blurShader)
					]);
					camHUD.setFilters([
						new ShaderFilter(chromNormalShader),
						new ShaderFilter(blurShader)
					]);
				}
				
				game.chromEffect += 0.22;
				blurEffect += 2.5;
				
				if (game.chromTween != null)
					game.chromTween.cancel();
				if (blurTween != null)
					blurTween.cancel();

				game.chromTween = FlxTween.tween(
					game,
					{
						chromEffect: 0.0001
					},
					0.1,
					{
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							game.chromTween = null;
						}
					}
				);
				blurTween = FlxTween.tween(
					GrassNation,
					{
						blurEffect: 0.0
					},
					0.1,
					{
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
						
							if(!ClientPrefs.data.lowQuality)
							{
								camGame.setFilters([new ShaderFilter(chromZoomShader), new ShaderFilter(chromNormalShader)]);
								camHUD.setFilters([new ShaderFilter(chromNormalShader)]);
							}
							blurTween = null;
						}
					}
				);
			}
		}
	}
}