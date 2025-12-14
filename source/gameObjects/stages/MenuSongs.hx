package gameObjects.stages;

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
		overlay.blend = ADD;
		overlay.alpha = 0.45;
		add(overlay);
	}
	
	override function createPost()
	{
		game.boyfriend.visible = false;
		game.dad.visible = false;
		game.gf.visible = false;
	}

	override function beatHit()
	{
		if (!ClientPrefs.data.lowQuality && PlayState.SONG.song.toLowerCase() == 'seeking freedom')
			if (curBeat % 4 == 0)
				seekingFreedomNoteSpawner();

		if (!ClientPrefs.data.lowQuality && PlayState.SONG.song.toLowerCase() == 'curtain call')
			if (curBeat % 8 == 0 && FlxG.random.bool(35))
				deploySillouetteInBG();
	}

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

	override function closeSubState()
	{
		if(paused)
		{
			if (skyTwn != null) skyTwn.active = true;
			if (laneTwn != null) laneTwn.active = true;
			if (lightTwn != null) lightTwn.active = true;
			if (lightTwn2 != null) lightTwn2.active = true;
			if (lightTwn3 != null) lightTwn3.active = true;
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
			case "rotten petals":
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

			case 'ahh the scary (somber night)':
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

			case 'ship the fart yay hooray <3 (distant stars)':
				subpath = 'distant-stars/';
				for (flashableObj in ['sky', 'stars1', 'stars2'])
				{
					var spr = new FlxBackdrop(Paths.image(PlayState.pathway + subpath + flashableObj), X, 0, 0);
					spr.scrollFactor.set(0, 0);
					switch(flashableObj)
					{
						case 'sky':
							spr.velocity.set(0, 0);
						case "stars1":
							spr.velocity.set(-15, 0);
							lightTwn = FlxTween.tween(spr, {alpha: 0.001}, 3, {type: 4});
						case "stars2":
							spr.velocity.set(-15, 0);
							spr.alpha = 0.001;
							lightTwn2 = FlxTween.tween(spr, {alpha: 1}, 3, {type: 4});
					}
					flashableObjects.add(spr);
				}
				var street = new FlxBackdrop(Paths.image(PlayState.pathway + subpath + "street"), X, 0, 0);
				street.velocity.set(-120, 0);
				street.scrollFactor.set(0, 0);
				add(street);

				var fog = new FlxBackdrop(Paths.image(PlayState.pathway + subpath + "fog"), X, 0, 0);
				fog.velocity.set(-150, 0);
				fog.scrollFactor.set(0, 0);
				add(fog);

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

			case 'the wretched tilezones (simple life)':
				subpath = 'simple-life/';
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
				var room = new FlxSprite().loadGraphic(Paths.image(PlayState.pathway + subpath + "room"));
				room.scrollFactor.set(0, 0);
				add(room);

				if (!ClientPrefs.data.lowQuality)
				{
					var steam = new FlxSprite();
					steam.frames = Paths.getSparrowAtlas(PlayState.pathway + subpath + "steam");
					steam.animation.addByPrefix("idle", "idle", 7, true);
					steam.animation.play("idle");
					steam.scrollFactor.set(0, 0);
					add(steam);

					var lighting = new FlxSprite().loadGraphic(Paths.image(PlayState.pathway + subpath + "lightingOverlay"));
					lighting.scrollFactor.set(0, 0);
					add(lighting);
				}
			case 'your final bow':
				var hellSky = new FlxSprite().loadGraphic(Paths.image(PlayState.pathway + subpath + "hellishSky"));
				hellSky.scrollFactor.set(0, 0);
				flashableObjects.add(hellSky);

				var flames = new FlxSprite();
				flames.frames = Paths.getSparrowAtlas(PlayState.pathway + subpath + "flames");
				flames.animation.addByPrefix("idle", "idle", 8, true);
				flames.scrollFactor.set(0, 0);
				flames.animation.play("idle");
				flashableObjects.add(flames);

				var throne = new FlxSprite().loadGraphic(Paths.image(PlayState.pathway + subpath + "throneRoom"));
				throne.scrollFactor.set(0, 0);
				add(throne);

			case 'seeking freedom':
				for (flashableObj in ['bg', 'lights1', 'lights2', 'noteLane'])
				{
					var spr = new FlxSprite().loadGraphic(Paths.image(PlayState.pathway + subpath + flashableObj));
					spr.scrollFactor.set(0, 0);
					switch(flashableObj)
					{
						case 'bg':
							flashableObjects.add(spr);
						case "lights1":
							lightTwn = FlxTween.tween(spr, {alpha: 0.001}, 3, {type: 4});
							flashableObjects.add(spr);
						case "lights2":
							spr.alpha = 0.001;
							lightTwn2 = FlxTween.tween(spr, {alpha: 1}, 3, {type: 4});
							flashableObjects.add(spr);
						case "noteLane":
							spr.alpha = 0.55;
							spr.blend = ADD;
							laneTwn = FlxTween.tween(spr, {alpha: 1}, 5, {ease: FlxEase.expoInOut, type: 4});
							if (!ClientPrefs.data.lowQuality)
								flashableObjects.add(spr);
							else {
								spr.destroy();
								spr = null;
							}
					}
				}

				var discs = new FlxSprite().loadGraphic(Paths.image(PlayState.pathway + subpath + "discs"));
				discs.scrollFactor.set(0, 0);
				add(discs);

				if (!ClientPrefs.data.lowQuality)
				{
					var discLines = new FlxSprite();
					discLines.frames = Paths.getSparrowAtlas(PlayState.pathway + subpath + "discAnim");
					discLines.animation.addByPrefix("idle", "idle", 9, true);
					discLines.animation.play("idle");
					discLines.scrollFactor.set(0, 0);
					add(discLines);

					lights1 = new FlxSprite().loadGraphic(Paths.image(PlayState.pathway + subpath + "lighting"));
					lights1.scrollFactor.set(0, 0);
					add(lights1);
					lights1.blend = ADD;
					lights1.alpha = 0.7;
					lightTwn3 = FlxTween.tween(lights1, {alpha: 0.3}, 6, {ease: FlxEase.expoInOut, type: 4});
				}

			case 'curtain call':
				for (flashableObj in ['seats', 'seatsLighting'])
				{
					var spr = new FlxSprite().loadGraphic(Paths.image(PlayState.pathway + subpath + flashableObj));
					spr.scrollFactor.set(0, 0);

					switch (flashableObj) {
						case 'seats':
							flashableObjects.add(spr);
						case 'seatLighting':
							if (!ClientPrefs.data.lowQuality)
								flashableObjects.add(spr);
							else {
								spr.destroy();
								spr = null;
							}
					}
					flashableObjects.add(spr);
				}

				var stage = new FlxSprite().loadGraphic(Paths.image(PlayState.pathway + subpath + "stage"));
				stage.scrollFactor.set(0, 0);
				add(stage);

				if (!ClientPrefs.data.lowQuality)
				{
					var steam = new FlxSprite();
					steam.frames = Paths.getSparrowAtlas(PlayState.pathway + subpath + "steam");
					steam.animation.addByPrefix("idle", "idle", 7, true);
					steam.animation.play("idle");
					steam.scrollFactor.set(0, 0);
					add(steam);

					var lighting = new FlxSprite().loadGraphic(Paths.image(PlayState.pathway + subpath + "stageLighting"));
					lighting.scrollFactor.set(0, 0);
					add(lighting);
				}

			case 'alone':
				var bg = new FlxSprite().loadGraphic(Paths.image(PlayState.pathway + subpath + 'bg'));
				bg.scrollFactor.set(0, 0);
				add(bg);

				var dark = new FlxSprite().loadGraphic(Paths.image(PlayState.pathway + subpath + 'darkness'));
				dark.alpha = 0.001;
				dark.scrollFactor.set(0, 0);
				add(dark);

				var light = new FlxSprite().loadGraphic(Paths.image(PlayState.pathway + subpath + 'light'));
				light.blend = ADD;
				light.scrollFactor.set(0, 0);
				add(light);

				FlxTween.tween(dark, {alpha: 1}, 5, {ease: FlxEase.sineInOut, type: FlxTween.PINGPONG});
				FlxTween.tween(light, {alpha: 0.5}, 5, {ease: FlxEase.sineInOut, type: FlxTween.PINGPONG});

			case 'mistful wind':
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

				var field = new FlxSprite();
				field.frames = Paths.getSparrowAtlas(PlayState.pathway + subpath + "grassField");
				field.animation.addByIndices("idle", "idle", [1, 2, 0, 2], '', 3, true);
				field.animation.play("idle");
				field.scrollFactor.set(0, 0);
				add(field);

				var overlay = new FlxSprite().loadGraphic(Paths.image(PlayState.pathway + subpath + "lightingOverlay"));
				overlay.scrollFactor.set(0, 0);
				add(overlay);
		}
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
		noteTwn = FlxTween.tween(note.scale, {x: 1.2, y: 1.2}, 7);
	}

	var checkSpawnedChar:Array<Bool> = [
		false, //avier
		false, //everett
		false, //mr. smiles
		false, //white noise
		false //mal
	]; //the nalsquares are plentiful.

	// cooldown timers
	var aTmr:FlxTimer;
	var eTmr:FlxTimer;
	var sTmr:FlxTimer;
	var wTmr:FlxTimer;
	var mTmr:FlxTimer;

	function deploySillouetteInBG()
	{
		// set up data variables
		var rngBullshit:Array<Bool> = [FlxG.random.bool(50), FlxG.random.bool(10), FlxG.random.bool(1.5)]; // Which side to walk from, if Mal can spawn, if Legendary Tumbleweed can spawn
		var charList:Array<String> = ['avier', 'everett', 'girl', 'generic', 'smile', 'white-noise', 'malsquare'];
		var speed:Int = FlxG.random.int(60, 140);
		var yOffset:Int = 0;

		if (checkSpawnedChar[0]) charList.remove('avier');
		if (checkSpawnedChar[1]) charList.remove('everett');
		if (checkSpawnedChar[2]) charList.remove('smile');
		if (checkSpawnedChar[3]) charList.remove('white-noise');

		// prepare sprite
		var getChar:String = charList[FlxG.random.int(0, charList.length - 1)];
		var amWalkin = new FlxSprite();
		amWalkin.frames = Paths.getSparrowAtlas(PlayState.pathway + 'curtain-call/stageWalkers');

		// rng bullshit time
		if (rngBullshit[2]) // Legendary Tumbleweed
		{
			amWalkin.animation.addByPrefix("walkin", "legendary-tumbleweed", 16, true);
			speed = 320;
			yOffset = 50;
			FlxTween.tween(amWalkin, {y: amWalkin.y*0.07}, 0.1, {ease: FlxEase.sineInOut, type: FlxTween.PINGPONG});
		}
		else if (rngBullshit[1] && !rngBullshit[2] && !checkSpawnedChar[4]) // Mal (will get overriden by tumbleweed if triggered)
		{
			amWalkin.animation.addByPrefix("walkin", "mal-og", 6, true);
			speed = 100;
			yOffset = -30;
			mTmr = new FlxTimer().start(18, function(tmr:FlxTimer)
			{
				checkSpawnedChar[4] = false;
				mTmr = null;
			});
			checkSpawnedChar[4] = true;
		}
		else // Regular characters
		{
			amWalkin.animation.addByPrefix("walkin", getChar, 4, true);

			switch (getChar)
			{
				case 'white-noise':
					checkSpawnedChar[3] = true;
					wTmr = new FlxTimer().start(15, function(tmr:FlxTimer)
					{
						checkSpawnedChar[3] = false;
						wTmr = null;
					});
					yOffset = 25;
					speed = 140;
					FlxTween.tween(amWalkin, {y: amWalkin.y + 1}, 1, {ease: FlxEase.sineInOut, type: FlxTween.PINGPONG});
				case 'smile':
					checkSpawnedChar[2] = true;
					sTmr = new FlxTimer().start(20, function(tmr:FlxTimer)
					{
						checkSpawnedChar[2] = false;
						sTmr = null;
					});
					speed = 80;
					yOffset = -40;
				case 'avier':
					checkSpawnedChar[0] = true;
					aTmr = new FlxTimer().start(20, function(tmr:FlxTimer)
					{
						checkSpawnedChar[0] = false;
						aTmr = null;
					});
					speed = 75;
				case 'everett':
					checkSpawnedChar[1] = true;
					eTmr = new FlxTimer().start(25, function(tmr:FlxTimer)
					{
						checkSpawnedChar[1] = false;
						eTmr = null;
					});
					speed = 60;
				case 'malsquare':
					speed = 90;
					yOffset = -10;
			}
		}

		amWalkin.updateHitbox();
		amWalkin.animation.play("walkin");
		amWalkin.scrollFactor.set(0, 0);
		amWalkin.y = 165 - amWalkin.height;
		amWalkin.y += yOffset;

		if (rngBullshit[0]) // From right
		{
			amWalkin.x = 1380;
			amWalkin.velocity.set(-speed, 0);
		}
		else // From left
		{
			amWalkin.x = -80;
			amWalkin.flipX = true;
			amWalkin.velocity.set(speed, 0);
		}

		flashableObjects.insert(1, amWalkin);
	}
}