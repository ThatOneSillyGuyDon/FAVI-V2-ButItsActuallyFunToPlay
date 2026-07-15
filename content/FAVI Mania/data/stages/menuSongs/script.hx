import flixel.util.FlxStringUtil;

var skyTwn:FlxTween;
var lightTwn:FlxTween;
var lightTwn2:FlxTween;
var lightTwn3:FlxTween;
var laneTwn:FlxTween;
var noteTwn:FlxTween;
var flashableObjects:FlxSpriteGroup;
var lights1:FlxSprite;
var lights2:FlxSprite;
var pathway = 'stages/';
var subpath:String;

function onLoad()
{
	defaultCamZoom = 1;
	generateBGVariant(PlayState.SONG.song);
	
	var underlay = new FlxSprite().loadGraphic(Paths.image(pathway + "maniaUnderlay"));
	underlay.cameras = [camHUD];
	add(underlay);
	
	var overlay = new FlxSprite().loadGraphic(Paths.image(pathway + "maniaOverlay"));
	overlay.cameras = [camOther];
	overlay.blend = 0;
	overlay.alpha = 0.45;
	add(overlay);
}

function onCreatePost()
{
	allowBaseTimer = canRotateCam = boyfriend.visible = dad.visible = gf.visible = iconP1.visible = iconP2.visible = timeBar.visible = false;
	
	playHUD.flipBar();
	healthBar.setColors(FlxColor.WHITE, FlxColor.BLACK);
	healthBar.angle = timeTxt.angle = -90;
	scoreTxt.angle = 90;
	healthBar.setPosition(60, 340);
	scoreTxt.setPosition(-315, 340);
	timeTxt.setPosition(280, 340);
	scoreTxt.setFormat(Paths.font('resultsFont.ttf'), 20, FlxColor.WHITE, 'center', FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	timeTxt.setFormat(Paths.font('resultsFont.ttf'), 20, FlxColor.WHITE, 'center', FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	
	modManager.setValue("transformX", -9999, 1);
	modManager.setValue("transformX", -320, 0);
}

function onBeatHit()
{
	if (!ClientPrefs.lowQuality && PlayState.SONG.song.toLowerCase() == 'seeking freedom' && curBeat % 4 == 0) seekingFreedomNoteSpawner();
	if (!ClientPrefs.lowQuality && PlayState.SONG.song.toLowerCase() == 'curtain call' && curBeat % 8 == 0 && FlxG.random.bool(35)) deploySillouetteInBG();
}

function onOpenSubState()
{
	if (paused)
	{
		if (skyTwn != null) skyTwn.active = false;
		if (laneTwn != null) laneTwn.active = false;
		if (lightTwn != null) lightTwn.active = false;
		if (lightTwn2 != null) lightTwn2.active = false;
		if (lightTwn3 != null) lightTwn3.active = false;
	}
}

function onCloseSubState()
{
	if (paused)
	{
		if (skyTwn != null) skyTwn.active = true;
		if (laneTwn != null) laneTwn.active = true;
		if (lightTwn != null) lightTwn.active = true;
		if (lightTwn2 != null) lightTwn2.active = true;
		if (lightTwn3 != null) lightTwn3.active = true;
	}
}

function onUpdatePost(elapsed:Float)
{
	var curTime:Float = Math.max(0, Conductor.songPosition - ClientPrefs.noteOffset);
	songPercent = (curTime / songLength);
	var songCalc:Float = (songLength - curTime);
	var secondsTotal:Int = Math.floor(songCalc / 1000);
	if (secondsTotal < 0) secondsTotal = 0;
	timeTxt.text = PlayState.SONG.song + " - " + FlxStringUtil.formatTime(secondsTotal, false);
	if (lights1 != null) lights1.color = flashableObjects.color;
	if (lights2 != null) lights2.color = flashableObjects.color;
}

function onEvent(eventName:String, value1:String, value2:String)
{
	switch (eventName)
	{
		case "Mania BG Flash":
			var triggerVars:Array<String> = value1.split(',');
			if (ClientPrefs.flashing)
			{
				if (skyTwn != null) skyTwn.cancel();
				if (flashableObjects != null)
				{
					flashableObjects.color = FlxColor.fromRGB(Std.parseInt(triggerVars[3]), Std.parseInt(triggerVars[4]), Std.parseInt(triggerVars[5]));
					skyTwn = FlxTween.color(flashableObjects, Std.parseFloat(triggerVars[0]),
						FlxColor.fromRGB(Std.parseInt(triggerVars[3]), Std.parseInt(triggerVars[4]), Std.parseInt(triggerVars[5])), FlxColor.WHITE, {
							ease: PlayState.returnTweenEase(triggerVars[1]),
							onComplete: function(twn:FlxTween) {
								skyTwn = null;
							}
						});
				}
			}
	}
}

function generateBGVariant(songName:String)
{
	flashableObjects = new FlxSpriteGroup();
	flashableObjects.scrollFactor.set(0, 0);
	add(flashableObjects);
	
	var subpath:String = Paths.sanitize(songName) + '/';
	switch (songName.toLowerCase())
	{
		case "rotten petals":
			subpath = 'rotten-petals/';
			for (flashableObj in ['sky', 'stars1', 'stars2'])
			{
				var spr = new FlxSprite().loadGraphic(Paths.image(pathway + subpath + flashableObj));
				spr.scrollFactor.set(0, 0);
				switch (flashableObj)
				{
					case "stars1":
						lightTwn = FlxTween.tween(spr, {alpha: 0.001}, 3, {type: 4});
					case "stars2":
						spr.alpha = 0.001;
						lightTwn2 = FlxTween.tween(spr, {alpha: 1}, 3, {type: 4});
				}
				flashableObjects.add(spr);
			}
			var street = new FlxSprite().loadGraphic(Paths.image(pathway + subpath + "street"));
			street.scrollFactor.set(0, 0);
			add(street);
			
		case 'ahh the scary (somber night)':
			subpath = 'somber-night/';
			var spr = new FlxSprite().loadGraphic(Paths.image(pathway + subpath + 'sky'));
			spr.scrollFactor.set(0, 0);
			flashableObjects.add(spr);
			
			var city = new FlxSprite().loadGraphic(Paths.image(pathway + subpath + "city"));
			city.scrollFactor.set(0, 0);
			add(city);
			
			lights1 = new FlxSprite().loadGraphic(Paths.image(pathway + subpath + "lights1"));
			lights1.scrollFactor.set(0, 0);
			add(lights1);
			
			lights2 = new FlxSprite().loadGraphic(Paths.image(pathway + subpath + "lights2"));
			lights2.scrollFactor.set(0, 0);
			add(lights2);
			
			lightTwn = FlxTween.tween(lights1, {alpha: 0.001}, 3, {type: 4});
			lights2.alpha = 0.001;
			lightTwn2 = FlxTween.tween(lights2, {alpha: 1}, 3, {type: 4});
			
		case 'ship the fart yay hooray <3 (distant stars)':
			subpath = 'distant-stars/';
			for (flashableObj in ['sky', 'stars1', 'stars2'])
			{
				var spr = new FlxBackdrop(Paths.image(pathway + subpath + flashableObj), FlxAxes.X, 0, 0);
				spr.scrollFactor.set(0, 0);
				switch (flashableObj)
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
			var street = new FlxBackdrop(Paths.image(pathway + subpath + "street"), FlxAxes.X, 0, 0);
			street.velocity.set(-120, 0);
			street.scrollFactor.set(0, 0);
			add(street);
			
			var fog = new FlxBackdrop(Paths.image(pathway + subpath + "fog"), FlxAxes.X, 0, 0);
			fog.velocity.set(-150, 0);
			fog.scrollFactor.set(0, 0);
			add(fog);
			
		case 'am i real?':
			subpath = 'am-i-real/';
			var bg = new FlxSprite().loadGraphic(Paths.image(pathway + subpath + "bg"));
			bg.scrollFactor.set(0, 0);
			add(bg);
			lightTwn = FlxTween.tween(bg.colorTransform,
				{
					redOffset: 255,
					blueOffset: 255,
					greenOffset: 255,
					redMultiplier: -1,
					blueMultiplier: -1,
					greenMultiplier: -1
				}, 5,
				{
					ease: FlxEase.sineInOut,
					type: FlxTween.PINGPONG
				});
				
		case 'the wretched tilezones (simple life)':
			subpath = 'simple-life/';
			for (flashableObj in ['sky', 'stars1', 'stars2'])
			{
				var spr = new FlxSprite().loadGraphic(Paths.image(pathway + subpath + flashableObj));
				spr.scrollFactor.set(0, 0);
				switch (flashableObj)
				{
					case "stars1":
						lightTwn = FlxTween.tween(spr, {alpha: 0.001}, 3, {type: 4});
					case "stars2":
						spr.alpha = 0.001;
						lightTwn2 = FlxTween.tween(spr, {alpha: 1}, 3, {type: 4});
				}
				flashableObjects.add(spr);
			}
			var room = new FlxSprite().loadGraphic(Paths.image(pathway + subpath + "room"));
			room.scrollFactor.set(0, 0);
			add(room);
			
			if (!ClientPrefs.lowQuality)
			{
				var steam = new FlxSprite();
				steam.frames = Paths.getSparrowAtlas(pathway + subpath + "steam");
				steam.animation.addByPrefix("idle", "idle", 7, true);
				steam.animation.play("idle");
				steam.scrollFactor.set(0, 0);
				add(steam);
				
				var lighting = new FlxSprite().loadGraphic(Paths.image(pathway + subpath + "lightingOverlay"));
				lighting.scrollFactor.set(0, 0);
				add(lighting);
			}
		case 'your final bow':
			subpath = 'your-final-bow/';
			var hellSky = new FlxSprite().loadGraphic(Paths.image(pathway + subpath + "hellishSky"));
			hellSky.scrollFactor.set(0, 0);
			flashableObjects.add(hellSky);
			
			var flames = new FlxSprite();
			flames.frames = Paths.getSparrowAtlas(pathway + subpath + "flames");
			flames.animation.addByPrefix("idle", "idle", 8, true);
			flames.scrollFactor.set(0, 0);
			flames.animation.play("idle");
			flashableObjects.add(flames);
			
			var throne = new FlxSprite().loadGraphic(Paths.image(pathway + subpath + "throneRoom"));
			throne.scrollFactor.set(0, 0);
			add(throne);
			
		case 'seeking freedom':
			subpath = 'seeking-freedom/';
			for (flashableObj in ['bg', 'lights1', 'lights2', 'noteLane'])
			{
				var spr = new FlxSprite().loadGraphic(Paths.image(pathway + subpath + flashableObj));
				spr.scrollFactor.set(0, 0);
				switch (flashableObj)
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
						spr.blend = 0;
						laneTwn = FlxTween.tween(spr, {alpha: 1}, 5, {ease: FlxEase.expoInOut, type: 4});
						if (!ClientPrefs.lowQuality) flashableObjects.add(spr); else
						{
							spr.destroy();
							spr = null;
						}
				}
			}
			
			var discs = new FlxSprite().loadGraphic(Paths.image(pathway + subpath + "discs"));
			discs.scrollFactor.set(0, 0);
			add(discs);
			
			if (!ClientPrefs.lowQuality)
			{
				var discLines = new FlxSprite();
				discLines.frames = Paths.getSparrowAtlas(pathway + subpath + "discAnim");
				discLines.animation.addByPrefix("idle", "idle", 9, true);
				discLines.animation.play("idle");
				discLines.scrollFactor.set(0, 0);
				add(discLines);
				
				lights1 = new FlxSprite().loadGraphic(Paths.image(pathway + subpath + "lighting"));
				lights1.scrollFactor.set(0, 0);
				add(lights1);
				lights1.blend = 0;
				lights1.alpha = 0.7;
				lightTwn3 = FlxTween.tween(lights1, {alpha: 0.3}, 6, {ease: FlxEase.expoInOut, type: 4});
			}
			
		case 'curtain call':
			subpath = 'curtain-call/';
			for (flashableObj in ['seats', 'seatsLighting'])
			{
				var spr = new FlxSprite().loadGraphic(Paths.image(pathway + subpath + flashableObj));
				spr.scrollFactor.set(0, 0);
				
				switch (flashableObj)
				{
					case 'seats':
						flashableObjects.add(spr);
					case 'seatLighting':
						if (!ClientPrefs.lowQuality) flashableObjects.add(spr); else
						{
							spr.destroy();
							spr = null;
						}
				}
				flashableObjects.add(spr);
			}
			
			var stage = new FlxSprite().loadGraphic(Paths.image(pathway + subpath + "stage"));
			stage.scrollFactor.set(0, 0);
			add(stage);
			
			if (!ClientPrefs.lowQuality)
			{
				var steam = new FlxSprite();
				steam.frames = Paths.getSparrowAtlas(pathway + subpath + "steam");
				steam.animation.addByPrefix("idle", "idle", 7, true);
				steam.animation.play("idle");
				steam.scrollFactor.set(0, 0);
				add(steam);
				
				var lighting = new FlxSprite().loadGraphic(Paths.image(pathway + subpath + "stageLighting"));
				lighting.scrollFactor.set(0, 0);
				add(lighting);
			}
			
		case 'alone':
			subpath = 'alone/';
			var bg = new FlxSprite().loadGraphic(Paths.image(pathway + subpath + 'bg'));
			bg.scrollFactor.set(0, 0);
			add(bg);
			
			var dark = new FlxSprite().loadGraphic(Paths.image(pathway + subpath + 'darkness'));
			dark.alpha = 0.001;
			dark.scrollFactor.set(0, 0);
			add(dark);
			
			var light = new FlxSprite().loadGraphic(Paths.image(pathway + subpath + 'light'));
			light.blend = 0;
			light.scrollFactor.set(0, 0);
			add(light);
			
			FlxTween.tween(dark, {alpha: 1}, 5, {ease: FlxEase.sineInOut, type: 4});
			FlxTween.tween(light, {alpha: 0.5}, 5, {ease: FlxEase.sineInOut, type: 4});
			
		case 'mistful wind':
			subpath = 'mistful-wind/';
			for (flashableObj in ['sky', 'stars1', 'stars2'])
			{
				var spr = new FlxSprite().loadGraphic(Paths.image(pathway + subpath + flashableObj));
				spr.scrollFactor.set(0, 0);
				switch (flashableObj)
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
			field.frames = Paths.getSparrowAtlas(pathway + subpath + "grassField");
			field.animation.addByIndices("idle", "idle", [1, 2, 0, 2], '', 3, true);
			field.animation.play("idle");
			field.scrollFactor.set(0, 0);
			add(field);
			
			var overlay = new FlxSprite().loadGraphic(Paths.image(pathway + subpath + "lightingOverlay"));
			overlay.scrollFactor.set(0, 0);
			add(overlay);
	}
}

function seekingFreedomNoteSpawner()
{
	var note = new FlxSprite(1300, -60).loadGraphic(Paths.image(pathway + 'seeking-freedom/notes/note${FlxG.random.int(1, 8)}'));
	note.scrollFactor.set(0, 0);
	note.flipY = FlxG.random.bool(50);
	note.scale.set(0.2, 0.2);
	note.velocity.set(-300, 160);
	note.acceleration.set(-35, -55);
	if (flashableObjects != null) flashableObjects.add(note);
	noteTwn = FlxTween.tween(note.scale, {x: 1.2, y: 1.2}, 7);
}

var checkSpawnedChar:Array<Bool> = [
	false, // avier
	false, // everett
	false, // mr. smiles
	false, // white noise
	false // mal
]; // the nalsquares are plentiful.

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
	amWalkin.frames = Paths.getSparrowAtlas(pathway + 'curtain-call/stageWalkers');
	
	// rng bullshit time
	if (rngBullshit[2]) // Legendary Tumbleweed
	{
		amWalkin.animation.addByPrefix("walkin", "legendary-tumbleweed", 16, true);
		speed = 320;
		yOffset = 50;
		FlxTween.tween(amWalkin, {y: amWalkin.y * 0.07}, 0.1, {ease: FlxEase.sineInOut, type: 4});
	}
	else if (rngBullshit[1] && !rngBullshit[2] && !checkSpawnedChar[4]) // Mal (will get overriden by tumbleweed if triggered)
	{
		amWalkin.animation.addByPrefix("walkin", "mal-og", 6, true);
		speed = 100;
		yOffset = -30;
		mTmr = new FlxTimer().start(18, function(tmr:FlxTimer) {
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
				wTmr = new FlxTimer().start(15, function(tmr:FlxTimer) {
					checkSpawnedChar[3] = false;
					wTmr = null;
				});
				yOffset = 25;
				speed = 140;
				FlxTween.tween(amWalkin, {y: amWalkin.y + 1}, 1, {ease: FlxEase.sineInOut, type: 4});
			case 'smile':
				checkSpawnedChar[2] = true;
				sTmr = new FlxTimer().start(20, function(tmr:FlxTimer) {
					checkSpawnedChar[2] = false;
					sTmr = null;
				});
				speed = 80;
				yOffset = -40;
			case 'avier':
				checkSpawnedChar[0] = true;
				aTmr = new FlxTimer().start(20, function(tmr:FlxTimer) {
					checkSpawnedChar[0] = false;
					aTmr = null;
				});
				speed = 75;
			case 'everett':
				checkSpawnedChar[1] = true;
				eTmr = new FlxTimer().start(25, function(tmr:FlxTimer) {
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
