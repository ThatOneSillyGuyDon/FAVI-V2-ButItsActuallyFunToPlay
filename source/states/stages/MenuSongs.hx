package states.stages;

import states.stages.objects.*;

class MenuSongs extends BaseStage
{
	var flashableObjects:FlxSpriteGroup;

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
			case "rotten petals" | 'seeking freedom' | 'alone' | 'curtain call':
				subpath = 'rotten-petals/';
				for (flashableObj in ['sky', 'stars1', 'stars2'])
				{
					var spr = new FlxSprite().loadGraphic(Paths.image(PlayState.pathway + subpath + flashableObj));
					spr.scrollFactor.set(0, 0);
					spr.ID = flashableObj.length-1;
					switch(flashableObj)
					{
						case "stars1":
							FlxTween.tween(spr, {alpha: 0.001}, 3, {type: 4});
						case "stars2":
							spr.alpha = 0.001;
							FlxTween.tween(spr, {alpha: 1}, 3, {type: 4});
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
				spr.ID = 0;
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

				FlxTween.tween(lights1, {alpha: 0.001}, 3, {type: 4});
				lights2.alpha = 0.001;
				FlxTween.tween(lights2, {alpha: 1}, 3, {type: 4});

			case 'am i real?':
				var bg = new FlxSprite().loadGraphic(Paths.image(PlayState.pathway + subpath + "bg"));
				bg.scrollFactor.set(0, 0);
				add(bg);
				FlxTween.tween(bg.colorTransform, {
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

	var skyTwn:FlxTween;
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

	override function update(elapsed:Float)
	{
		if (lights1 != null) //so basically, they can't be put in the group obj cause then the city lights won't appear, which is why I did this one for you so you don't have to suffer like I did (don)
			lights1.color = lights2.color = flashableObjects.color;

		super.update(elapsed);
	}
}