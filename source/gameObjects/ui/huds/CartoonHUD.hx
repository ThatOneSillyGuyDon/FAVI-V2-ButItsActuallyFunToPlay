package gameObjects.ui.huds;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxObject;
import flixel.util.FlxStringUtil;

import gameObjects.ui.Bar;
import gameObjects.ui.HealthIcon;

// if the hud resembles psych u can just extend this instead of base
@:access(states.game.PlayState)
class CartoonHUD extends BaseHUD
{
	var comboGroup:FlxSpriteGroup;

	public var fancyBarOverlay:FlxSprite;
	public var watermarkTxt:FlxText;
	public var songTxt:FlxText;
	var scoreTxtTween:FlxTween;
	
	var healthBar:Bar;
	var iconP1:HealthIcon;
	var iconP2:HealthIcon;
	public var scoreTxt:FlxText;

	var daPixelZoom:Float = 6;

	// Display Texts
	public var infoDisplay:String = CoolUtil.dashToSpace(PlayState.SONG.song);
	public var engineDisplay:String = '~ Episode 1 ~';
	
	var timeTxt:FlxText;
	var timeBar:Bar;
	var pixelZoom:Float = 6; // idgaf
	
	var showComboNum:Bool = true;
	var showRating:Bool = true;

	// stores the last judgement object
	public static var lastRating:FlxSprite;
	// stores the last combo score objects in an array
	public static var lastScore:Array<FlxSprite> = [];
	
	// TODO: Make combo shit change for week 6, the ground work is already there so incase someone else wants to come on in and mess w it.
	override function init()
	{
		name = 'CARTOON';

		if (PlayState.SONG.song != "Malfunction Legacy")
			daPixelZoom = 5;
		else
			daPixelZoom = 6;
		
		healthBar = new Bar(0, FlxG.height * (!ClientPrefs.data.downScroll ? 0.89 : 0.11), 'healthBar', function() return FreeplayState.freeplayMenuList != 2  ? parent.healthLerp : parent.healthThing, 0, 2);
		healthBar.screenCenter(X);
		healthBar.leftToRight = PlayState.SONG.song == "Devilish Deal" ? true : false;
		healthBar.scrollFactor.set();
		healthBar.visible = !ClientPrefs.data.hideHud;
		healthBar.alpha = ClientPrefs.data.healthBarAlpha;
		reloadHealthBarColors();
		if(ClientPrefs.data.downScroll || PlayState.SONG.stage == "waltRoom" || PlayState.SONG.stage == "menuSongs") healthBar.y = FlxG.height * 0.11;

		//have to make an underlay so you can see the healthbar colors lmao
		fancyBarOverlay = new FlxSprite(healthBar.x, healthBar.y).loadGraphic(Paths.image('episode1Overlay'));
		fancyBarOverlay.scale.set(1.01, 1);
		fancyBarOverlay.screenCenter(X);
		fancyBarOverlay.scrollFactor.set();
		if (ClientPrefs.data.downScroll || PlayState.SONG.stage == "waltRoom" || PlayState.SONG.stage == "menuSongs")
		{
			fancyBarOverlay.y -= 10;
		}
		else
		{
			fancyBarOverlay.y -= 117;
			fancyBarOverlay.flipY = true;
		}
		fancyBarOverlay.visible = PlayState.SONG.song.toLowerCase() != 'cycled sins';
		add(healthBar);
		if (FreeplayState.freeplayMenuList != 2)
			add(fancyBarOverlay);

		iconP1 = new HealthIcon((PlayState.SONG.song == "Mercy" ? "everettmercy" : parent.boyfriend.healthIcon), (PlayState.SONG.song == "Mercy" ? false : true));
		iconP1.y = healthBar.y - 75;

		// reposition specific icons on the healthbar properly
		switch (parent.boyfriend.healthIcon)
		{
			case "everett" | "maleverett-pixel": iconP1.y -= 20;
			case "everettmodern": iconP1.y -= 10;
			case "everettb": iconP1.y -= 5;
		}

		iconP1.visible = !ClientPrefs.data.hideHud;
		iconP1.alpha = ClientPrefs.data.healthBarAlpha;
		add(iconP1);

		iconP2 = new HealthIcon(parent.dad.healthIcon, false);
		iconP2.y = healthBar.y - 75;

		// reposition specific icons on the healthbar properly
		switch (parent.dad.healthIcon)
		{
			case "walt" | "ricky" | "noise": iconP2.y -= 20;
			case "goofy" | "smile" | "relapseNEW-pixel": iconP2.y -= 10;
			case "cross": iconP2.y -= 15;
		}

		iconP2.visible = !ClientPrefs.data.hideHud;
		iconP2.alpha = ClientPrefs.data.healthBarAlpha;
		add(iconP2);
		reloadHealthBarColors();

		scoreTxt = new FlxText(0, ((PlayState.SONG.stage == "menuSongs" || PlayState.SONG.stage == "waltRoom") ? (ClientPrefs.data.downScroll ? 15 : 675) : healthBar.y + 36), FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font("DisneyFont.ttf"), (FreeplayState.freeplayMenuList == 2  ? 28 : 20), FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		scoreTxt.visible = (!ClientPrefs.data.hideHud || !parent.cpuControlled);
		add(scoreTxt);
		
		comboGroup = new FlxSpriteGroup();
		add(comboGroup);

		onUpdateScore(0, 0, 0);

		if (FreeplayState.freeplayMenuList == 2 && !parent.isStoryMode)
		{
		#if desktop
			var peWatermark:FlxText = new FlxText(5, FlxG.height - 29, 0, "", 16);
			peWatermark.setFormat(Paths.font("DisneyFont.ttf"), 28, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			peWatermark.scrollFactor.set();
			peWatermark.text = 'Funkin.avi | ${PlayState.SONG.song} (Hard)';
			peWatermark.cameras = [parent.camOther];
			add(peWatermark);
		#end
			var SCALEdebugText:FlxText = new FlxText(10,10,200,"Default scale mode (ratio)");
			SCALEdebugText.scrollFactor.set(0,0);
			SCALEdebugText.cameras = [parent.camOther];
			add(SCALEdebugText);
		}

		if (PlayState.SONG.stage == 'vaultRoom') iconP2.blend = ADD;

		if (PlayState.SONG.stage == "waltRoom" || PlayState.SONG.stage == "menuSongs")
		{
			fancyBarOverlay.flipY = true;
			for (bar in [healthBar, fancyBarOverlay])
			{
				bar.angle = 90;
				bar.x -= 580;
				bar.y += 270;
			}
			fancyBarOverlay.x += 54;
			fancyBarOverlay.y -= 53;
			iconP1.x = healthBar.x + 220;
			iconP2.x = healthBar.x + 220;
		}

		switch (PlayState.SONG.song)
		{
			case "Devilish Deal" | "Isolated" | "Lunacy" | "Delusional":
				if (parent.isStoryMode) 
					engineDisplay = "~ Episode 1 ~";
				else
					engineDisplay = "~ Freeplay ~";
			default:
				if (parent.isStoryMode) 
					engineDisplay = "~ Episode ??? ~";
				else
					engineDisplay = "~ Freeplay ~";
		}
		watermarkTxt = new FlxText(0, 0, 0, engineDisplay);
		watermarkTxt.setFormat(Paths.font('DisneyFont.ttf'), 32, FlxColor.WHITE);
		watermarkTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		if (ClientPrefs.data.downScroll) watermarkTxt.setPosition(0, 655); else watermarkTxt.setPosition(0, 8);
		watermarkTxt.screenCenter(X);
		if (FreeplayState.freeplayMenuList != 2)
			add(watermarkTxt);

		songTxt = new FlxText(watermarkTxt.x, watermarkTxt.y + 30, 1280, (PlayState.SONG.song == "Dont Cross" ? "Don't Cross!" : '$infoDisplay'));
		songTxt.setFormat(Paths.font('DisneyFont.ttf'), 22, FlxColor.WHITE, CENTER);
		songTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		songTxt.alpha = 0.6;
		songTxt.screenCenter(X);
		if (FreeplayState.freeplayMenuList != 2)
			add(songTxt);

		if (PlayState.SONG.stage == "menuSongs")
		{
			watermarkTxt.visible = false;
			songTxt.alpha = 1;
			songTxt.angle = 90;
			songTxt.screenCenter(Y);
			songTxt.x += 270;
			scoreTxt.screenCenter(Y);
			scoreTxt.angle = -90;
			scoreTxt.x -= 270;
			iconP1.visible = false;
			iconP2.visible = false;
		}

		// shitty thing to make it so the health bar is visible at all times
		if (PlayState.SONG.stage == "waltRoom")
		{
			for (funny in [healthBar, fancyBarOverlay, iconP1, iconP2])
				funny.cameras = [parent.fakeCam];
		}
	}

	override function onGameOver()
	{
		for (highEndShit in [fancyBarOverlay])
			if (highEndShit != null)
			{
				remove(highEndShit);
				highEndShit.kill();
				highEndShit.destroy();
				highEndShit = null;
			}
	}
	
	override function onUpdateScore(score:Int = 0, accuracy:Float = 0, misses:Int = 0, missed:Bool = false)
	{
		if (FreeplayState.freeplayMenuList == 2)
			scoreTxt.text = 'Score: ' + score + ' | Misses: ' + misses + ' | Accuracy: ' + CoolUtil.floorDecimal(accuracy * 100, 2) + '% ' + ' [' + (parent.ratingName != '?' ? '${parent.ratingFC}' : '?') + ']';//peeps wanted no integer rating
		//This basically now makes the score/misses look like this: 1,000 instead of this: 1000
		else
			scoreTxt.text = 'Score: ' + FlxStringUtil.formatMoney(score, false, true) + ' | Combo Breaks: ' + FlxStringUtil.formatMoney(misses, false, true) + ' | Rank: ' + (parent.ratingName != '?' ? '${parent.ratingFC} (${CoolUtil.floorDecimal(accuracy * 100, 2)}%)' : '?');

		if (!missed && !parent.cpuControlled)
			doScoreBop();
	}
	
	public function doScoreBop():Void
	{
		if(!ClientPrefs.data.scoreZoom)
			return;

		if(scoreTxtTween != null)
			scoreTxtTween.cancel();

		scoreTxt.scale.x = 1.075;
		scoreTxt.scale.y = 1.075;
		scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
			onComplete: function(twn:FlxTween) {
				scoreTxtTween = null;
			}
		});

		// Updating Discord Rich Presence (with Time Left)
		if (parent.autoUpdateRPC)
			switch (PlayState.SONG.song)
			{
				case "Joygrim" | "Neglection" | "Scrapped" | "Whimsical Bar Blues": DiscordClient.changePresence("Playing a song", "It's a secret...", "icon", "random", true, parent.songLength - Conductor.songPosition - ClientPrefs.data.noteOffset);
				default: DiscordClient.changePresence(parent.discordTxt[0], (parent.isDisplayingScore ? scoreTxt.text : parent.discordTxt[1]), CoolUtil.spaceToDash(parent.discordIcon), "random", true, parent.songLength - Conductor.songPosition - ClientPrefs.data.noteOffset);
			}
	}
	
	public function updateIconsPosition()
	{
		var iconOffset:Int = 26;

		if (PlayState.SONG.stage == "waltRoom")
		{
			iconP1.y = healthBar.y + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * iconP1.scale.y - 150) / 2 - iconOffset * 11.85;
			iconP2.y = healthBar.y + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (150 * iconP2.scale.y) / 2 - iconOffset * 13.85;
		}
		else
		{
			iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * iconP1.scale.x - 150) / 2 - iconOffset;
			iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (150 * iconP2.scale.x) / 2 - iconOffset * 2;
			if (PlayState.SONG.song == "Devilish Deal")
			{
				DDStage.minnieIcon.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(-healthBar.percent, 0, 100, 100, 0) * 0.01)) - (150 * iconP2.scale.x) / 2 - iconOffset * 25;
				DDStage.satanIcon.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(-healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * iconP1.scale.x - 150) / 2 - iconOffset * 24;
				DDStage.satanIconPulse.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(-healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * iconP1.scale.x - 150) / 2 - iconOffset * 24;
			}
		}
	}
	
	public function updateIconsScale(elapsed:Float)
	{
		var mult:Float = FlxMath.lerp(1, iconP1.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * parent.playbackRate), 0, 1));
		iconP1.scale.set(mult, mult);
		iconP1.updateHitbox();

		var fuck:Float = PlayState.SONG.song == "Cycled Sins" ? 0.85 : 1;
		var mult:Float = FlxMath.lerp(fuck, iconP2.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * parent.playbackRate), 0, 1));
		iconP2.scale.set(mult, mult);
		iconP2.updateHitbox();
	}
	
	public function updateIconsAnimation()
	{
		if (iconP1.frames.frames.length >= 3 && healthBar.percent > 80)
		{
			if (PlayState.SONG.song == "Isolated") 
				AbandonedStreet.demonBFIcon.animation.curAnim.curFrame = 2;
			iconP1.animation.curAnim.curFrame = 2;
		}
		else if (iconP1.frames.frames.length >= 2 && healthBar.percent < 20)
		{
			if (PlayState.SONG.song == "Isolated") 
				AbandonedStreet.demonBFIcon.animation.curAnim.curFrame = 1;
			iconP1.animation.curAnim.curFrame = 1;
		}
		else
		{
			if (PlayState.SONG.song == "Isolated") 
				AbandonedStreet.demonBFIcon.animation.curAnim.curFrame = 1;
			iconP1.animation.curAnim.curFrame = 0;
		}
		
		if (iconP2.frames.frames.length >= 2 && healthBar.percent > 80)
		{
			if (PlayState.SONG.song == "Isolated")
			{
				AbandonedStreet.lunacyIcon.animation.curAnim.curFrame = 1;
				AbandonedStreet.delusionalIcon.animation.curAnim.curFrame = 1;
			}
			iconP2.animation.curAnim.curFrame = 1;
		}
		else if (iconP2.frames.frames.length >= 3 && healthBar.percent < 20)
		{
			if (PlayState.SONG.song == "Isolated")
			{
				AbandonedStreet.lunacyIcon.animation.curAnim.curFrame = 2;
				AbandonedStreet.delusionalIcon.animation.curAnim.curFrame = 2;
			}
			iconP2.animation.curAnim.curFrame = 2;
		}
		else
		{
			if (PlayState.SONG.song == "Isolated")
			{
				AbandonedStreet.lunacyIcon.animation.curAnim.curFrame = 0;
				AbandonedStreet.delusionalIcon.animation.curAnim.curFrame = 0;
			}
			iconP2.animation.curAnim.curFrame = 0;
		}
	}

	public function reloadHealthBarColors()
	{
		switch (PlayState.SONG.song)
		{
			case "Mercy":
				healthBar.setColors(FlxColor.fromRGB(97, 72, 52), 
					FlxColor.fromRGB(255, 239, 176));
			case "Devilish Deal":
				healthBar.setColors(FlxColor.fromRGB(135, 99, 99),
					FlxColor.fromRGB(158, 158, 158));
			default:
				healthBar.setColors(FlxColor.fromRGB(parent.dad.healthColorArray[0], parent.dad.healthColorArray[1], parent.dad.healthColorArray[2]),
					FlxColor.fromRGB(parent.boyfriend.healthColorArray[0], parent.boyfriend.healthColorArray[1], parent.boyfriend.healthColorArray[2]));
		}
		healthBar.updateBar();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		updateIconsPosition();
		updateIconsScale(elapsed);
		updateIconsAnimation();

		if (parent.boyfriend.curCharacter == "everett-ghost")
			iconP1.blend = ADD;
		else
			iconP1.blend = NORMAL;

		// shitty system for the camera to stay updated
		var rotRateWn = curStep / 9.5;

		if (parent.boyfriend.curCharacter == "everett-ghost")
			iconP1.y += (((healthBar.y - 85) + Math.sin(rotRateWn * 2) * 20 * 0.45) - iconP1.y) / 12;

		if (parent.dad.curCharacter == "white-noise-new")
			iconP2.y += (((healthBar.y - 85) + -Math.sin(rotRateWn * 2) * 20 * 0.45) - iconP2.y) / 12;

		if (parent.cpuControlled)
		{
			scoreTxt.visible = false;
		}
		
		if (!parent.startingSong && !parent.paused && parent.updateTime && !parent.endingSong)
		{
			var curTime:Float = Math.max(0, Conductor.songPosition - ClientPrefs.data.noteOffset);
			parent.songPercent = (curTime / parent.songLength);

			var songCalc:Float = (parent.songLength - curTime);

			var secondsTotal:Int = Math.floor(songCalc / 1000);
			if(secondsTotal < 0) secondsTotal = 0;

			if (PlayState.SONG.stage == "menuSongs")
				songTxt.text = PlayState.SONG.song + " - " + FlxStringUtil.formatTime(secondsTotal, false);
		}
	}
	
	override function beatHit()
	{
		// why is this even a fucking thing ???????? --- because it is jason lmao
		/*if (boyfriend.boppingIcon) iconP1.scale.set(1.2, 1.2);
		if (dad.boppingIcon) iconP2.scale.set(1.2, 1.2);*/

		// ok ok i need a plan b
		// retarded code AND untested because monthly motel shit bla bla bla
		// just know that we are NOT sonic legacy :sob:
		if (parent.introSoundsSuffix != "-sins")
		{
			if (parent.boyfriend.curCharacter != 'etherealMickey' || parent.boyfriend.curCharacter != 'everett-relapse') iconP1.scale.set(1.2, 1.2);
			if (parent.dad.curCharacter != 'white-noise-new' || parent.dad.curCharacter != 'etherealGoofy' || parent.dad.curCharacter != 'walt-new'
				|| parent.dad.curCharacter != 'walt-true' || parent.dad.curCharacter != 'relapsedNEW') iconP2.scale.set(1.2, 1.2);
		}

		iconP1.updateHitbox();
		iconP2.updateHitbox();
	}
	
	override function onCharacterChange()
	{
		reloadHealthBarColors();
		iconP1.changeIcon(parent.boyfriend.healthIcon, false, false, true);
		iconP2.changeIcon(parent.dad.healthIcon, false, false, true);
	}
	
	override function popUpScore(ratingImage:String, combo:Int)
	{
		if (!ClientPrefs.data.comboStacking && comboGroup.members.length > 0) {
			for (spr in comboGroup) {
				spr.destroy();
				comboGroup.remove(spr);
			}
		}

		var placement:String = Std.string(combo);

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.35;

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (PlayState.isPixelStage)
		{
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		if (FreeplayState.freeplayMenuList == 2)
		{
			pixelShitPart1 = 'legacyUI/';
			if (PlayState.isPixelStage)
				pixelShitPart2 = '-pixel';
			else 
				pixelShitPart2 = '';
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + (((parent.ratingPercent == 1 || parent.cpuControlled) && PlayState.SONG.song != "Cycled Sins") ? "marvelous" : ratingImage) + (PlayState.SONG.song == "Malfunction" ? '-mal' : '') + pixelShitPart2));
		rating.scale.set(0.4, 0.4);
		rating.screenCenter();
		rating.x = FlxG.width * 0.8;
		rating.y = 100;
		rating.acceleration.y = 550 * parent.playbackRate * parent.playbackRate;
		rating.velocity.y -= FlxG.random.int(140, 175) * parent.playbackRate;
		rating.velocity.x -= FlxG.random.int(0, 10) * parent.playbackRate;
		rating.visible = (!ClientPrefs.data.hideHud && showRating);
		if (!ClientPrefs.data.downScroll)
			rating.y += 495 + (PlayState.SONG.song == "Malfunction" ? ((ratingImage == "sick" && parent.ratingPercent != 1) ? -50 : -35) : 0);
		if (PlayState.SONG.song == "War Dilemma" && !ClientPrefs.data.downScroll)
			rating.y -= 120;
		comboGroup.add(rating);
		
		if (!ClientPrefs.data.comboStacking)
		{
			if (lastRating != null) lastRating.kill();
			lastRating = rating;
		}

		if (!PlayState.isPixelStage)
		{
			//nothing
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.28));
		}
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		if(combo >= 1000) {
			seperatedScore.push(Math.floor(combo / 1000) % 10);
		}
		seperatedScore.push(Math.floor(combo / 100) % 10);
		seperatedScore.push(Math.floor(combo / 10) % 10);
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		var xThing:Float = 0;
		
		if (lastScore != null)
		{
			while (lastScore.length > 0)
			{
				lastScore[0].kill();
				lastScore.remove(lastScore[0]);
			}
		}

		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + (((parent.ratingPercent == 1 || parent.cpuControlled) && (FreeplayState.freeplayMenuList != 2 && PlayState.SONG.song != "Cycled Sins")) ? ((PlayState.SONG.song == "Malfunction") ? '-malgold' : '-gold') : (PlayState.SONG.song == "Malfunction" ? '-mal' : '')) + pixelShitPart2));
			numScore.scale.set(0.22, 0.22);
			numScore.screenCenter();
			numScore.x = (32 * daLoop) - 90;
			numScore.x += FlxG.width * 0.92;
			numScore.y = rating.y + (PlayState.SONG.song == "Malfunction" ? ((ratingImage == "sick" && parent.ratingPercent != 1) ? 80 : 56) : 45);

			if (!ClientPrefs.data.comboStacking)
				lastScore.push(numScore);

			if (!PlayState.isPixelStage)
			{
				//nothing
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom * 0.28));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300) * parent.playbackRate * parent.playbackRate;
			numScore.velocity.y -= FlxG.random.int(140, 160) * parent.playbackRate;
			numScore.velocity.x = FlxG.random.float(-5, 5) * parent.playbackRate;
			numScore.visible = !ClientPrefs.data.hideHud;

			//if (combo >= 10 || combo == 0)
			if(showComboNum)
				comboGroup.add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2 / parent.playbackRate, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002 / parent.playbackRate
			});

			daLoop++;
			if(numScore.x > xThing) xThing = numScore.x;
		}

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2 / parent.playbackRate, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001 / parent.playbackRate
		});
	}
}
