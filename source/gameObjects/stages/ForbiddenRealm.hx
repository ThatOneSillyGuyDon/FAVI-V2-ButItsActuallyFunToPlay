package gameObjects.stages;

#if !flash 
import openfl.filters.ShaderFilter;
#end

import lime.app.Application;

class ForbiddenRealm extends BaseStage
{
	//MALFUNCTION
	var mickeyEmitter:FlxEmitter;
	var fuckingsquares:FlxSprite;
	var whiteBG:FlxSprite;
	var glitchBG:FlxRuntimeShader;
	var staticBG:FlxRuntimeShader;
	var accessPath:String;

	public var crashLives:FlxText;
	public var crashLivesIcon:FlxSprite;

	public var crashLivesCounter:Int = 0;

	var heartTween:FlxTween;
	var malfunctionTxt:FlxTween;

	public static var malFreakG:FlxRuntimeShader = new FlxRuntimeShader(Shaders.freakyGlitch, null, 120);
	public static var malBG:FlxRuntimeShader = new FlxRuntimeShader(Shaders.malfunctionBGEffect, null, 120);

	//SHADERS WOOOOOOOOOOOOOOOOO
	public static var chromZoomShader:FlxRuntimeShader = new FlxRuntimeShader(Shaders.aberration, null, 150);
	public static var chromNormalShader:FlxRuntimeShader = new FlxRuntimeShader(Shaders.aberrationDefault, null, 150);
	public static var blurShader:FlxRuntimeShader = new FlxRuntimeShader(Shaders.tiltShift, null, 120);

	public static var blurEffect:Float = 0.0;
	public var shaderAnim:Float = 0;

	public static var blurTween:FlxTween;

	override function create()
	{
		game.defaultCamZoom = 0.8;

		accessPath = PlayState.SONG.song == 'Malfunction Legacy' ? 'PixelMouse' : 'malfunctionBG-NEW';
		
		staticBG = new FlxRuntimeShader(Shaders.tvStatic, null, 120);
		glitchBG = new FlxRuntimeShader(Shaders.vignetteGlitch, null, 130);

		fuckingsquares = new FlxSprite(-750, -850);
		fuckingsquares.loadGraphic(Paths.image(PlayState.pathway + accessPath));
		fuckingsquares.scale.set(1.2, 1);
		fuckingsquares.updateHitbox();
		fuckingsquares.antialiasing = false;
		fuckingsquares.scrollFactor.set(1, 1);
		fuckingsquares.active = false;
		if (ClientPrefs.data.shaders && !ClientPrefs.data.lowQuality)
			fuckingsquares.shader = malBG;
		add(fuckingsquares);

		var greyParticles:FlxEmitter = new FlxEmitter(-2080.5, 650.4);
		greyParticles.launchMode = SQUARE;
		greyParticles.velocity.set(-50, -200, 50, -600, -90, 0, 90, -600);
		greyParticles.scale.set(4, 4, 4, 4, 0, 0, 0, 0);
		greyParticles.drag.set(0, 0, 0, 0, 5, 5, 10, 10);
		greyParticles.width = 4787.45;
		greyParticles.alpha.set(1, 1);
		greyParticles.lifespan.set(1.9, 4.9);
		greyParticles.loadParticles(Paths.image(PlayState.pathway + 'greyParticle'), 500, 16, true);
		greyParticles.start(false, FlxG.random.float(.0521, .1060), 1000000);
		
		whiteBG = new FlxSprite(-800, -200).makeGraphic(1, 1, 0xFFFFFFFF);
		whiteBG.scale.set(FlxG.width, FlxG.height);
		whiteBG.alpha = 0.001;
		whiteBG.active = false;
		add(whiteBG);
		
		if (PlayState.SONG.song != 'Malfunction Legacy')
		{
			add(greyParticles);
		}
	}

	override function createPost()
	{	
		var blackParticles:FlxEmitter = new FlxEmitter(-2080.5, 912.4);
		blackParticles.launchMode = SQUARE;
		blackParticles.velocity.set(-70, -220, 70, -620, -110, 20, 110, -620);
		blackParticles.scale.set(6, 6, 6, 6, 2, 2, 2, 2);
		blackParticles.drag.set(2, 2, 2, 2, 7, 7, 12, 12);
		blackParticles.width = 4787.45;
		blackParticles.alpha.set(1, 1);
		blackParticles.lifespan.set(1.9, 4.9);
		blackParticles.loadParticles(Paths.image(PlayState.pathway + 'particleBlack'), 500, 16, true);
		blackParticles.start(false, FlxG.random.float(.0821, .1460), 1000000);
		
		mickeyEmitter = new FlxEmitter(-2099.8, 1620.4);
		for (i in 0 ... 100)
		{
			var mickeyParticle = new FlxParticle();
			mickeyParticle.frames = Paths.getSparrowAtlas(PlayState.pathway + 'mickParticle');
			mickeyParticle.animation.addByPrefix('mickParticle idle', 'mickParticle idle', 12, true);
			mickeyParticle.animation.play('mickParticle idle');
			mickeyParticle.exists = false;
			mickeyEmitter.add(mickeyParticle);
		}
		mickeyEmitter.launchMode = SQUARE;
		mickeyEmitter.velocity.set(-50, -400, 50, -800, -100, 0, 100, -800);
		mickeyEmitter.scale.set(3.4, 3.4, 3.4, 3.4, 0, 0, 0, 0);
		mickeyEmitter.drag.set(0, 0, 0, 0, 5, 5, 10, 10);
		mickeyEmitter.width = 4200.45;
		mickeyEmitter.alpha.set(1, 1);
		mickeyEmitter.lifespan.set(4, 4.5);
		mickeyEmitter.start(false, FlxG.random.float(.125, .287), 100000);
		mickeyEmitter.emitting = false;
		
		if (PlayState.SONG.song != 'Malfunction Legacy')
			add(blackParticles);
			add(mickeyEmitter);

		if (ClientPrefs.data.shaders)
		{
			if(!ClientPrefs.data.lowQuality)
			{
				camGame.setFilters(
				[
					new ShaderFilter(chromNormalShader),
					new ShaderFilter(blurShader)
				]);
				camHUD.setFilters(
				[
					new ShaderFilter(chromNormalShader),
					new ShaderFilter(blurShader)
				]);
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
		crashLives.cameras = [game.malThing];

		crashLivesIcon.frames = Paths.getSparrowAtlas('favi/ui/malfunctionGimmickIcon');
		crashLivesIcon.animation.addByPrefix('idle', 'lives-icon idle', 15);
		crashLivesIcon.animation.addByPrefix('OMFG IT GLITCHES', 'lives-icon glitchin', 15);
		crashLivesIcon.animation.play('idle');
		crashLivesIcon.scale.set(2.2, 2.2);
		crashLivesIcon.antialiasing = false;
		crashLivesIcon.cameras = [game.malThing];
		add(crashLives);
		add(crashLivesIcon);
		crashLivesCounter += 30;
		crashLives.text = 'Lives: ${crashLivesCounter}';
	}

	override function update(elapsed:Float)
	{
		if (game.dad.curCharacter == 'gm-calm-pixel')
			game.dad.setPosition(-130, 50);
		else
			game.dad.setPosition(-100, 150);
		
		game.boyfriend.setPosition(1300, 600);
		game.gf.visible = false;
		
		if (ClientPrefs.data.shaders)
		{
			chromNormalShader.setFloat('rOffset', game.chromEffect / 20);
			chromNormalShader.setFloat('bOffset', -game.chromEffect / 20);
			if (ClientPrefs.data.epilepsy)
				blurShader.setFloat('bluramount', blurEffect);
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
		if (game.healthThing > 0.05)
			game.healthThing -= 0.016;
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
					new ShaderFilter(chromNormalShader),
					new ShaderFilter(blurShader)
				]);
				camHUD.setFilters([
					new ShaderFilter(chromNormalShader),
					new ShaderFilter(blurShader)
				]);
			}
				
			game.chromEffect += 0.3;
			blurEffect += 1.5;
				
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
				ForbiddenRealm,
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
							camGame.setFilters([new ShaderFilter(chromNormalShader)]);
							camHUD.setFilters([new ShaderFilter(chromNormalShader)]);
						}
						blurTween = null;
					}
				}
			);
		}
	}
}