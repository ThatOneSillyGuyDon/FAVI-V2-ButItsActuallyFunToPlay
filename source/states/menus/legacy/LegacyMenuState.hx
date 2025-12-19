package states.menus.legacy;

import flixel.input.keyboard.FlxKeyboard;
import flixel.input.keyboard.FlxKey;

import flixel.util.FlxTimer;
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
import flixel.input.keyboard.FlxKey;
import openfl.filters.ShaderFilter;

using StringTools;

//The menu that has an 8% chance of appearing

class LegacyMenuState extends MusicBeatState
{
	public static var MouseVersion:String = '2.5.0';
	public static var evilpsychEngineVersion:String = '0.7.3'; // always when i see this i say no same variable name cuz haxe being dumb
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	public var camFilter:FlxCamera;

	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		'credits',
		'options'
	];

	var birthdayCode:Array<Dynamic> = [
		[FlxKey.TWO, FlxKey.NUMPADTWO],
		[FlxKey.ONE, FlxKey.NUMPADONE],
		[FlxKey.ZERO, FlxKey.NUMPADZERO],
		[FlxKey.THREE, FlxKey.NUMPADTHREE],
		[FlxKey.TWO, FlxKey.NUMPADTWO],
		[FlxKey.TWO, FlxKey.NUMPADTWO]
	];
	var theBirthdayCode:Int = 0;

	var menuart:FlxSprite;
	var eyes:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	public static var firstStart:Bool = true;
	public static var finishedFunnyMove:Bool = false;

	var defaultShader:FlxRuntimeShader;
	var defaultShader2:FlxRuntimeShader;

	var howmuchyoufuckinkeptdoingit:Int = 0;

	var messenger:MessageBox;
	var windowShit:Array<Any> = [
		"Anyone up right now?",
		"Shipy's SNS Mickey & F.AVI Mickey would make love to each other",
		"We lied about Episode 2's release...",
		"I trapped don in my basement.",
		"Someone put an end to my misery.",
		"I dare you to press 7 on that keyboard of yours.",
		"Cock & ball torture.",
		"OKAY, YOU GOT DELUSIONAL, NOW STFU.",
		"Look at that cute little devil, he's cute :)",
		"Do you like the new menu art?",
		"You're gonna love the final song.",
		"Malfunction isn't easy anymore, fuck you, skill issue.",
			(GameData.birthdayLocky == 'beaten' || GameData.birthdayLocky == 'uninvited' /**<- this 2nd one is important otherwise it wont work**/) ? ("Happy Birthday Muckney!" + (GameData.birthdayLocky == 'uninvited' ? " Except for you, monster..." : "" /**nothing lol this is just to save some lines of code**/)) : "It's someone's birthday here!",
		"SOMEONE PLEASE GIVE MICKEY HIS FUCKING SANDVICH", // intentional misspell lolol
		"Have fun, you'll be here for like an hour or longer.",
		"10 Seconds before I shut your fucking game again >:[",
		"Oh the misery, everybody wants to be my enemy.",
		"Sex, NOW.",
		"Quick, hide behind that conveniently shaped lamp!",
		"Welcome to hell",
		"blue lobster *jumpscare*",
		"hi. *starts dancing on the floor*",
		"sample text 2: electric boogaloo",
		"The bastard named squidward cheated on poor mickey :[",
		"D E A T H",
		"Man i'm hungry",
		"Shit, the mouse got a gun again.",
		"You should /kill @s NOW", // haha, funi Minecraft reference
		"Why are you here? FNF is still cancelled.",
		"This community is fr the big stinky.",
		"Go ahead, cancel us, you'll only make us come back stronger.",
		"NOOOOOOOOOOO, YOU CAN'T JUST CHEAT THE GAME!!!!!!!",
		"Mom, can we have Wednesday's Infidelity?",
		"WHAT THE FUCK IS A KILOMETER?",
		"Don't leave Muckney's party, please, you'll make him sad if you do :(",
		"It's about drive, it's about power, we stay hungry, we devour.",
		"Peter, the horse is here.",
		"*horse walks in*",
		"When she Isolated on my Lunacy til I Delusional.",
		"Anyone here watch Yahiamice?",
		"*cantaloupe jumpscare*",
		"Prank 'em John",
		"POV: You're a YouTuber doing some generic intro right about now",
		"Another very well thought out idea of a random message that this game can randomly pick from within the code.",
		"AHHH, FUCK, THERE'S RULE 34 OF SUICIDE MOUSE, WHYYYYYY????",
		"Check out this cool rare little easter egg that I found, which I want to show to you but I can't cause I'm just a title screen message.",
		"There's still uranium in my ass, send help.",
		"Main Menu Music: Rotten Petals",
		"Mickey lost his ballsack.",
		"Oh the horror of AI generated images.",
		"You should [R] Reset Character NOW", // boblox reference
		"awesome mouse experience.",
		"This mod was stressful to make.",
		"Funkin.avi - Funkin.avi - Funkin.avi - Funkin.avi - Funkin.avi - Funkin.avi - Funkin.avi - Funkin.avi - Funkin.avi - Funkin.avi - Funkin.avi",
		"Just like Domingo is constantly remaking Mickey's sprites, Dreupy is the Domingo of Delusional Recharts.",
		"When did Funkin.avi start development?",
		"I think one of the codes is a certain date",
		"The idea of the mod was created on 21/03/22, pretty crazy, right?",
		"Everyday is Muckney's Birthday",
		"there is no message, go play some minecraft",
		"THEY HIT THE FUCKING PENTAGON",
		"Want a break from the ads? If you tap now to take a short servey, you'll recieve 30 minutes of ad-free music.",
		"I bet you're complaining that this isn't easy to steal assets from right about now, silly kiddo",
		"Development was so long Mickey died of waiting",
		"um um um um um um um",
		"uhuhuhuh",
		"This is actually the patch's exclusive message, hi to however found this message - malyplus",
		"women.",
		"men."
	];

	override function create()
	{
		Paths.clearUnusedMemory();

		Application.current.window.title = "Funkin.avi";

		FlxG.sound.music.fadeIn(0.5, 0, 1);
		FlxG.sound.playMusic(Paths.music('aviOST/alone'));

		AppIcon.changeIcon("legacyIcon");
		#if desktop
		DiscordClient.changePresence('Main Menu', 'Browsing...', 'icon', 'mouse');
		#end
		openfl.Lib.application.window.title = "Funkin.avi - " + windowShit[FlxG.random.int(0, windowShit.length - 1)];
		if (openfl.Lib.application.window.title.contains('10 Seconds before I shut your fucking game again >:('))
		{
			new flixel.util.FlxTimer().start(10, function(e)
			{
				Sys.exit(0);
			});
		}
		
		camGame = new FlxCamera();
		camFilter = new FlxCamera();
		camFilter.bgColor.alpha = 0;


		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camFilter);
		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);

		eyes = new FlxSprite().loadGraphic(Paths.image('Funkin_avi/menu/OLDmenu/HahaSadBoi'));
		eyes.scrollFactor.set(0, 0);
		eyes.screenCenter();
		eyes.updateHitbox();
		eyes.antialiasing = ClientPrefs.data.antialiasing;
		add(eyes);

		menuart = new FlxSprite().loadGraphic(Paths.image('Funkin_avi/menu/OLDmenu/newspaper'));
		menuart.scrollFactor.set(0, 0);
		//menuart.setGraphicSize(StdDaInt(menuart.width * 1.175));
		menuart.updateHitbox();
		menuart.screenCenter();
		menuart.antialiasing = ClientPrefs.data.antialiasing;
		add(menuart);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

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
			menuItem.frames = Paths.getSparrowAtlas('Funkin_avi/menu/OLDmenu/buttons/menu_' + optionShit[0]);
			menuItem.animation.addByPrefix('idle', optionShit[0] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[0] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = 0;
			//menuItem.screenCenter(X);
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 2) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.data.antialiasing;
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
			menuItem.frames = Paths.getSparrowAtlas('Funkin_avi/menu/OLDmenu/buttons/menu_' + optionShit[1]);
			menuItem.animation.addByPrefix('idle', optionShit[1] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[1] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = 1;
			//menuItem.screenCenter(X);
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 2) * 0.135;
			if(optionShit.length < 6) scr = 1;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.data.antialiasing;
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
			menuItem.frames = Paths.getSparrowAtlas('Funkin_avi/menu/OLDmenu/buttons/menu_' + optionShit[2]);
			menuItem.animation.addByPrefix('idle', optionShit[2] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[2] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = 2;
			//menuItem.screenCenter(X);
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 2) * 0.135;
			if(optionShit.length < 6) scr = 2;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.data.antialiasing;
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
			menuItem.frames = Paths.getSparrowAtlas('Funkin_avi/menu/OLDmenu/buttons/menu_' + optionShit[3]);
			menuItem.animation.addByPrefix('idle', optionShit[3] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[3] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = 3;
			//menuItem.screenCenter(X);
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 2) * 0.135;
			if(optionShit.length < 6) scr = 3;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.data.antialiasing;
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

		firstStart = false;

		FlxG.camera.follow(camFollowPos, null, 1);

		var versionShit:FlxText = new FlxText(12, FlxG.height - 84, 0, "Funkin.avi v" + MouseVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat(Paths.font("NewWaltDisneyFontRegular-BPen.ttf"), 22, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionShit.cameras = [camFilter];
		add(versionShit);

		var versionShit:FlxText = new FlxText(12, FlxG.height - 64, 0, "Psych Engine v" + evilpsychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat(Paths.font("NewWaltDisneyFontRegular-BPen.ttf"), 22, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionShit.cameras = [camFilter];
		add(versionShit);

		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat(Paths.font("NewWaltDisneyFontRegular-BPen.ttf"), 22, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionShit.cameras = [camFilter];
		add(versionShit);

		messenger = new MessageBox(-400, FlxG.height - 80, {
			text: 'Freeplay is Locked!', 
			subText: 'Complete Episode 1 to Unlock this Menu!',
			boxHeight: 90,
			boxWidth: 600,
			font: 'DisneyFont.ttf',
			camera: camFilter
		});
		add(messenger);

		changeItem();

		var scratchStuff:FlxSprite = new FlxSprite();
		scratchStuff.frames = Paths.getSparrowAtlas('Funkin_avi/filters/scratchShit');
		scratchStuff.animation.addByPrefix('idle', 'scratch thing 1', 24, true);
		scratchStuff.animation.play('idle');
		scratchStuff.screenCenter();
		scratchStuff.scale.x = 1.1;
		scratchStuff.scale.y = 1.1;
		add(scratchStuff);

		var grain:FlxSprite = new FlxSprite();
		grain.frames = Paths.getSparrowAtlas('Funkin_avi/filters/Grainshit');
		grain.animation.addByPrefix('idle', 'grains 1', 24, true);
		grain.animation.play('idle');
		grain.screenCenter();
		grain.scale.x = 1.1;
		grain.scale.y = 1.1;
		add(grain);

		scratchStuff.cameras = [camFilter];
		grain.cameras = [camFilter];

		super.create();

		defaultShader2 = new FlxRuntimeShader(Shaders.monitorFilter, null, 140);
		if(ClientPrefs.data.shaders)
		{
			FlxG.camera.setFilters(
			[
				new openfl.filters.ShaderFilter(defaultShader2)
			]);
		}
}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ANY)
		{
			var hitCorrectKey:Bool = false;
			var birthdayKey:Bool = false;
			for (b in 0...birthdayCode[theBirthdayCode].length)
				if (FlxG.keys.checkStatus(birthdayCode[theBirthdayCode][b], JUST_PRESSED))
					birthdayKey = true;
			if (birthdayKey && !selectedSomethin && GameData.birthdayLocky != "uninvited")
				if (theBirthdayCode == (birthdayCode.length - 1))
					if (GameData.birthdayLocky == "obtained" || GameData.birthdayLocky == "beaten")
					{
						FlxG.sound.play(Paths.sound('cancelMenu'));
						switch(howmuchyoufuckinkeptdoingit) {
							case 0: messenger.sendMessage('You\'ve already unlocked this song!', 'Go to freeplay to play the song.');
							case 1: messenger.sendMessage('Can\'t you understand?', 'You already unlocked the song.');
							case 2: messenger.sendMessage('Can\'t you read?', 'This. Is. Already. Unlocked.');
							case 3: messenger.sendMessage('go to freeplay menu.', 'its already unlocked.');
							case 4: messenger.sendMessage('IF YOU KEEP DOING IT THEN', 'IM GONNA DO SOMETHING BAD');
							case 5:
								messenger.sendMessage('...', 'Im closing the game. Fuck you');
								new FlxTimer().start(2, function(tmr:FlxTimer){
									System.exit(0);
								});
						}
						howmuchyoufuckinkeptdoingit++;
					}
					else
					{
						GameData.birthdayLocky = 'obtained';
						FlxG.sound.play(Paths.sound('funkinAVI/easterEggSound'));
						messenger.sendMessage('Something has unlocked!', 'Check freeplay to see what has been unlocked.');
					}
				else
					theBirthdayCode++;
			else
			{
				theBirthdayCode = 0;
				for (b in 0...birthdayCode[0].length)
					if (FlxG.keys.checkStatus(birthdayCode[0][b], JUST_PRESSED))
						theBirthdayCode = 1;
			}
			if (theBirthdayCode == 3)
				FlxG.sound.muteKeys = null;
			else
				FlxG.sound.muteKeys = [FlxKey.ZERO, FlxKey.NUMPADZERO];
		}
		
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!sys.FileSystem.exists('./assets/shared/images/favi/stages/forbiddenRealm/DO NOT TOUCH MY MEME.png') && GameData.check(NO_MALFUNCTION))
		{
			selectedSomethin = true;
			new FlxTimer().start(0.4, function(tmr:FlxTimer)
			{
				selectedSomethin = false;
			});
			FlxG.sound.play(Paths.sound('funkinAVI/easterEggSound'));
			messenger.sendMessage('I just wanna talk bro.', 'New Freeplay Song Unlocked!');
			GameData.canAddMalfunction = true;
			GameData.saveShit();
		}

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
				Conductor.bpm = (50); // changes back to titlescreen bpm
				FlxG.sound.playMusic(Paths.music('aviOST/rottenPetals'), 1); // resets music back to menu music
				FlxG.sound.music.fadeIn();
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('funkinAVI/menu/selectSfx'));

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							// Main Menu Select Animations
							FlxTween.tween(FlxG.camera, {zoom: 1.15}, 2, {ease: FlxEase.quartInOut});
							FlxTween.tween(menuart, {x: -170}, 2.2, {ease: FlxEase.quartInOut});
							FlxTween.tween(menuart, {y: 200}, 1.9, {ease: FlxEase.quartInOut});
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
										FlxG.mouse.visible = false;
										MusicBeatState.switchState(new StoryMenuState());
										Conductor.bpm = (50); // changes back to titlescreen bpm
										FlxG.sound.playMusic(Paths.music('aviOST/rottenPetals'), 1); // resets music back to menu music
										FlxG.sound.music.fadeIn();
									case 'freeplay':
										MusicBeatState.switchState(new GeneralMenu());
										FlxG.sound.music.fadeIn(0.5, 0, 1);
										FlxG.sound.playMusic(Paths.music('aviOST/seekingFreedom'));
									case 'credits':
										FlxG.sound.music.fadeIn(0.5, 0, 1);
										FlxG.sound.playMusic(Paths.music('aviOST/curtainCall'));
										MusicBeatState.switchState(new CreditsState());
									case 'options':
										Conductor.bpm = (50); // changes back to titlescreen bpm
										FlxG.sound.playMusic(Paths.music('aviOST/rottenPetals'), 1); // resets music back to menu music
										FlxG.sound.music.fadeIn();
										LoadingState.loadAndSwitchState(new states.options.OptionsState());
										states.options.OptionsState.onPlayState = false;
										if (PlayState.SONG != null)
										{
											PlayState.SONG.arrowSkin = null;
											PlayState.SONG.splashSkin = null;
											PlayState.stageUI = 'normal';
										}
								}
							});
						}
					});
				}
			}

			if (FlxG.keys.justPressed.SEVEN)
			{
				if (Main.debug)
				{
					Conductor.bpm = (50); // changes back to titlescreen bpm
					FlxG.sound.playMusic(Paths.music('aviOST/rottenPetals'), 1); // resets music back to menu music
					FlxG.sound.music.fadeIn();
					MusicBeatState.switchState(new MasterEditorMenu());
				}
				else
				{
					FlxG.sound.play(Paths.sound('cancelMenu'));
					messenger.sendMessage('ACCESS DENIED!', 'Perhaps there is a code to access this?');
				}
			}
			if (Main.debug)
			{
				if (FlxG.keys.justPressed.ONE) // Unlocks EVERYTHING
				{
					GameData.unlockEverything();
					FlxG.sound.play(Paths.sound('funkinAVI/easterEggSound'));
				}
				if (FlxG.keys.justPressed.TWO) // Unlocks Freeplay Access for Testing
				{
					FlxG.sound.play(Paths.sound('funkinAVI/easterEggSound'));
					GameData.episode1FPLock = "unlocked";
					GameData.saveShit();
				}
				if (FlxG.keys.justPressed.THREE) // Dev Shortcut to Mania Menu
				{
					FlxG.sound.playMusic(Paths.music('aviOST/seekingFreedom'));
					FreeplayState.freeplayMenuList = 3;
					MusicBeatState.switchState(new FreeplayState());
				}
			}
		}

		super.update(elapsed);
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
}
