package states.menus;

import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import flash.system.System;
import flixel.input.keyboard.FlxKey;

class MainMenuState extends MusicBeatState
{
	var camGame:FlxCamera;
	var camHUD:FlxCamera;

	var selectedSomethin:Bool = false;
	var menuItems:FlxTypedGroup<FlxSprite>;
	var optionShit:Array<String> = ['story_mode', 'freeplay', 'credits', 'options'];
	public static var curSelected:Int = 0;

	var arrow:FlxSprite;
	var arrowX:Float = 0;
	var arrowY:Float = 0;

	var discordButton:FlxSprite;
	var datBook:FlxSprite;
	var evilAndFuckedUpBookScale = 1.0;
	var discordScale = 1.0;

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

		camGame = new FlxCamera(); // Main camera for objects and stuff
		camHUD = new FlxCamera(); // for the grain effect and etc
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		#if desktop
		DiscordClient.changePresence('Main Menu', 'Browsing...', 'icon', 'mouse');
		#end
		FlxG.mouse.load(Paths.image('UI/funkinAVI/mouses/Hand').bitmap);
		if (!FlxG.mouse.visible) FlxG.mouse.visible = true;
		openfl.Lib.application.window.title = "Funkin.avi - " + windowShit[FlxG.random.int(0, windowShit.length - 1)];
		if (openfl.Lib.application.window.title.contains('10 Seconds before I shut your fucking game again >:('))
		{
			new flixel.util.FlxTimer().start(10, function(e)
			{
				Sys.exit(0);
			});
		}

		//debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;
		persistentUpdate = persistentDraw = true;

		var bg = new FlxSprite().loadGraphic(Paths.image('Funkin_avi/menu/menuBG'));
		bg.setGraphicSize(0, FlxG.height);
		bg.updateHitbox();
		bg.screenCenter();
		datBook = new FlxSprite().loadGraphic(Paths.image('Funkin_avi/menu/book'));
		datBook.screenCenter().x -= 220;
		discordButton = new FlxSprite(1120, 610).loadGraphic(Paths.image("Funkin_avi/menu/discordIcon"));
		discordButton.scale.set(0.14, 0.14);
		discordButton.updateHitbox();

		for (obj in [bg, datBook, discordButton])
		{
			obj.scrollFactor.set(0, 0);
			obj.antialiasing = ClientPrefs.globalAntialiasing;
			add(obj);
		}

		if (!ClientPrefs.lowQuality)
		{
			arrow = new FlxSprite().loadGraphic(Paths.image('Funkin_avi/menu/menuArrow'));
			var gradient = new FlxSprite().loadGraphic(Paths.image('Funkin_avi/filters/gradient'));
			gradient.setGraphicSize(Std.int(gradient.width * 0.78));
			gradient.x -= 5;
			var vig = new FlxSprite().loadGraphic(Paths.image('Funkin_avi/menu/vignette'));
			vig.setGraphicSize(0, FlxG.height);

			for (obj in [arrow, gradient, vig])
			{
				obj.scrollFactor.set(0, 0);
				obj.updateHitbox();
				obj.screenCenter();
				obj.antialiasing = ClientPrefs.globalAntialiasing;
				add(obj);
			}
		}

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);
		for (i in 0...optionShit.length)
		{
			var offset = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem = new FlxSprite(0, (i * 100) + offset);
			menuItem.scale.set(0.6, 0.6);
			menuItem.updateHitbox();
			menuItem.loadGraphic(Paths.image('Funkin_avi/menu/buttons/' + optionShit[i]));
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItem.x += 460;
			menuItems.add(menuItem);
			var scr = (optionShit.length - 4) * 0.135;
			menuItem.scrollFactor.set(0, 0);
			switch (menuItem.ID)
			{
				case 0:
					menuItem.y = 130;
				case 1:
					if (GameData.episode1FPLock != "unlocked") menuItem.loadGraphic(Paths.image('Funkin_avi/menu/buttons/freeplayLocked'));
					menuItem.x += 25;
					menuItem.y = 240;
				case 2:
					menuItem.x += 50;
					menuItem.y = 350;
				case 3:
					menuItem.x += 75;
					menuItem.y = 460;
			}
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			menuItem.updateHitbox();
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

		if (!ClientPrefs.lowQuality)
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

		changeSelection(0);
		super.create();
	}

	override function update(elapsed:Float)
	{
		evilAndFuckedUpBookScale = (FlxG.mouse.overlaps(datBook) && !FlxG.mouse.overlaps(menuItems.members[curSelected])) ? 1.1 : 1;
		discordScale = (FlxG.mouse.overlaps(discordButton)) ? .165 : .14;

		datBook.scale.set(FlxMath.lerp(evilAndFuckedUpBookScale, datBook.scale.x, CoolUtil.boundTo(1 - (elapsed * 9.6), 0, 1)), FlxMath.lerp(evilAndFuckedUpBookScale, datBook.scale.x, CoolUtil.boundTo(1 - (elapsed * 9.6), 0, 1)));
		if (arrow != null) arrow.setPosition(FlxMath.lerp(arrowX, arrow.x, CoolUtil.boundTo(1 - (elapsed * 15), 0, 1)), FlxMath.lerp(arrowY, arrow.y, CoolUtil.boundTo(1 - (elapsed * 15), 0, 1)));
		for (i in 0...menuItems.length) menuItems.members[i].scale.set(FlxMath.lerp(.6, menuItems.members[i].scale.x, CoolUtil.boundTo(1 - (elapsed * 9.6), 0, 1)), FlxMath.lerp(.6, menuItems.members[i].scale.y, CoolUtil.boundTo(1 - (elapsed * 9.6), 0, 1)));
		discordButton.scale.set(FlxMath.lerp(discordScale, discordButton.scale.x, CoolUtil.boundTo(1 - (elapsed * 7.4), 0, 1)), FlxMath.lerp(discordScale, discordButton.scale.y, CoolUtil.boundTo(1 - (elapsed * 7.4), 0, 1)));

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

		if (FlxG.sound.music.volume < 0.8)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		if (!selectedSomethin)
		{
			if (FlxG.mouse.justMoved)
				for (i in 0...menuItems.length)
					if (i != curSelected)
						if (FlxG.mouse.overlaps(menuItems.members[i]) && !FlxG.mouse.overlaps(menuItems.members[curSelected]))
							changeSelection(i);
			if ((FlxG.mouse.overlaps(datBook) && !FlxG.mouse.overlaps(menuItems.members[curSelected])) && FlxG.mouse.justPressed)
				if (GameData.malfunctionLock == "unlocked" || GameData.malfunctionLock == "beaten")
					coolMenuEvents(3);
				else
				{
					FlxG.sound.play(Paths.sound('cancelMenu'));
					messenger.sendMessage('You haven\'t unlocked this yet!', 'Complete EVERYTHING to open this book.');
				}	
			if (FlxG.mouse.overlaps(discordButton) && FlxG.mouse.justPressed)
				CoolUtil.browserLoad('https://discord.gg/qTZYpP4hg3');	
			if (FlxG.mouse.justPressed && !selectedSomethin)
				if (FlxG.mouse.overlaps(menuItems.members[curSelected]))
					enterSelection();
			if (FlxG.keys.justPressed.SEVEN)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				messenger.sendMessage('Sorry, debug access is not allowed!', 'We will open it back up in a later update however...');
			}	
			if (FlxG.keys.justPressed.ONE && Main.debug)
			{
				GameData.unlockEverything();
				FlxG.sound.play(Paths.sound('funkinAVI/easterEggSound'));
			}		
			if (FlxG.keys.justPressed.TWO && Main.debug)
			{
				GameData.episode1FPLock = "unlocked";
				GameData.saveShit();
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

	function changeSelection(selection:Int)
	{
		if (selection != curSelected)
			FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'));
	
		if (selection < 0)
			selection = menuItems.length - 1;
		if (selection >= menuItems.length)
			selection = 0;
		curSelected = selection;

		if (arrow != null && !selectedSomethin)
		{
			switch (curSelected)
			{
				case 0:
					arrowX = 560;
					arrowY = 155;
				case 1:
					arrowX = 690;
					arrowY = 255;
				case 2:
					arrowX = 730;
					arrowY = 360;
				case 3:
					arrowX = 740;
					arrowY = 470;
			}
		}
	
		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = menuItems.members[i];
			if (i == selection)
			{
				menuItem.color = FlxColor.RED;
				menuItem.alpha = 1.0;
			}
			else
			{
				menuItem.color = FlxColor.WHITE;
				menuItem.alpha = 0.45;
			}
		}
		curSelected = selection;
	}

	function enterSelection()
	{
		var daChoice:String = optionShit[Math.floor(curSelected)];
		var flashValue:Float = 0.1;
		if (ClientPrefs.flashing)
			flashValue = 0.2;

		menuItems.members[curSelected].scale.set(.75, .75);
		for (sillies in [arrow, menuItems.members[Math.floor(curSelected)]])
		{
			if (sillies != null)
			{
				sillies.setColorTransform(1, 1, 1, 1, 255, 255, 255, 255);
				FlxTween.tween(sillies.colorTransform, {redOffset: 0, greenOffset: 0, blueOffset: 0}, 1);
			}
		}
		FlxG.sound.play(Paths.sound('funkinAVI/menu/selectSfx'));

		if (daChoice == "freeplay")
		{
			if (GameData.episode1FPLock == "unlocked")
			{
				FlxG.sound.music.fadeOut(0.8);
				menuItems.forEach(function(spr:FlxSprite)
				{
					if (curSelected != spr.ID)
					{
						FlxTween.tween(spr, {x: spr.x + 250, alpha: 0}, 0.4, {
							ease: FlxEase.quadOut,
							onComplete: function(twn:FlxTween)
							{
								spr.kill();
							}
						});
					}
					else
					{
						FlxFlicker.flicker(spr, 1, flashValue, false, false, function(flick:FlxFlicker)
						{
							MusicBeatState.switchState(new GeneralMenu());
							FlxG.sound.music.fadeIn(0.5, 0, 1);
							FlxG.sound.playMusic(Paths.music('aviOST/seekingFreedom'));
						});
					}
				});
			}
			else
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				messenger.sendMessage('Freeplay is locked!', 'Complete Episode 1 to Unlock this menu.');
			}
		}
		else
		{
			menuItems.forEach(function(spr:FlxSprite)
			{
				if (curSelected != spr.ID)
				{
					FlxTween.tween(spr, {x: spr.x + 250, alpha: 0}, 0.4, {
						ease: FlxEase.quadOut,
						onComplete: function(twn:FlxTween)
						{
							spr.kill();
						}
					});
				}
				else
				{
					if (!selectedSomethin)
					{
						FlxFlicker.flicker(spr, 1, flashValue, false, false, function(flick:FlxFlicker)
						{
							switch (daChoice)
							{
								case 'story_mode':
									FlxG.mouse.visible = false;
									MusicBeatState.switchState(new StoryMenu());
								case 'credits':
									FlxG.mouse.visible = false;
									MusicBeatState.switchState(new CreditsMenu());
								case 'options':
									LoadingState.loadAndSwitchState(new OptionsState());
							}
						});
					}
				}
			});
		}
		selectedSomethin = true;
	}

	function coolMenuEvents(getEvent:Int)
	{
		switch (getEvent)
		{
			case 1:
				var redGradient:FlxSprite = new FlxSprite(0, 0, Paths.image('UI/gimmicks/redGradient'));
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
				datBook.scale.set(.9, .9);
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('funkinAVI/menu/selectSfx'));
				menuItems.forEach(function(spr:FlxSprite)
				{
					for (item in [arrow, spr])
					FlxTween.tween(item, {x: item.x + 250, alpha: 0}, 0.4, {
						ease: FlxEase.quadOut,
						onComplete: function(twn:FlxTween)
						{
							spr.kill();
							arrow.kill();
						}
					});
				});
				if (arrow != null) FlxTween.tween(arrow, {alpha: 0}, 0, {ease: FlxEase.quadOut});
				new FlxTimer().start(.6, s -> MusicBeatState.switchState(new states.menus.CharacterMenu()));

			case 4:
				var cantaloupe = new FlxSprite(-200, -100).loadGraphic(Paths.image('Funkin_avi/cantaloupe'));
				cantaloupe.scale.set(0.05, 0.05);
				cantaloupe.screenCenter(XY).x -= 700;
				cantaloupe.y -= 300;
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
						case 0:
							messenger.sendMessage('You\'ve already unlocked this song!', 'Go to freeplay to play the song.');
						case 1:
							messenger.sendMessage('Can\'t you understand?', 'You already unlocked the song.');
						case 2:
							messenger.sendMessage('Can\'t you read?', 'This. Is. Already. Unlocked.');
						case 3:
							messenger.sendMessage('go to freeplay menu.', 'its already unlocked.');
						case 4:
							messenger.sendMessage('IF YOU KEEP DOING IT THEN', 'IM GONNA DO SOMETHING BAD');
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
		}
	}
}