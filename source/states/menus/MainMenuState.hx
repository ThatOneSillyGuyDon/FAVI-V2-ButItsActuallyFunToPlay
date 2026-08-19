package states.menus;

import lime.ui.MouseCursor;
import openfl.ui.Mouse;
import openfl.events.MouseEvent;
import flixel.addons.transition.FlxTransitionableState;
import lime.app.Application;
import flash.system.System;
import flixel.effects.FlxFlicker;

import flixel.input.keyboard.FlxKey;

class MainMenuState extends MusicBeatState
{
	var camGame:FlxCamera;
	var camHUD:FlxCamera;
	public static var selectedSomethin:Bool = false;
	var menuItems:FlxTypedGroup<FlxSprite>;
	var optionShit:Array<String> = ['story', 'freeplay', 'settings', 'credits', 'discordIcon', 'changelog', 'reset', 'book'];
	public static var curSelected:Int = 0;
	
	var miniBtnScale:Array<Float> = [1.0, 1.0, 1.0];
	var birthdayCode:Array<Dynamic> = [
		[FlxKey.TWO, FlxKey.NUMPADTWO],
		[FlxKey.ONE, FlxKey.NUMPADONE],
		[FlxKey.ZERO, FlxKey.NUMPADZERO],
		[FlxKey.THREE, FlxKey.NUMPADTHREE],
		[FlxKey.TWO, FlxKey.NUMPADTWO],
		[FlxKey.TWO, FlxKey.NUMPADTWO]
	];
	var theBirthdayCode:Int = 0;
	var howmuchyoufuckinkeptdoingit:Int = 0;
	var messenger:MessageBox;
	var debugKeys:Array<FlxKey>;
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
		"men.",
		"Blame Goober for making me delusional",
		"Fun fact: away3d is a library that makes our mod work, deleting it would result on us not being to compile no more" // change if needed.
	];

	override function create()
	{
		Paths.clearUnusedMemory();

		camGame = new FlxCamera(); // Main camera for objects and stuff
		camHUD = new FlxCamera(); // for the grain effect and etc
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		selectedSomethin = false;

		AppIcon.changeIcon("newIcon");
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

		//debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));
		/*transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;*/
		persistentUpdate = persistentDraw = true;

		var bg = new FlxSprite().loadGraphic(Paths.image('Funkin_avi/menu/NEWmenu/Background'));
		bg.setGraphicSize(0, FlxG.height);
		bg.updateHitbox();
		bg.screenCenter();
		bg.scrollFactor.set(0, 0);
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);

		if (!ClientPrefs.data.lowQuality)
		{
			var gradient = new FlxSprite().loadGraphic(Paths.image('Funkin_avi/filters/gradient'));
			gradient.setGraphicSize(Std.int(gradient.width * 0.78));
			gradient.x -= 5;
			var vig = new FlxSprite().loadGraphic(Paths.image('Funkin_avi/menu/NEWmenu/FrameScreenBlur'));
			vig.setGraphicSize(0, FlxG.height);

			for (obj in [gradient, vig])
			{
				obj.scrollFactor.set(0, 0);
				obj.updateHitbox();
				obj.screenCenter();
				obj.antialiasing = ClientPrefs.data.antialiasing;
				add(obj);
			}
		}

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);
		for (i in 0...optionShit.length)
		{
			var menuItem = new FlxSprite();
			menuItem.ID = i;
			switch (menuItem.ID)
			{
				case 0 | 1 | 2 | 3: //story mode, freeplay, settings, credits
					menuItem.frames = Paths.getSparrowAtlas("Funkin_avi/menu/NEWmenu/BUTTONS/" + optionShit[i]);
					menuItem.animation.addByPrefix("idle", optionShit[i] + " idle", 24, true);
					menuItem.animation.addByPrefix("selected", optionShit[i] + " selected", 24, true);
					menuItem.animation.addByPrefix("hovered", optionShit[i] + " hovered", 24, true);
					menuItem.animation.play("idle");
					menuItem.scale.set(1, 1);
					switch (menuItem.ID)
					{
						case 0:
							menuItem.offset.x = -50;
							menuItem.setPosition(725, 190);
							menuItem.width *= 6.5;
						case 1: // freeplay
							if (GameData.episode1FPLock != "unlocked") menuItem.color = FlxColor.fromHSL(menuItem.color.hue, menuItem.color.saturation, 0.2, 1);
							menuItem.offset.x = -60;
							menuItem.setPosition(720, 270);
							menuItem.width *= 5;
						case 2:
							menuItem.offset.x = -70;
							menuItem.setPosition(715, 380);
							menuItem.width *= 5;
						case 3:
							menuItem.offset.x = -80;
							menuItem.setPosition(705, 485);
							menuItem.width *= 4;
					}
				case 4 | 5 | 6: // discord, changelog, reset save data
					menuItem.loadGraphic(Paths.image('Funkin_avi/menu/NEWmenu/BUTTONS/' + optionShit[i]));
					menuItem.scale.set(0.14, 0.14);
					menuItem.offset.x = 0;
					switch (menuItem.ID)
					{
						case 4:
							menuItem.x = 1070;
						case 5:
							menuItem.x = 980;
						case 6:
							menuItem.x = 860;
					}
					menuItem.y = 610;
					menuItem.updateHitbox();
				case 7: // book
					menuItem.frames = Paths.getSparrowAtlas("Funkin_avi/menu/NEWmenu/BUTTONS/book");
					menuItem.animation.addByPrefix("idle", "idle", 24, true);
					menuItem.animation.addByPrefix("hovered", "hovered", 24, true);
					menuItem.animation.play("idle");
					menuItem.scale.set(1, 1);
					menuItem.offset.x = 0;
					menuItem.setPosition(120, 300);
				case 8:
					menuItem.frames = Paths.getSparrowAtlas("Funkin_avi/menu/NEWmenu/BUTTONS/jaysun");
					menuItem.animation.addByPrefix("idle", optionShit[i] + " idle", 24, true);
					menuItem.animation.addByPrefix("selected", optionShit[i] + " selected", 24, true);
					menuItem.animation.addByPrefix("hovered", optionShit[i] + " hovered", 24, true);
					menuItem.animation.play("idle");
					menuItem.color = FlxColor.fromHSL(menuItem.color.hue, menuItem.color.saturation, 0.2, 1);
					menuItem.scale.set(1, 1);
					menuItem.setPosition(1200, 650);
			}
			menuItems.add(menuItem);
			
			menuItem.antialiasing = ClientPrefs.data.antialiasing;
		}

		messenger = new MessageBox(-400, FlxG.height - 80, {
			text: 'Freeplay is Locked!', 
			subText: 'Complete Episode 1 to Unlock this Menu!',
			boxHeight: 90,
			boxWidth: 600,
			font: 'DisneyFont.ttf',
			camera: camHUD
		});
		add(messenger);

		if (!ClientPrefs.data.lowQuality)
		{
			var scratchStuff = new FlxSprite();
			scratchStuff.frames = Paths.getSparrowAtlas('Funkin_avi/filters/scratchShit');
			scratchStuff.animation.addByPrefix('idle', 'scratch thing 1', 24, true);
			scratchStuff.animation.play('idle');
			var grain = new FlxSprite();
			grain.frames = Paths.getSparrowAtlas('Funkin_avi/filters/Grainshit');
			grain.animation.addByPrefix('idle', 'grains 1', 24, true);
			grain.animation.play('idle');

			for (filter in [scratchStuff, grain])
			{
				filter.screenCenter();
				filter.scale.set(1.1, 1.1);
				filter.cameras = [camHUD];
				add(filter);
			}
		}
		if (FlxG.stage.window.title.contains('*cantaloupe jumpscare*'))
			coolMenuEvents(4);

		FlxG.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);

		changeSelection(0);
		super.create();

		FlxG.mouse.load(Paths.image('favi/ui/Cursor').bitmap);

		if (!FlxG.mouse.visible)
			FlxG.mouse.visible = true;
	}

	var goingToBrainrot:Bool = false;
	override function update(elapsed:Float)
	{
		miniBtnScale = [
			(FlxG.mouse.overlaps(menuItems.members[4])) ? .165 : .14,
			(FlxG.mouse.overlaps(menuItems.members[5])) ? .165 : .14,
			(FlxG.mouse.overlaps(menuItems.members[6])) ? .165 : .14
		];

		menuItems.forEach(function(spr:FlxSprite)
		{
			switch (spr.ID)
			{
				case 4: spr.scale.set(FlxMath.lerp(miniBtnScale[0], spr.scale.x, CoolUtil.boundTo(1 - (elapsed * 7.4), 0, 1)), FlxMath.lerp(miniBtnScale[0], spr.scale.y, CoolUtil.boundTo(1 - (elapsed * 7.4), 0, 1)));
				case 5: spr.scale.set(FlxMath.lerp(miniBtnScale[1], spr.scale.x, CoolUtil.boundTo(1 - (elapsed * 7.4), 0, 1)), FlxMath.lerp(miniBtnScale[1], spr.scale.y, CoolUtil.boundTo(1 - (elapsed * 7.4), 0, 1)));
				case 6: spr.scale.set(FlxMath.lerp(miniBtnScale[2], spr.scale.x, CoolUtil.boundTo(1 - (elapsed * 7.4), 0, 1)), FlxMath.lerp(miniBtnScale[2], spr.scale.y, CoolUtil.boundTo(1 - (elapsed * 7.4), 0, 1)));
			}
		});

		if (!sys.FileSystem.exists('./assets/shared/images/favi/stages/forbiddenRealm/DO NOT TOUCH MY MEME.png') && GameData.check(NO_MALFUNCTION))
			coolMenuEvents(2);

		if (FlxG.keys.justPressed.R)
			coolMenuEvents(1);

		if (FlxG.keys.justPressed.ANY)
		{
			var hitCorrectKey:Bool = false;
			var birthdayKey:Bool = false;
			for (b in 0...birthdayCode[theBirthdayCode].length)
				if (FlxG.keys.checkStatus(birthdayCode[theBirthdayCode][b], JUST_PRESSED))
					birthdayKey = true;
			if (birthdayKey && !selectedSomethin && GameData.birthdayLocky != "uninvited")
				if (theBirthdayCode == (birthdayCode.length - 1))
					coolMenuEvents(5);
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

		if (!goingToBrainrot)
		{
			if (FlxG.sound.music.volume < 0.8)
				FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (!selectedSomethin)
		{
			if (FlxG.mouse.justMoved)
			{
				for (i in 0...menuItems.length)
				{
					if (FlxG.mouse.overlaps(menuItems.members[i]) || (FlxG.mouse.overlaps(menuItems.members[curSelected]) && menuItems.members[curSelected].alpha == 0.45))
						changeSelection(i);
					else if (!FlxG.mouse.overlaps(menuItems.members[i]))
					{
						switch (i)
						{
							case 0 | 1 | 2 | 3 | 7 | 8:
								menuItems.members[i].animation.play("idle");
							default:
								menuItems.members[i].color = FlxColor.WHITE;
								menuItems.members[i].alpha = 0.45;
						}
					}
				}
			}
				
			if (FlxG.mouse.overlaps(menuItems.members[curSelected]) && FlxG.mouse.justPressed)
					enterSelection();
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
			if (FlxG.keys.justPressed.FOUR)
			{
				//goingToBrainrot = true;
				MusicBeatState.switchState(new AskQuestionToThatGuy());
				//FlxG.sound.music.fadeOut(0.5);
			}	
			if (FlxG.keys.justPressed.SEVEN)
			{
				if (Main.debug)
					MusicBeatState.switchState(new MasterEditorMenu());
				else {
					FlxG.sound.play(Paths.sound('cancelMenu'));
					messenger.sendMessage('ACCESS DENIED!', 'Perhaps there is a code to access this?');
				}
			}
			if (FlxG.keys.justPressed.EIGHT)
			{
				MusicBeatState.switchState(new CutsceneState());
			}
			if (FlxG.keys.justPressed.NINE)
			{
				goingToBrainrot = true;
				MusicBeatState.switchState(new Brainrot());
				FlxG.sound.music.fadeOut(0.5);
			}	
			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}
		}
		super.update(elapsed);
	}

	override function destroy() {
		super.destroy();

		FlxG.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
	}

	function changeSelection(selection:Int)
	{
		if (selection != curSelected)
			FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'));

		if (selection < 0)
			selection = menuItems.length - 1;
		if (selection >= menuItems.length)
			selection = 0;
		curSelected = selection;

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = menuItems.members[i];
			if (i == selection)
			{
				switch (i)
				{
					case 0 | 1 | 2 | 3 | 7 | 8:
						menuItem.animation.play("hovered");
					default:
						menuItem.color = FlxColor.RED;
						menuItem.alpha = 1.0;
				}
			}
			else
			{
				switch (i)
				{
					case 0 | 1 | 2 | 3 | 7 | 8:
						menuItem.animation.play("idle");
					default:
						menuItem.color = FlxColor.WHITE;
						menuItem.alpha = 0.45;
				}
			}
		}
		curSelected = selection;
	}

	var flashValue:Float = 0.1;
	function enterSelection()
	{
		var daChoice:String = optionShit[curSelected];
		if (ClientPrefs.data.flashing)
			flashValue = 0.2;

		if (daChoice == "freeplay")
			coolMenuEvents(7);
		else if (daChoice == "credits")
			coolMenuEvents(8);
		else if (daChoice == "book")
		{
			if (GameData.malfunctionLock == "unlocked" || GameData.malfunctionLock == "beaten")
				coolMenuEvents(3);
			else
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				messenger.sendMessage('You haven\'t unlocked this yet!', 'Complete EVERYTHING to open this book.');
			}	
		}
		else if (daChoice == "discordIcon")
			CoolUtil.browserLoad('https://discord.gg/qTZYpP4hg3');
		else if (daChoice == "reset")
			coolMenuEvents(6);
		else if (daChoice == "changelog")
			coolMenuEvents(9);
		else if (daChoice == "jaysun")
			coolMenuEvents(10);
		else
		{
			if (!selectedSomethin)
			{
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					goToState(daChoice);
				});
			}
			for (sillies in [menuItems.members[curSelected]])
			{
				if (sillies != null)
				{
					sillies.animation.play("selected");
					sillies.setColorTransform(1, 1, 1, 1, 255, 0, 0, 0);
					FlxTween.tween(sillies.colorTransform, {redOffset: 0}, 1);
				}
			}
			FlxG.sound.play(Paths.sound('funkinAVI/menu/selectSfx'));
			selectedSomethin = true;
			FlxG.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
	}

	function goToState(name:String)
	{
		switch (name)
		{
			case 'story':
				FlxG.mouse.visible = false;
				MusicBeatState.switchState(new StoryMenuState());
			case 'settings':
				LoadingState.loadAndSwitchState(new OptionsState());
				OptionsState.onPlayState = false;
				if (PlayState.SONG != null)
				{
					PlayState.SONG.arrowSkin = null;
					PlayState.SONG.splashSkin = null;
					PlayState.stageUI = 'normal';
				}
		}
	}

	function coolMenuEvents(getEvent:Int)
	{
		switch (getEvent)
		{
			case 1:
				var redGradient:FlxSprite = new FlxSprite(0, 0, Paths.image('Funkin_avi/filters/redGradient'));
				redGradient.setGraphicSize(Std.int(redGradient.width * 0.7));
				redGradient.screenCenter();
				redGradient.cameras = [camHUD];
				FlxTween.tween(redGradient, {alpha: 0}, 0.9, {onComplete: sex -> redGradient.destroy()});
				add(redGradient);
				FlxG.sound.play(Paths.sound('funkinAVI/oof'), 1, false, null, true);
			case 2:
				selectedSomethin = true;
				new FlxTimer().start(0.4, function(tmr:FlxTimer)
				{
					selectedSomethin = false;
				});
				FlxG.sound.play(Paths.sound('funkinAVI/easterEggSound'));
				messenger.sendMessage('I just wanna talk bro.', 'New Freeplay Song Unlocked!');

				GameData.canAddMalfunction = true;
				GameData.saveShit();
			case 3:
				menuItems.members[7].setColorTransform(1, 1, 1, 1, 255, 255, 255, 255);
				FlxTween.tween(menuItems.members[7].colorTransform, {redOffset: 0, greenOffset: 0, blueOffset: 0}, 1);
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('funkinAVI/menu/selectSfx'));
				
				new FlxTimer().start(.6, s -> MusicBeatState.switchState(new states.menus.CharacterMenu()));
			case 4:
				var cantaloupe = new FlxSprite(-200, -100).loadGraphic(Paths.image('Funkin_avi/cantaloupe'));
				cantaloupe.scale.set(0.05, 0.05);
				cantaloupe.screenCenter();
				FlxTween.tween(cantaloupe.scale, {x: 2, y: 2}, 3, {ease: FlxEase.bounceOut, onComplete: _ -> FlxTween.tween(cantaloupe, {alpha: 0}, 2)});
				cantaloupe.shake(.05, 0, 5);
				add(cantaloupe);
				FlxG.camera.shake(0.02, 5);
				FlxG.sound.play(Paths.sound('funkinAVI/fnaf_jumpscare'), 0.7, false, null, true, () -> cantaloupe.destroy());
			case 5:
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
			case 6:
				selectedSomethin = true;
				openSubState(new ResetSaveDataSubState());
			case 7:
				if (GameData.episode1FPLock == "unlocked")
				{
					FlxG.sound.music.fadeOut(0.8);
					menuItems.forEach(function(spr:FlxSprite)
					{
						if (spr.ID == curSelected)
						{
							new FlxTimer().start(1, function(tmr:FlxTimer)
							{
								MusicBeatState.switchState(new GeneralMenu());
								FlxG.sound.music.fadeIn(0.5, 0, 1);
								FlxG.sound.playMusic(Paths.music('aviOST/seekingFreedom'));
							});
						}
					});
					for (sillies in [menuItems.members[curSelected]])
					{
						if (sillies != null)
						{
							sillies.animation.play("selected");
							sillies.setColorTransform(1, 1, 1, 1, 255, 0, 0, 0);
							FlxTween.tween(sillies.colorTransform, {redOffset: 0}, 1);
						}
					}
					FlxG.sound.play(Paths.sound('funkinAVI/menu/selectSfx'));
					selectedSomethin = true;
					FlxG.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
				}
				else
				{
					FlxG.sound.play(Paths.sound('cancelMenu'));
					messenger.sendMessage('Freeplay is locked!', 'Complete Episode 1 to Unlock this menu.');
				}
			case 8:
				FlxG.sound.music.fadeOut(0.8);
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					FlxG.sound.music.fadeIn(0.5, 0, 1);
					FlxG.sound.playMusic(Paths.music('aviOST/curtainCall'));
					MusicBeatState.switchState(new CreditsState());
				});

				for (sillies in [menuItems.members[curSelected]])
				{
					if (sillies != null)
					{
						sillies.animation.play("selected");
						sillies.setColorTransform(1, 1, 1, 1, 255, 0, 0, 0);
						FlxTween.tween(sillies.colorTransform, {redOffset: 0}, 1);
					}
				}
				FlxG.sound.play(Paths.sound('funkinAVI/menu/selectSfx'));
				selectedSomethin = true;
				FlxG.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			case 9:
				selectedSomethin = true;
				openSubState(new ChangelogMenu());
			case 10:
				FlxG.sound.music.fadeOut(3);
				FlxG.camera.fade();
				FlxTween.tween(camGame, {y: -300}, 2, {ease: FlxEase.sineInOut, onComplete: function(twn:FlxTween) {
					MusicBeatState.switchState(new states.menus.AskQuestionToThatGuy());
				}});

				for (sillies in [menuItems.members[curSelected]])
				{
					if (sillies != null)
					{
						sillies.animation.play("selected");
						sillies.setColorTransform(1, 1, 1, 1, 255, 0, 0, 0);
						FlxTween.tween(sillies.colorTransform, {redOffset: 0}, 1);
					}
				}
				FlxG.sound.play(Paths.sound('funkinAVI/easterEggSound'));
				selectedSomethin = true;
				FlxG.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
	}

	function onMouseMove(r)
	{
		for (items in menuItems)
			if (FlxG.mouse.overlaps(items))
			{
				Mouse.cursor = BUTTON;
				return;
			}
		Mouse.cursor = AUTO;
	}
}
