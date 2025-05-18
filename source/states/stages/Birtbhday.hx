package states.stages;

import states.stages.objects.*;

class Birtbhday extends BaseStage
{
	// BIRTHDAY NOTES
	// you welcome
	public static var spawnNotes:Map<String, Bool> = [
		"muckney" => false,
		"bf" => false
	];

	public var offsetTwn:FlxTween;

	override function create()
	{
		game.defaultCamZoom = 1.25;
		game.cameraSpeed = 50;

		var clubhouse:FlxSprite = new FlxSprite(-470, -150).loadGraphic(Paths.image(PlayState.pathway + 'clubhouse'));
		add(clubhouse);

		if (!ClientPrefs.data.lowQuality)
		{
			var ballon1 = new FlxSprite(-250, -310);
			ballon1.frames = Paths.getSparrowAtlas(PlayState.pathway + "Balloon_assets");
			ballon1.animation.addByPrefix("bop", "idle", 24, true);
			ballon1.animation.play("bop");
			add(ballon1);

			var ballon2 = new FlxSprite(350, -310);
			ballon2.frames = Paths.getSparrowAtlas(PlayState.pathway + "Balloon_assets");
			ballon2.animation.addByPrefix("bop", "idle", 24, true);
			ballon2.animation.play("bop");
			add(ballon2);

			for (i in [ballon1, ballon2])
			{
				i.scale.set(0.45, 0.45);
				i.y -= 280; // i got lazy
			}
		}

		var vignette:FlxSprite = new FlxSprite(-250, -140).loadGraphic(Paths.image(PlayState.pathway + 'vignetteOverlay'));
		vignette.cameras = [game.camOther];
		vignette.scale.set(0.75, 0.75);
		vignette.antialiasing = true;
		vignette.scrollFactor.set();
		vignette.active = false;
		add(vignette);
	}
	
	override function createPost()
	{
		game.camBars.fade(FlxColor.BLACK, 0.0001);
		camHUD.alpha = 0.001;

		if (!ClientPrefs.data.lowQuality)
		{
			var banners = new FlxSprite(-480, -110).loadGraphic(Paths.image(PlayState.pathway + "birthdayBanners"));
			banners.scrollFactor.set(1.2, 1.2);
			add(banners);

			var foreObj = new FlxSprite(-470, -400).loadGraphic(Paths.image(PlayState.pathway + 'foreBG'));
			foreObj.scrollFactor.set(1.4, 1.4);
			add(foreObj);
		}
	}

	//Have to put this in update since for some reason it bugs when munckey turns into munpet
	override function update(elapsed:Float)
	{
		switch (game.dad.curCharacter)
		{
			case 'munpet':
				game.dad.setPosition(-240, 0);
			default:
				game.dad.setPosition(-240, -260);
		}
		switch (game.boyfriend.curCharacter)
		{
			case 'xyloboy':
				game.boyfriend.setPosition(650, -100);
			default:
				game.boyfriend.setPosition(650, -360);
		}
		game.gf.setPosition(280, -410);
	}

	override function stepHit()
	{
		switch (curStep)
		{
			case 1407:
				FlxTween.tween(game.dadGroup, {'scale.x': 1, 'scale.y': 1}, 0.3, {ease: FlxEase.quartOut});
		}
	}
	override function beatHit()
	{
		switch (curBeat)
		{
			case 2: game.camBars.fade(FlxColor.BLACK, 3, true);
			case 32: game.defaultCamZoom = 1.18;
			case 60:
				game.cameraSpeed = 0.5;
				game.defaultCamZoom = 0.85;
				FlxTween.tween(camHUD, {alpha: 1}, 3);
			case 64:
				camGame.flash(FlxColor.WHITE, 1);
				game.cameraSpeed = 1;
			case 128:
				game.defaultCamZoom = 0.73;
			case 192:
				game.camFlashSystem(BG_FLASH, {alpha: 0.7, timer: 1, colors: [66, 224, 245]});
				FlxG.camera.zoom += 0.09;
				camHUD.zoom += 0.08;
				game.defaultCamZoom = 1;
				game.cameraSpeed = 0.7;
			case 204 | 205 | 221 | 222 | 223 | 236 | 237 | 253 | 254 | 255: game.defaultCamZoom += 0.1;
			case 206 | 238: game.defaultCamZoom = 1;
			case 224:
				game.defaultCamZoom = 1;
				game.camFlashSystem(BG_FLASH, {alpha: 0.7, timer: 1, colors: [119, 247, 96]});
				FlxG.camera.zoom += 0.09;
				camHUD.zoom += 0.08;
			case 256: game.defaultCamZoom = 0.85;
			case 320: game.tweenCamera(1, 1.5, 'sineInOut');
			case 336:
				game.tweenCamera(1.3, 2.8, 'quartInOut');
				offsetTwn = FlxTween.tween(game.camFollow, {x: game.camFollow.x - 150}, 3, {ease: FlxEase.sineInOut, onComplete: function(twn:FlxTween)
				{
					offsetTwn = null;
				}});
			case 348:
				if (offsetTwn != null)
					offsetTwn.cancel();
				game.tweenCamera(0.75, 1.2, 'quartInOut');
				offsetTwn = FlxTween.tween(game.camFollow, {x: game.camFollow.x + 100}, 1.2, {ease: FlxEase.sineInOut, onComplete: function(twn:FlxTween)
					{
						offsetTwn = null;
					}});
			case 350: 
				game.dadGroup.scale.y = 0.6;
				game.dadGroup.scale.x = 0.6;
				FlxTween.tween(game.dadGroup, {'scale.x': 0}, 0.3, {ease: FlxEase.quartInOut});
			case 352:
				spawnNotes['muckney'] = true;
			case 416: 
				game.boyfriendGroup.scale.x = 0.9;
				game.boyfriendGroup.scale.y = 0.9;
				FlxTween.tween(game.boyfriendGroup, {'scale.y': 0}, 0.5, {ease: FlxEase.quartInOut, onComplete: function(twn:FlxTween)
				{
					game.boyfriendGroup.scale.x = 0.7;
					FlxTween.tween(game.boyfriendGroup, {'scale.y': 0.7}, 0.5, {ease: FlxEase.quartOut});
				}});
			case 418:
				spawnNotes['bf'] = true;
			case 476: game.tweenCamera(0.85, 2, 'quartInOut');
			case 477: FlxTween.tween(game.dadGroup, {'scale.x': 0}, 0.3, {ease: FlxEase.quartInOut, onComplete: function(twn:FlxTween)
				{
					game.dadGroup.scale.y = 0.6;
					FlxTween.tween(game.dadGroup, {'scale.x': 0.6}, 0.3, {ease: FlxEase.quartOut});
				}});
			case 479:
				spawnNotes['muckney'] = false;
			case 481: 
				FlxTween.tween(game.boyfriendGroup, {'scale.x': 0}, 0.7, {ease: FlxEase.quartInOut, onComplete: function(twn:FlxTween)
				{
					game.boyfriendGroup.scale.y = 0.9;
					FlxTween.tween(game.boyfriendGroup, {'scale.x': 0.9}, 0.7, {ease: FlxEase.quartOut});
				}});
				spawnNotes['bf'] = false;
			case 536 | 540 | 544: game.defaultCamZoom += 0.18;
			case 548: game.tweenCamera(0.8, 2, 'sineOut');
			case 552:
				camGame.visible = false;
				camHUD.visible = false;
				game.camOther.flash(FlxColor.WHITE, 3);
		}
		if ((curBeat >= 64 && curBeat <= 191) || (curBeat >= 256 && curBeat <= 319 && curBeat % 2 == 0))
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}
	}
}