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
		PlayState.isGreyscale = true;

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

		spawnNotes['bf'] = false;
		spawnNotes['muckney'] = false;
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
				spawnNotes['muckney'] = false;
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
	// For events
	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case 'Tween Char Scale':
				switch (value1.toLowerCase())
				{
					case 'dad1':
						game.dadGroup.scale.y = 0.6;
						game.dadGroup.scale.x = 0.6;
						FlxTween.tween(game.dadGroup, {'scale.x': 0}, 0.3, {ease: FlxEase.quartInOut});
					case 'dad2':
						FlxTween.tween(game.dadGroup, {'scale.x': 1, 'scale.y': 1}, 0.3, {ease: FlxEase.quartOut});
						spawnNotes['muckney'] = true;
					case 'dad3':
						FlxTween.tween(game.dadGroup, {'scale.x': 0}, 0.3, {ease: FlxEase.quartInOut, onComplete: function(twn:FlxTween)
						{
							game.dadGroup.scale.y = 0.6;
							FlxTween.tween(game.dadGroup, {'scale.x': 0.6}, 0.3, {ease: FlxEase.quartOut});
						}});
						spawnNotes['muckney'] = false;
					case 'bf1':
						game.boyfriendGroup.scale.x = 0.9;
						game.boyfriendGroup.scale.y = 0.9;
						FlxTween.tween(game.boyfriendGroup, {'scale.y': 0}, 0.5, {ease: FlxEase.quartInOut, onComplete: function(twn:FlxTween)
						{
							game.boyfriendGroup.scale.x = 0.7;
							FlxTween.tween(game.boyfriendGroup, {'scale.y': 0.7}, 0.5, {ease: FlxEase.quartOut});
						}});
						spawnNotes['bf'] = true;
					case 'bf2':
						FlxTween.tween(game.boyfriendGroup, {'scale.x': 0}, 0.7, {ease: FlxEase.quartInOut, onComplete: function(twn:FlxTween)
						{
							game.boyfriendGroup.scale.y = 0.9;
							FlxTween.tween(game.boyfriendGroup, {'scale.x': 0.9}, 0.7, {ease: FlxEase.quartOut});
						}});
						spawnNotes['bf'] = false;
				}
		}
	}

	override function opponentNoteHit(note:Note)
	{
		if (spawnNotes['muckney'] && !note.isSustainNote) birthdayParticles(dadGroup);
	}

	override function goodNoteHit(note:Note)
	{
		if (states.stages.Birtbhday.spawnNotes['bf']) birthdayParticles(boyfriendGroup);
	}

	public function birthdayParticles(targetGroup:FlxSpriteGroup) {
		var path:String = 'favi/ui/bdaynotes';
		var particleNote:FlxSprite = new FlxSprite().loadGraphic(Paths.image('$path/note_${FlxG.random.int(1, 3)}'));
		particleNote.setGraphicSize(Std.int(particleNote.width * 0.7));
		particleNote.updateHitbox();
		particleNote.x = FlxG.random.int(Std.int(targetGroup.x - (targetGroup == boyfriendGroup ? 0 : 150)), Std.int(targetGroup.x + (targetGroup == boyfriendGroup ? 500 : 300)));
		particleNote.y = targetGroup.y + 170;
		particleNote.velocity.y += targetGroup.y - 400;
		particleNote.acceleration.y = 400 * game.playbackRate;
		particleNote.angle = FlxG.random.int(0, 360);
		
		FlxTween.tween(particleNote, {alpha: 0.0001}, 3, {
			onComplete: function(tween:FlxTween)
			{
				particleNote.destroy();
			}
		});
		add(particleNote);
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