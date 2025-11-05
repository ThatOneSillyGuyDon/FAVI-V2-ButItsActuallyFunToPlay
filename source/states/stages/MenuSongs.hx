package states.stages;

import states.stages.objects.*;

class MenuSongs extends BaseStage
{
	var skyTwn:FlxTween;
	var lightTwn:FlxTween;
	var lightTwn2:FlxTween;
	var lightTwn3:FlxTween;
	var laneTwn:FlxTween;
	var noteTwn:FlxTween;

	override function create()
	{
		game.defaultCamZoom = 1;

		generateBGVariant(PlayState.SONG.song);

		var underlay = new FlxSprite().loadGraphic(Paths.image(PlayState.pathway + "maniaUnderlay"));
		underlay.cameras = [camHUD];
		add(underlay);

		var overlay = new FlxSprite().loadGraphic(Paths.image(PlayState.pathway + "maniaOverlay"));
		overlay.cameras = [camOther];
		add(overlay);
	}
	
	override function createPost()
	{
		game.boyfriend.visible = false;
		game.dad.visible = false;
		game.gf.visible = false;
	}

	var flashableObjects:FlxSpriteGroup;
	var lights1:FlxSprite;
	var lights2:FlxSprite;
	function generateBGVariant(songName:String)
	{
		flashableObjects = new FlxSpriteGroup();
		flashableObjects.scrollFactor.set(0, 0);
		add(flashableObjects);

		var subpath:String = Paths.formatToSongPath(songName) + '/';
		switch(songName.toLowerCase())
		{
			case "rotten petals" | 'alone' | 'curtain call':
				subpath = 'rotten-petals/';
				for (flashableObj in ['sky', 'stars1', 'stars2'])
				{
					var spr = new FlxSprite().loadGraphic(Paths.image(PlayState.pathway + subpath + flashableObj));
					spr.scrollFactor.set(0, 0);
					switch(flashableObj)
					{
						case "stars1":
							lightTwn = FlxTween.tween(spr, {alpha: 0.001}, 3, {type: 4});
						case "stars2":
							spr.alpha = 0.001;
							lightTwn2 = FlxTween.tween(spr, {alpha: 1}, 3, {type: 4});
					}
					flashableObjects.add(spr);
				}
				var street = new FlxSprite().loadGraphic(Paths.image(PlayState.pathway + subpath + "street"));
				street.scrollFactor.set(0, 0);
				add(street);

			case 'ahh the scary (somber night)': //did these next two cause these would've been a fucking pain in the ass to talk you through about, maly; Goober, if you see this, please do not touch this, let Maly do this bro (don)
				subpath = 'somber-night/';
				var spr = new FlxSprite().loadGraphic(Paths.image(PlayState.pathway + subpath + 'sky'));
				spr.scrollFactor.set(0, 0);
				flashableObjects.add(spr);

				var city = new FlxSprite().loadGraphic(Paths.image(PlayState.pathway + subpath + "city"));
				city.scrollFactor.set(0, 0);
				add(city);

				lights1 = new FlxSprite().loadGraphic(Paths.image(PlayState.pathway + subpath + "lights1"));
				lights1.scrollFactor.set(0, 0);
				add(lights1);

				lights2 = new FlxSprite().loadGraphic(Paths.image(PlayState.pathway + subpath + "lights2"));
				lights2.scrollFactor.set(0, 0);
				add(lights2);

				lightTwn = FlxTween.tween(lights1, {alpha: 0.001}, 3, {type: 4});
				lights2.alpha = 0.001;
				lightTwn2 = FlxTween.tween(lights2, {alpha: 1}, 3, {type: 4});

			case 'am i real?':
				var bg = new FlxSprite().loadGraphic(Paths.image(PlayState.pathway + subpath + "bg"));
				bg.scrollFactor.set(0, 0);
				add(bg);
				lightTwn = FlxTween.tween(bg.colorTransform, {
					redOffset: 255,
					blueOffset: 255,
					greenOffset: 255,
					redMultiplier: -1,
					blueMultiplier: -1,
					greenMultiplier: -1
					}, 5, {ease: FlxEase.sineInOut, type: FlxTween.PINGPONG
				});

			//case 'ship the fart yay hooray <3 (distant stars)':
			//case 'the wretched tilezones (simple life)':
			//case 'your final bow':
			//case 'seeking freedom':
			//case 'alone':
			//case 'curtain call':
		}
	}

	// For events
	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case "Mania BG Flash":
				var triggerVars:Array<String> = value1.split(',');
				if (ClientPrefs.data.flashing)
				{
					switch (value2.toLowerCase())
					{
						case "sky":
							if (skyTwn != null)
								skyTwn.cancel();
							if (flashableObjects != null)
							{
								flashableObjects.color = FlxColor.fromRGB(Std.parseInt(triggerVars[3]), Std.parseInt(triggerVars[4]), Std.parseInt(triggerVars[5]));
								skyTwn = FlxTween.color(
									flashableObjects, 
									Std.parseFloat(triggerVars[0]), 
									FlxColor.fromRGB(Std.parseInt(triggerVars[3]), Std.parseInt(triggerVars[4]), Std.parseInt(triggerVars[5])), 
									FlxColor.WHITE, 
									{
										ease: PlayState.returnTweenEase(triggerVars[1]),
										onComplete: function(twn:FlxTween)
										{
											skyTwn = null;
										}
									}
								);
							}
						case "all": 
							game.backgroundControls(BG_FLASH, {
								timer: Std.parseFloat(triggerVars[0]), 
								ease: PlayState.returnTweenEase(triggerVars[1]), 
								alpha: Std.parseFloat(triggerVars[2]), 
								colors: [Std.parseInt(triggerVars[3]), Std.parseInt(triggerVars[4]), Std.parseInt(triggerVars[5])]
							});
					}
				}
		}
	}

	override function beatHit()
		if (!ClientPrefs.data.lowQuality && PlayState.SONG.song.toLowerCase() == 'seeking freedom')
			if (curBeat % 4 == 0)
				seekingFreedomNoteSpawner();

	override function openSubState(SubState:flixel.FlxSubState)
	{
		if(paused)
		{
			if (skyTwn != null) skyTwn.active = false;
			if (laneTwn != null) laneTwn.active = false;
			if (lightTwn != null) lightTwn.active = false;
			if (lightTwn2 != null) lightTwn2.active = false;
			if (lightTwn3 != null) lightTwn3.active = false;
		}
	}

	override function update(elapsed:Float)
	{
		if (lights1 != null)
			lights1.color = flashableObjects.color;
		if (lights2 != null)
			lights2.color = flashableObjects.color;

		super.update(elapsed);
	}

	function seekingFreedomNoteSpawner()
	{
		var note = new FlxSprite(1300, -60).loadGraphic(Paths.image(PlayState.pathway + 'seeking-freedom/notes/note${FlxG.random.int(1, 8)}'));
		note.scrollFactor.set(0, 0);
		note.flipY = FlxG.random.bool(50);
		note.scale.set(0.2, 0.2);
		note.velocity.set(-300, 160);
		note.acceleration.set(-35, -55);
		if (flashableObjects != null)
			flashableObjects.add(note);
		noteTwn = FlxTween.tween(note.scale, {x: 1.2, y: 1.2}, 7, {onComplete: function(twn:FlxTween)
		{
			if (flashableObjects.members[4] != null)
			{
				FlxTween.tween(note, {alpha: 0}, 0.5, {onComplete: function(twn2:FlxTween)
				{
					flashableObjects.remove(flashableObjects.members[4], true);
				}});
			}
		}});
	}
}