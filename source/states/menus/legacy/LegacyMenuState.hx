package states.menus.legacy;

import flixel.input.keyboard.FlxKeyboard;
import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepad;

import flixel.util.FlxTimer;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flash.system.System;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;
import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;
import Shaders;
import IndieCrossShaderShit.FXHandler;

using StringTools;

class LegacyMenuState extends MusicBeatState
{
	public static var MouseVersion:String = '2.5.0';
	public static var DemoEngineVersion:String = '0.3.0 PRE-RELEASE';
	public static var psychEngineVersion:String = '0.5.2h'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var bloomShit:WIBloomEffect;
	var chrom:ChromaticAberrationEffect;
	var blurThisShit:TiltshiftEffect;
	var greyscale:GreyscaleEffect;

	var shaders:Array<ShaderEffect> = [];

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	public var camFilter:FlxCamera;

	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		//#if MODS_ALLOWED 'mods', #end
		//#if ACHIEVEMENTS_ALLOWED 'awards', #end
		'credits',
		//#if !switch 'donate', #end
		'options'
	];

	var theCode:Array<Dynamic> = [
		[FlxKey.E, FlxKey.E],
		[FlxKey.R, FlxKey.R],
		[FlxKey.R, FlxKey.R],
		[FlxKey.O, FlxKey.O],
		[FlxKey.R, FlxKey.R],
		[FlxKey.ONE, FlxKey.NUMPADONE],
		[FlxKey.ONE, FlxKey.NUMPADONE],
		[FlxKey.ZERO, FlxKey.NUMPADZERO]];
		var theCodeOrder:Int = 0;

	var ms:FlxSprite;
	var menuart:FlxSprite;
	var mp:FlxSprite;
	var nudes:FlxSprite;
	var eyes:FlxSprite;
	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;
	public static var firstStart:Bool = true;
	public static var finishedFunnyMove:Bool = false;
	var noFreeplay:FlxText;
	//public var camZooming:Bool = false;

	override function create()
	{
		WeekData.loadTheFirstEnabledMod();

		FPClientPrefs.loadShit();

		Application.current.window.title = "Funkin.avi";

		//FlxG.game.filtersEnabled = true;
		//FXHandler.UpdateColors(filters);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null, null, 'icon');
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;
		camFilter = new FlxCamera();
		camFilter.bgColor.alpha = 0;


		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxG.cameras.add(camFilter);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);

		/*if(ClientPrefs.funiShaders)
					{
						chrom = new ChromaticAberrationEffect();
						blurThisShit = new TiltshiftEffect(0.4, 0);
						bloomShit = new WIBloomEffect(0);
						greyscale = new GreyscaleEffect();
						//uncomment these fucking pieces of shit if you feel like testing it.

						addShader(chrom);
						addShader(blurThisShit);
						addShader(bloomShit);
						addShader(greyscale);
						//uncomment these fucking pieces of shit if you feel like testing it.

						if(!ClientPrefs.optimization) {
						if (chrom != null)
						chrom.setChrome(0.003);

						if (bloomShit != null)
						bloomShit.setSize(18.0);

						if(blurThisShit != null)
						blurThisShit.setBlur(0.4);
						}
						//uncomment these fucking pieces of shit if you feel like testing it.


					} //the game fucking breaks now for some reason with this on :(
						//Facts
						*/

		eyes = new FlxSprite().loadGraphic(Paths.image('NEWmenu/HahaSadBoi'));
		eyes.scrollFactor.set(0, 0);
		eyes.screenCenter();
		eyes.updateHitbox();
		eyes.antialiasing = ClientPrefs.globalAntialiasing;
		add(eyes);

		menuart = new FlxSprite().loadGraphic(Paths.image('NEWmenu/newspaper'));
		menuart.scrollFactor.set(0, 0);
		//menuart.setGraphicSize(StdDaInt(menuart.width * 1.175));
		menuart.updateHitbox();
		menuart.screenCenter();
		menuart.antialiasing = ClientPrefs.globalAntialiasing;
		add(menuart);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		magenta.color = 0xFFfd719b;
		add(magenta);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 0.8;
		if(optionShit.length > 6) {
			scale = 0.6 / optionShit.length;
		}

			// Story Mode
			var menuItem:FlxSprite = new FlxSprite(700, 100);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[0]);
			menuItem.animation.addByPrefix('idle', optionShit[0] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[0] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = 0;
			//menuItem.screenCenter(X);
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 2) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();
			if (firstStart)
				FlxTween.tween(menuItem, {y: 100 + (0 * 90)}, 1 + (0 * 0.25), {
					ease: FlxEase.elasticInOut,
					onComplete: function(flxTween:FlxTween)
					{
						finishedFunnyMove = true;
						changeItem();
					}
				});
			else
				menuItem.y = 108 + (0 * 90);

			// Freeplay
			var menuItem:FlxSprite = new FlxSprite(700, 250);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[1]);
			menuItem.animation.addByPrefix('idle', optionShit[1] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[1] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = 1;
			//menuItem.screenCenter(X);
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 2) * 0.135;
			if(optionShit.length < 6) scr = 1;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();
			if (firstStart)
				FlxTween.tween(menuItem, {y: 100 + (0 * 90)}, 1 + (0 * 0.25), {
					ease: FlxEase.elasticInOut,
					onComplete: function(flxTween:FlxTween)
					{
						finishedFunnyMove = true;
						changeItem();
					}
				});
			else
				menuItem.y = 108 + (0 * 90);

			// Credits
			var menuItem:FlxSprite = new FlxSprite(700, 400);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[2]);
			menuItem.animation.addByPrefix('idle', optionShit[2] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[2] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = 2;
			//menuItem.screenCenter(X);
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 2) * 0.135;
			if(optionShit.length < 6) scr = 2;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();
			if (firstStart)
				FlxTween.tween(menuItem, {y: 100 + (0 * 90)}, 1 + (0 * 0.25), {
					ease: FlxEase.elasticInOut,
					onComplete: function(flxTween:FlxTween)
					{
						finishedFunnyMove = true;
						changeItem();
					}
				});
			else
				menuItem.y = 108 + (0 * 90);

			// Settings
			var menuItem:FlxSprite = new FlxSprite(700, 700);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[3]);
			menuItem.animation.addByPrefix('idle', optionShit[3] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[3] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = 3;
			//menuItem.screenCenter(X);
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 2) * 0.135;
			if(optionShit.length < 6) scr = 3;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();
			if (firstStart)
				FlxTween.tween(menuItem, {y: 100 + (0 * 90)}, 1 + (0 * 0.25), {
					ease: FlxEase.elasticInOut,
					onComplete: function(flxTween:FlxTween)
					{
						finishedFunnyMove = true;
						changeItem();
					}
				});
			else
				menuItem.y = 108 + (0 * 90);

			// Donate
			/*var menuItem:FlxSprite = new FlxSprite(100, 700);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[3]);
			menuItem.animation.addByPrefix('idle', optionShit[3] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[3] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = 3;
			//menuItem.screenCenter(X);
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 2) * 0.135;
			if(optionShit.length < 6) scr = 3;
			menuItem.scrollFactor.set(0.75, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();
			if (firstStart)
				FlxTween.tween(menuItem, {y: 100 + (0 * 90)}, 1 + (0 * 0.25), {
					ease: FlxEase.elasticInOut,
					onComplete: function(flxTween:FlxTween)
					{
						finishedFunnyMove = true;
						changeItem();
					}
				});
			else
				menuItem.y = 108 + (0 * 90);

			// Options
			var menuItem:FlxSprite = new FlxSprite(100, 850);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[3]);
			menuItem.animation.addByPrefix('idle', optionShit[3] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[3] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = 3;
			//menuItem.screenCenter(X);
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 2) * 0.135;
			if(optionShit.length < 6) scr = 3;
			menuItem.scrollFactor.set(0.75, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();
			if (firstStart)
				FlxTween.tween(menuItem, {y: 100 + (0 * 90)}, 1 + (0 * 0.25), {
					ease: FlxEase.elasticInOut,
					onComplete: function(flxTween:FlxTween)
					{
						finishedFunnyMove = true;
						changeItem();
					}
				});
			else
				menuItem.y = 108 + (0 * 90);*/

		firstStart = false;

		FlxG.camera.follow(camFollowPos, null, 1);

		var versionShit:FlxText = new FlxText(12, FlxG.height - 84, 0, "Funkin.avi v" + MouseVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat(Paths.font("NewWaltDisneyFontRegular-BPen.ttf"), 22, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 64, 0, "Demolition Engine v" + DemoEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat(Paths.font("NewWaltDisneyFontRegular-BPen.ttf"), 22, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat(Paths.font("NewWaltDisneyFontRegular-BPen.ttf"), 22, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat(Paths.font("NewWaltDisneyFontRegular-BPen.ttf"), 22, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		if(!gamejolt.GJClient.logged && ClientPrefs.language == "Spanish") {
		var achievementText:FlxText = new FlxText(907, FlxG.height - 34, 0, "Presiona 8 para ir al menu de trofeos", 25);
		achievementText.scrollFactor.set();
		achievementText.setFormat(Paths.font("NewWaltDisneyFontRegular-BPen.ttf"), 25, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(achievementText);

		var GameJoltText:FlxText = new FlxText(907, FlxG.height - 54, 0, "Presiona 6 Para Iniciar Sesion en GameJolt", 25);
		GameJoltText.scrollFactor.set();
		GameJoltText.setFormat(Paths.font("NewWaltDisneyFontRegular-BPen.ttf"), 25, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(GameJoltText);

		} else if(!gamejolt.GJClient.logged && ClientPrefs.language == "English") {
		var achievementText:FlxText = new FlxText(937, FlxG.height - 34, 0, "Press 8 to go to the achievement menu", 25);
		achievementText.scrollFactor.set();
		achievementText.setFormat(Paths.font("NewWaltDisneyFontRegular-BPen.ttf"), 25, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(achievementText);

		var GameJoltText:FlxText = new FlxText(937, FlxG.height - 54, 0, "Press 6 to Login to GameJolt", 25);
		GameJoltText.scrollFactor.set();
		GameJoltText.setFormat(Paths.font("NewWaltDisneyFontRegular-BPen.ttf"), 25, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(GameJoltText);
		} else if(gamejolt.GJClient.logged && ClientPrefs.language == "English") {
		var achievementText:FlxText = new FlxText(937, FlxG.height - 34, 0, "Press 8 to go to the achievement menu", 25);
		achievementText.scrollFactor.set();
		achievementText.setFormat(Paths.font("NewWaltDisneyFontRegular-BPen.ttf"), 25, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(achievementText);
		} else if(gamejolt.GJClient.logged && ClientPrefs.language == "Spanish") {
			var achievementText:FlxText = new FlxText(907, FlxG.height - 34, 0, "Presiona 8 Para Ir Al menu De Trofeos", 25);
		achievementText.scrollFactor.set();
		achievementText.setFormat(Paths.font("NewWaltDisneyFontRegular-BPen.ttf"), 25, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(achievementText);
		}

		//Took me like 3 attemps

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 4 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('thursday_night_play');
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a thursday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}

		#if desktop
		Achievements.loadAchievements();
		if(gamejolt.GJClient.logged) {
			var achieveID:Int = Achievements.getAchievementIndex('gamejolt');
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's GameJolt time!
			//i loved when he said "It's GameJolt time!" and started to GameJolting all around
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveGameJoltAchievement();
				gamejolt.GJClient.trophieAdd(169870);
				ClientPrefs.saveSettings();
			}
		}
		#end
		#end

		var scratchStuff:FlxSprite = new FlxSprite();
		scratchStuff.frames = Paths.getSparrowAtlas('funkinAVI-filters/scratchShit');
		scratchStuff.animation.addByPrefix('idle', 'scratch thing 1', 24, true);
		scratchStuff.animation.play('idle');
		scratchStuff.screenCenter();
		scratchStuff.scale.x = 1.1;
		scratchStuff.scale.y = 1.1;
		add(scratchStuff);

		var grain:FlxSprite = new FlxSprite();
		grain.frames = Paths.getSparrowAtlas('funkinAVI-filters/Grainshit');
		grain.animation.addByPrefix('idle', 'grains 1', 24, true);
		grain.animation.play('idle');
		grain.screenCenter();
		grain.scale.x = 1.1;
		grain.scale.y = 1.1;
		add(grain);

		scratchStuff.cameras = [camFilter];
		grain.cameras = [camFilter];

		super.create();
}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement() {
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('funkinAVI/menu/select_sfx'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}

	#if desktop
	function giveGameJoltAchievement() {
		add(new AchievementObject('gamejolt', camAchievement));
		FlxG.save.data.achievementMap;
		FlxG.sound.play(Paths.sound('funkinAVI/menu/select_sfx'), 0.7);
	}
	#end
	#end

	function addShader(effect:ShaderEffect)
	{
		if (!ClientPrefs.funiShaders)
			return;

		shaders.push(effect);

		var newCamEffects:Array<BitmapFilter> = [];

		for (i in shaders)
		{
			newCamEffects.push(new ShaderFilter(i.shader));
		}

		FlxG.camera.setFilters(newCamEffects);
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('funkinAVI/menu/scroll_sfx'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('funkinAVI/menu/scroll_sfx'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				/*if(optionShit[curSelected] == 'freeplay')
					{
						if(FPClientPrefs.episode1FPLock == 'unlocked')
						{
							selectedSomethin = true;
							FlxG.sound.play(Paths.sound('funkinAVI/menu/select_sfx'));
	
							menuItems.forEach(function(spr:FlxSprite)
								{
									if (curSelected != spr.ID)
									{
										// Main Menu Select Animations
										FlxTween.tween(FlxG.camera, {zoom: 1.15}, 2, {ease: FlxEase.quartInOut});
										FlxTween.tween(menuart, {x: -170}, 2.2, {ease: FlxEase.quartInOut});
										FlxTween.tween(magenta, {x: -170}, 2.2, {ease: FlxEase.quartInOut});
										FlxTween.tween(menuart, {y: 200}, 1.9, {ease: FlxEase.quartInOut});
										FlxTween.tween(magenta, {y: -120}, 1.9, {ease: FlxEase.quartInOut});
										// FlxTween.tween(bg, {alpha: 0}, 0.8, {ease: FlxEase.expoIn});
										// FlxTween.tween(magenta, {alpha: 0}, 0.8, {ease: FlxEase.expoIn});
										FlxTween.tween(spr, {x: -250, alpha: 0}, 0.4, {
											ease: FlxEase.quadOut,
											onComplete: function(twn:FlxTween)
											{
												spr.kill();
											}
										});
									}
									else
									{
										FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
										{
											var daChoice:String = optionShit[curSelected];
			
											switch (daChoice)
											{
												case 'freeplay':
													MusicBeatState.switchState(new EpicSelectorWOOO());
											}
										});
									}
								});
						}else{
						FlxG.sound.play(Paths.sound('cancelMenu'));
						noFreeplay.alpha = 1;
						FlxTween.tween(noFreeplay, {alpha: 0}, 1.5, {ease: FlxEase.quadIn, startDelay: 2});
						}
				}else*/ if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('funkinAVI/menu/select_sfx'));

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							// Main Menu Select Animations
							FlxTween.tween(FlxG.camera, {zoom: 1.15}, 2, {ease: FlxEase.quartInOut});
							FlxTween.tween(menuart, {x: -170}, 2.2, {ease: FlxEase.quartInOut});
							FlxTween.tween(magenta, {x: -170}, 2.2, {ease: FlxEase.quartInOut});
							FlxTween.tween(menuart, {y: 200}, 1.9, {ease: FlxEase.quartInOut});
							FlxTween.tween(magenta, {y: -120}, 1.9, {ease: FlxEase.quartInOut});
							// FlxTween.tween(bg, {alpha: 0}, 0.8, {ease: FlxEase.expoIn});
							// FlxTween.tween(magenta, {alpha: 0}, 0.8, {ease: FlxEase.expoIn});
							FlxTween.tween(spr, {x: -250, alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story_mode':
										//FlxG.sound.play(Paths.sound('cancelMenu'));
										MusicBeatState.switchState(new StoryMenuState());
									case 'freeplay':
										MusicBeatState.switchState(new EpicSelectorWOOO());
									//#if MODS_ALLOWED
									//case 'mods':
										//MusicBeatState.switchState(new ModsMenuState());
									//#end
									//case 'awards':
										//MusicBeatState.switchState(new AchievementsMenuState());
									case 'credits':
										if(ClientPrefs.language == "Spanish") MusicBeatState.switchState(new CreditsSpanishState());
										else MusicBeatState.switchState(new TestCredits());
									case 'options':
										if(ClientPrefs.language == "Spanish") {
										LoadingState.loadAndSwitchState(new options.SpanishOption());
										} else {
										LoadingState.loadAndSwitchState(new options.OptionsState());
									}
								}
							});
						}
					});
				}
			}
			#if desktop
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				FlxG.switchState(new MasterEditorMenu());
			}
			else if (FlxG.keys.justPressed.SIX || FlxG.keys.justPressed.NUMPADSIX)
			{
				MusicBeatState.switchState(new gamejolt.GameJoltLoginState());
			}
			#end
			else if (FlxG.keys.justPressed.EIGHT || FlxG.keys.justPressed.NUMPADEIGHT)
			{
				MusicBeatState.switchState(new AchievementsMenuState());
			}
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
				//spr.screenCenter(X);
		});
	}


	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				var add:Float = 0;
				if(menuItems.length > 4) {
					add = menuItems.length * 8;
				}
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);
				spr.centerOffsets();
			}
		});
	}

override function beatHit()
	{
		super.beatHit();
		if (curBeat % 4 == 0 && ClientPrefs.camZooms)
			FlxG.camera.zoom = 1.015;
	}
}
