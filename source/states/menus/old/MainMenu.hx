package states.menus;

import lime.ui.MouseCursor;
import openfl.ui.Mouse;
import openfl.events.MouseEvent;
import lime.app.Application;
import flash.system.System;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.input.keyboard.FlxKey;
import flixel.input.keyboard.FlxKeyboard;
import haxe.io.Path;
import openfl.net.SharedObject;
import openfl.net.SharedObjectFlushStatus;
import sys.io.File;
import flixel.addons.effects.FlxSkewedSprite;

using StringTools;

/**
 * This is the main menu state! Not a lot is going to change about it so it'll remain similar to the original, but I do want to condense some code and such.
 * Get as expressive as you can with this, create your own menu!
 * 
 * I really need to make a structure to manage and customize menus haha @BeastlyGhost
**/
class MainMenu extends MusicBeatState
{
	var menuItems:FlxTypedGroup<FlxSprite>;
	var curSelected:Int = 0;

	var bg:FlxSprite; // the background has been separated for more control
	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;

	var optionShit:Array<String> = ['story_mode', 'freeplay', 'credits', 'options'];

	// HOWTODELUSIONAL
	var delutranceLmao:Array<Dynamic> = [
		[FlxKey.H, FlxKey.H], [FlxKey.O, FlxKey.O], [FlxKey.W, FlxKey.W], [FlxKey.T, FlxKey.T], [FlxKey.O, FlxKey.O], [FlxKey.D, FlxKey.D],
		[FlxKey.E, FlxKey.E], [FlxKey.L, FlxKey.L], [FlxKey.U, FlxKey.U], [FlxKey.S, FlxKey.S], [FlxKey.I, FlxKey.I], [FlxKey.O, FlxKey.O],
		[FlxKey.N, FlxKey.N], [FlxKey.A, FlxKey.A], [FlxKey.L, FlxKey.L]];

	// the anniversary date of Funkin.avi lmao
	var birthdayCode:Array<Dynamic> = [
		[FlxKey.TWO, FlxKey.NUMPADTWO],
		[FlxKey.ONE, FlxKey.NUMPADONE],
		[FlxKey.ZERO, FlxKey.NUMPADZERO],
		[FlxKey.THREE, FlxKey.NUMPADTHREE],
		[FlxKey.TWO, FlxKey.NUMPADTWO],
		[FlxKey.TWO, FlxKey.NUMPADTWO]
	];

	var theCodeOrder:Int = 0;
	var theBirthdayCode:Int = 0;

	var eyes:FlxSprite;
	var floor:FlxSprite;
	var blood:FlxSprite;
	var otherCoolDetail:FlxSprite;
	var moreCoolDetails:FlxSprite;
	var omgCamera:FlxSprite;
	var datBook:FlxSprite;
	var shittyUnoptimizedBookCopy:FlxSprite;
	var discordIcon:FlxSprite;

	var gradient:FlxSprite;

	var arrow:FlxSprite;

	var arrowTween:FlxTween;

	var flashThing:Float = 0.0;

	var firstStart:Bool = true;
	var finishedFunnyMove:Bool = false;

	var freeplayPopup:FlxText;
	var freeplayPopupSub:FlxText;
	var freeplayTxtBox:FlxSprite;
	var freeplayTxtTween:FlxTween;
	var freeplayTxtTween2:FlxTween;
	var freeplayTxtTween3:FlxTween;

	var theBox:MessageBox;

	var camGame:FlxCamera;
	var camHUD:FlxCamera;

	var sigmaClick:FlxSkewedSprite;

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
		"Main Menu Music: Soulless Town",
		"Mickey lost his ballsack.",
		"Oh the horror of AI generated images.",
		"You should [R] Reset Character NOW", // boblox reference
		"awesome mouse experience.",
		"This mod was stressful to make.",
		"Funkin.avi - Funkin.avi - Funkin.avi - Funkin.avi - Funkin.avi - Funkin.avi - Funkin.avi - Funkin.avi - Funkin.avi - Funkin.avi - Funkin.avi",
		"Just like Domingo is constantly remaking Mickey's sprites, Dreupy is the Domingo of Delusional Recharts.",
		"Type \"HOWTODELUSIONAL\" for a special surprise :)",
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

	var defaultShader:FlxRuntimeShader;
	var defaultShader2:FlxRuntimeShader;
	var darkFilter:FlxRuntimeShader;

	var evilAndFuckedUpBookScale = 1.0;

	var howmuchyoufuckinkeptdoingit:Int = 0;

	// the create 'state'
	override function create()
	{
		Paths.clearUnusedMemory();

		camGame = new FlxCamera(); // Main camera for objects and stuff

		camHUD = new FlxCamera(); // for the grain effect and etc
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		FlxG.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);

		super.create();

		FlxG.mouse.load(Paths.image('UI/funkinAVI/mouses/Hand').bitmap);
		
		if (!FlxG.mouse.visible)
			FlxG.mouse.visible = true;

		if (ClientPrefs.shaders)
		{
			defaultShader = new FlxRuntimeShader(Shaders.grayScale, null, 140);
			defaultShader2 = new FlxRuntimeShader(Shaders.monitorFilter, null, 140);
			darkFilter = new FlxRuntimeShader(Shaders.dimScreen, null, 120);

			if (!ClientPrefs.shaders)
			{
				if (!ClientPrefs.lowQuality)
				{
					camGame.setFilters([
						new openfl.filters.ShaderFilter(defaultShader2),
						new openfl.filters.ShaderFilter(defaultShader),
						new openfl.filters.ShaderFilter(darkFilter),
					]);
				}
				else
				{
					camGame.setFilters([new openfl.filters.ShaderFilter(defaultShader2),]);
				}
			}
		}

		openfl.Lib.application.window.title = "Funkin.avi - " + windowShit[FlxG.random.int(0, windowShit.length - 1)];

		// shutdowns the game
		if (openfl.Lib.application.window.title.contains('10 Seconds before I shut your fucking game again >:('))
		{
			new flixel.util.FlxTimer().start(10, function(e)
			{
				Sys.exit(0);
			});
		}

		// set the transitions to the previously set ones
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		DiscordClient.changePresence('Main Menu', 'Browsing...', 'icon', 'mouse');

		// uh
		persistentUpdate = persistentDraw = true;

		floor = new FlxSprite().loadGraphic(Paths.image('Funkin_avi/menu/menuBG'));
		floor.scrollFactor.set(0, 0);
		floor.setGraphicSize(0, FlxG.height);
		floor.updateHitbox();
		floor.screenCenter();
		floor.antialiasing = ClientPrefs.globalAntialiasing;
		add(floor);

		/*trace(GameData.episode1FPLock);
		if (GameData.episode1FPLock == 'unlocked')
		{
			sigmaClick = new FlxSkewedSprite(500, 600, Paths.image('Funkin_avi/menu/click'));
			sigmaClick.antialiasing = ClientPrefs.globalAntialiasing;
			sigmaClick.setGraphicSize(100, 100);
			sigmaClick.updateHitbox();
			sigmaClick.screenCenter();
			sigmaClick.x -= 150;
			sigmaClick.y -= 80;
			sigmaClick.angle = 6;
			sigmaClick.skew.set(15, -10);
			add(sigmaClick);
		}*/

		datBook = new FlxSprite().loadGraphic(Paths.image('Funkin_avi/menu/book'));
		datBook.scrollFactor.set(0, 0);
		datBook.setGraphicSize(0, FlxG.height);
		datBook.updateHitbox();
		datBook.screenCenter().x -= 220;
		datBook.antialiasing = ClientPrefs.globalAntialiasing;
		add(datBook);

		/*discordIcon = new FlxSprite().loadGraphic(Paths.image('Funkin_avi/menu/discordIcon'));
		discordIcon.scrollFactor.set(0, 0);
		discordIcon.scale.set(0.6, 0.6);
		discordIcon.updateHitbox();
		discordIcon.screenCenter().x += 250;
		discordIcon.y += 350;
		discordIcon.antialiasing = ClientPrefs.globalAntialiasing;
		add(discordIcon);*/

		/*shittyUnoptimizedBookCopy = new FlxSprite().loadGraphic(Paths.image('Funkin_avi/menu/book'));
		shittyUnoptimizedBookCopy.scrollFactor.set(0, 0);
		shittyUnoptimizedBookCopy.setGraphicSize(Std.int(shittyUnoptimizedBookCopy.width * 0.68));
		shittyUnoptimizedBookCopy.updateHitbox();
		shittyUnoptimizedBookCopy.screenCenter().x += 285;
		shittyUnoptimizedBookCopy.antialiasing = true;
		shittyUnoptimizedBookCopy.setColorTransform(1, 1, 1, 1, 255, 255, 255, 255);
		insert(members.indexOf(datBook) - 1, shittyUnoptimizedBookCopy);*/

		if (!ClientPrefs.lowQuality)
		{
			arrow = new FlxSprite().loadGraphic(Paths.image('Funkin_avi/menu/menuArrow'));
			arrow.screenCenter(X);
			arrow.scrollFactor.set(0, 0);
			arrow.antialiasing = ClientPrefs.globalAntialiasing;

			// i think colorTransform is better than a shader in this case. i don't know, i'm just doing theories
			/*if (!Init.trueSettings.get('Disable Screen Shaders'))
				arrow.shader = arrowFlash;*/
			add(arrow);

			gradient = new FlxSprite().loadGraphic(Paths.image('Funkin_avi/filters/gradient'));
			gradient.scrollFactor.set(0, 0);
			gradient.setGraphicSize(Std.int(gradient.width * 0.78));
			gradient.x -= 5;
			gradient.updateHitbox();
			gradient.screenCenter();
			gradient.antialiasing = ClientPrefs.globalAntialiasing;
			add(gradient);

			var vig = new FlxSprite().loadGraphic(Paths.image('Funkin_avi/menu/vignette'));
			vig.setGraphicSize(0, FlxG.height);
			vig.scrollFactor.set(0, 0);
			vig.antialiasing = ClientPrefs.globalAntialiasing;
			vig.screenCenter();
			add(vig);
		}

		// add the camera
		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		// add the menu items
		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 0.8;

		for (i in 0...optionShit.length)
		{
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(0, (i * 100) + offset);
			menuItem.scale.set(0.6, 0.6);
			menuItem.updateHitbox();
			menuItem.loadGraphic(Paths.image('Funkin_avi/menu/buttons/' + optionShit[i]));
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItem.x += 460;
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			menuItem.scrollFactor.set(0, 0);

			switch (menuItem.ID)
			{
				case 0:
					menuItem.y = 130;
				case 1:
					if (GameData.episode1FPLock != "unlocked")
						menuItem.loadGraphic(Paths.image('Funkin_avi/menu/buttons/freeplayLocked'));

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

		// set the camera to actually follow the camera object that was created before
		FlxG.camera.follow(camFollowPos, LOCKON, 1);
 
		theBox = new MessageBox(-400, FlxG.height - 80, {
			text: 'Freeplay is Locked!', 
			subText: 'Complete Episode 1 to Unlock this Menu!',
			boxHeight: 90,
			boxWidth: 600,
			font: 'DisneyFont.ttf',
			camera: camHUD
		});
		add(theBox);

		if (!ClientPrefs.lowQuality)
		{
			var scratchStuff:FlxSprite = new FlxSprite();
			scratchStuff.frames = Paths.getSparrowAtlas('Funkin_avi/filters/scratchShit');
			scratchStuff.animation.addByPrefix('idle', 'scratch thing 1', 24, true);
			scratchStuff.animation.play('idle');
			scratchStuff.screenCenter();
			scratchStuff.scale.x = 1.1;
			scratchStuff.scale.y = 1.1;
			scratchStuff.cameras = [camHUD];
			add(scratchStuff);

			var grain:FlxSprite = new FlxSprite();
			grain.frames = Paths.getSparrowAtlas('Funkin_avi/filters/Grainshit');
			grain.animation.addByPrefix('idle', 'grains 1', 24, true);
			grain.animation.play('idle');
			grain.screenCenter();
			grain.scale.x = 1.1;
			grain.scale.y = 1.1;
			grain.cameras = [camHUD];
			add(grain);
		}

		if (FlxG.stage.window.title.contains('*cantaloupe jumpscare*'))
		{
			var cantaloupe = new FlxSprite(-200, -100).loadGraphic(Paths.image('Funkin_avi/cantaloupe'));
			cantaloupe.scale.set(0.05, 0.05);
			cantaloupe.screenCenter(XY).x -= 700;
			cantaloupe.y -= 300;
			FlxTween.tween(cantaloupe.scale, {x: 2, y: 2}, 3, {ease: FlxEase.bounceOut, onComplete: _ -> FlxTween.tween(cantaloupe, {alpha: 0}, 2)});
			cantaloupe.shake(.05, 0, 5);
			add(cantaloupe);

			FlxG.camera.shake(0.02, 5);

			FlxG.sound.play(Paths.sound('funkinAVI/fnaf_jumpscare'), 0.7, false, null, true, () -> cantaloupe.destroy());
		}

		/*if (GameData.highOnCrackLock == 'forceBackToSong') // you can't run from delutrance lol
		{
			var songLowercase:String = Paths.formatToSongPath("Delutrance");
			var poop:String = Highscore.formatSong(songLowercase, 0); //fuck fuck fuck fuck fuck fuck
			PlayState.SONG = Song.loadFromJson(poop, songLowercase);
			new FlxTimer().start(0.25, function(tmr:FlxTimer)
			{
				LoadingState.loadAndSwitchState(new PlayState());
				FlxG.sound.music.volume = 0;
			});
		}*/
		updateSelection();
		new FlxTimer().start(0.1, function(tmr){
			menuItems.forEach(function(spr:FlxSprite){
				spr.updateHitbox();
			});
		});
	}

	var selectedSomethin:Bool = false;
	var isHitboxFixed:Bool = false;
	var counterControl:Float = 0;

	var iconOverlap:Float = 0.9;

	override function update(elapsed:Float)
	{
		var iconLerp:Float = CoolUtil.boundTo(elapsed * 9, 0, 1);
		/*if (!CoolUtil.findCoreFile())
		{
			new FlxTimer().start(1.0, function(tmr:FlxTimer)
			{
				FlxG.switchState(new SafeModeState());
				FlxG.sound.music.volume = 0;
			});
		}*/

		if (!sys.FileSystem.exists('./assets/shared/images/favi/stages/forbiddenRealm/DO NOT TOUCH MY MEME.png') && GameData.check(NO_MALFUNCTION))
		{
			selectedSomethin = true;
			new FlxTimer().start(0.4, function(tmr:FlxTimer)
			{
				selectedSomethin = false;
			});
			FlxG.sound.play(Paths.sound('funkinAVI/easterEggSound'));
		 	theBox.sendMessage('I just wanna talk bro.', 'New Freeplay Song Unlocked!');
			GameData.canAddMalfunction = true;
			GameData.saveShit();
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);

		if (FlxG.keys.justPressed.R)
		{
			var redGradient:FlxSprite = new FlxSprite(0, 0, Paths.image('UI/gimmicks/redGradient'));
			redGradient.setGraphicSize(Std.int(redGradient.width * 0.7));
			redGradient.screenCenter();
			redGradient.cameras = [camHUD];
			FlxTween.tween(redGradient, {alpha: 0}, 0.9, {onComplete: sex -> redGradient.destroy()});
			add(redGradient);

			FlxG.sound.play(Paths.sound('funkinAVI/oof'), 1, false, null, true);
		}

		// more optimized than tweens if i'm not wrong
		if (arrow != null) arrow.setPosition(FlxMath.lerp(arrowX, arrow.x, CoolUtil.boundTo(1 - (elapsed * 15), 0, 1)), FlxMath.lerp(arrowY, arrow.y, CoolUtil.boundTo(1 - (elapsed * 15), 0, 1)));

		if (FlxG.keys.justPressed.ANY)
		{
			var hitCorrectKey:Bool = false;
			var birthdayKey:Bool = false;

			for (b in 0...birthdayCode[theBirthdayCode].length)
			{
				if (FlxG.keys.checkStatus(birthdayCode[theBirthdayCode][b], JUST_PRESSED))
					birthdayKey = true;
			}

			if (birthdayKey && !selectedSomethin && GameData.birthdayLocky != "uninvited")
			{
				if (theBirthdayCode == (birthdayCode.length - 1))
				{
					if (GameData.birthdayLocky == "unlocked" || GameData.birthdayLocky == "beaten")
					{
						// can i kill myself please? --- no bro, not yet (don)
						FlxG.sound.play(Paths.sound('cancelMenu'));
						switch(howmuchyoufuckinkeptdoingit) {
							case 0:
								theBox.sendMessage('You\'ve already unlocked this song!', 'Go to freeplay to play the song.');
							case 1:
								theBox.sendMessage('Can\'t you understand?', 'You already unlocked the song.');
							case 2:
								theBox.sendMessage('Can\'t you read?', 'This. Is. Already. Unlocked.');
							case 3:
								theBox.sendMessage('go to freeplay menu.', 'its already unlocked.');
							case 4:
								theBox.sendMessage('IF YOU KEEP DOING IT THEN', 'IM GONNA DO SOMETHING BAD');
							case 5:
								theBox.sendMessage('...', 'Im closing the game. Fuck you');
								new FlxTimer().start(2, function(tmr:FlxTimer){
									System.exit(0);
								});
						}


						howmuchyoufuckinkeptdoingit++;

					}
					else
					{
						// There's the new way of you getting Birthday brah - MalyPlus
						GameData.birthdayLocky = 'obtained';
						//FlxG.sound.play(Paths.sound('confirmMenu'));
						FlxG.sound.play(Paths.sound('funkinAVI/easterEggSound'));
						theBox.sendMessage('Something has unlocked!', 'Check freeplay to see what has been unlocked.');
					}
				}
				else
				{
					theBirthdayCode++;
				}
			}
			else
			{
				theBirthdayCode = 0;
				for (b in 0...birthdayCode[0].length)
				{
					if (FlxG.keys.checkStatus(birthdayCode[0][b], JUST_PRESSED))
						theBirthdayCode = 1;
				}
			}

			if (theBirthdayCode == 3)
				FlxG.sound.muteKeys = null;
			else
				FlxG.sound.muteKeys = [FlxKey.ZERO, FlxKey.NUMPADZERO];
		}

		var changeValue:Int = 0;

		if (!selectedSomethin)
		{
			if ((controls.UI_UP_P))
			{
				FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'));
				changeValue -= 1;
			}

			if ((controls.UI_DOWN_P))
			{
				FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'));
				changeValue += 1;
			}

			if ((controls.BACK))
			{
				selectedSomethin = true;
				//FlxG.sound.play(Paths.sound('base/menus/cancelMenu'));
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if ((controls.ACCEPT))
				enterSelection();
	
		}
		
		curSelected = FlxMath.wrap(Math.floor(curSelected) + changeValue, 0, optionShit.length - 1);
		Conductor.songPosition = FlxG.sound.music != null ? FlxG.sound.music.time : 0;

		if (ClientPrefs.shaders)
			darkFilter.setFloat('iTime', Conductor.songPosition / 1000);

		for (i in 0...menuItems.length) menuItems.members[i].scale.set(FlxMath.lerp(.6, menuItems.members[i].scale.x, CoolUtil.boundTo(1 - (elapsed * 9.6), 0, 1)), FlxMath.lerp(.6, menuItems.members[i].scale.y, CoolUtil.boundTo(1 - (elapsed * 9.6), 0, 1)));

		if (FlxG.keys.justPressed.SEVEN && !selectedSomethin)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			theBox.sendMessage('Sorry, debug access is not allowed!', 'We will open it back up in a later update however...');
		}

		if (FlxG.keys.justPressed.ONE && !selectedSomethin && Main.debug)
		{
			GameData.unlockEverything();
			FlxG.sound.play(Paths.sound('funkinAVI/easterEggSound'));
		}

		if (FlxG.keys.justPressed.TWO && !selectedSomethin && Main.debug)
		{
			GameData.episode1FPLock = "unlocked";
			GameData.saveShit();
		}

		if (Math.floor(curSelected) != lastCurSelected || !isHitboxFixed)
			updateSelection();

		if (FlxG.mouse.justMoved)
		{
			for (i in 0...menuItems.length)
			{
				if (i != curSelected)
				{
					if (FlxG.mouse.overlaps(menuItems.members[i]) && !FlxG.mouse.overlaps(menuItems.members[curSelected]))
					{
						changeSelection(i);
					}
				}
			}
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (sigmaClick != null && FlxG.mouse.overlaps(sigmaClick) && FlxG.mouse.justPressed)
		{
			FlxG.sound.play(Paths.sound('funkinAVI/easterEggSound'));

			FlxG.camera.fade();
			FlxG.sound.music.fadeOut(3, 0, s -> FlxG.switchState(new states.menus.AskQuestionToThatGuy()));
			FlxTween.tween(camGame, {y: -300}, 2, {ease: FlxEase.sineInOut});
		}

		//if (FlxG.mouse.overlaps(discordIcon))
		//{

		//}

		datBook.scale.set(FlxMath.lerp(evilAndFuckedUpBookScale, datBook.scale.x, CoolUtil.boundTo(1 - (elapsed * 9.6), 0, 1)), FlxMath.lerp(evilAndFuckedUpBookScale, datBook.scale.x, CoolUtil.boundTo(1 - (elapsed * 9.6), 0, 1)));
		/*shittyUnoptimizedBookCopy.scale.set(FlxMath.lerp(evilAndFuckedUpBookScale + .02, shittyUnoptimizedBookCopy.scale.x, .65), FlxMath.lerp(evilAndFuckedUpBookScale, shittyUnoptimizedBookCopy.scale.x, .65));
		shittyUnoptimizedBookCopy.alpha = FlxMath.lerp(FlxG.mouse.overlaps(datBook) ? .7 : 0, shittyUnoptimizedBookCopy.alpha, .65);*/
		evilAndFuckedUpBookScale = (FlxG.mouse.overlaps(datBook) && !FlxG.mouse.overlaps(menuItems.members[curSelected])) ? 1.1 : 1; 
		
		if ((FlxG.mouse.overlaps(datBook) && !FlxG.mouse.overlaps(menuItems.members[curSelected])) && FlxG.mouse.justPressed && !selectedSomethin)
		{
			if (GameData.malfunctionLock == "unlocked" || GameData.malfunctionLock == "beaten")
			{
				datBook.scale.set(.9, .9);
				//shittyUnoptimizedBookCopy.scale.set(.75, .77);

				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('funkinAVI/menu/selectSfx'));

				//theBox.sendMessage('You might have to wait...', 'The secrets that lie within this book shall soon be revealed...');
				
				FlxG.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
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
			}
			else
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				theBox.sendMessage('You haven\'t unlocked this yet!', 'Complete EVERYTHING to open this book.');
			}
		}

		if (FlxG.mouse.justPressed && !selectedSomethin)
		{
			if (FlxG.mouse.overlaps(menuItems.members[curSelected]))
			{
				enterSelection();
			}
		}

		super.update(elapsed);
	}

	override function destroy() {
		super.destroy();

		FlxG.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
	}

	// corny ass functions for mouse usage grah
	function changeSelection(selection:Int)
	{
		if (selection != curSelected)
		{
			//FlxG.sound.play(Paths.sound('base/menus/scrollMenu'));
			FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'));
		}

		if (selection < 0)
			selection = optionShit.length - 1;
		if (selection >= optionShit.length)
			selection = 0;

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = menuItems.members[i];
			if (i == selection)
			{
				menuItem.alpha = 1.0;
			}
			else
			{
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

		if (daChoice == 'freeplay')
		{
			if (GameData.episode1FPLock == 'unlocked' || GameData.birthdayLocky == 'beaten')
			{
				for (sillies in [arrow, menuItems.members[Math.floor(curSelected)]])
				{
					if (sillies != null)
					{
						sillies.setColorTransform(1, 1, 1, 1, 255, 255, 255, 255);
						FlxTween.tween(sillies.colorTransform, {redOffset: 0, greenOffset: 0, blueOffset: 0}, 1);
					}
				}
				selectedSomethin = true;
				//FlxG.sound.play(Paths.sound('base/menus/confirmMenu'));
				FlxG.sound.play(Paths.sound('funkinAVI/menu/selectSfx'));
				FlxG.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
				FlxG.sound.music.fadeOut(0.8);
				//FlxTween.tween(camGame, {zoom: 6}, 2, {ease: FlxEase.cubeInOut, startDelay: 0.5});

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
						FlxG.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
						menuItems.members[curSelected].scale.set(.75, .75);
						FlxFlicker.flicker(spr, 1, flashValue, false, false, function(flick:FlxFlicker)
						{
							switch (daChoice)
							{
								case 'freeplay':
									MusicBeatState.switchState(new GeneralMenu());
									FlxG.sound.music.fadeIn(0.5, 0, 0.7);
									FlxG.sound.playMusic(Paths.music('aviOST/seekingFreedom'));
							}
						});
					}
				});
			}
			else
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				theBox.sendMessage('Freeplay is locked!', 'Complete Episode 1 to Unlock this menu.');
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
						FlxG.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
						menuItems.members[curSelected].scale.set(.75, .75);
						FlxFlicker.flicker(spr, 1, flashValue, false, false, function(flick:FlxFlicker)
						{
							switch (daChoice)
							{
								case 'story_mode':
									FlxG.mouse.visible = false;
									Mouse.cursor = AUTO;
									MusicBeatState.switchState(new StoryMenu());
								case 'credits':
									FlxG.mouse.visible = false;
									Mouse.cursor = AUTO;
									MusicBeatState.switchState(new CreditsMenu());
								case 'options':
									transIn = FlxTransitionableState.defaultTransIn;
									transOut = FlxTransitionableState.defaultTransOut;
									Mouse.cursor = AUTO;
									LoadingState.loadAndSwitchState(new OptionsState());
							}
						});
						for (sillies in [arrow, menuItems.members[Math.floor(curSelected)]])
						{
							if (sillies != null)
							{
								sillies.setColorTransform(1, 1, 1, 1, 255, 255, 255, 255);
								FlxTween.tween(sillies.colorTransform, {redOffset: 0, greenOffset: 0, blueOffset: 0}, 1);
							}
						}
						selectedSomethin = true;
						FlxG.sound.play(Paths.sound('funkinAVI/menu/selectSfx'));
						//FlxTween.tween(camGame, {zoom: 6}, 2, {ease: FlxEase.cubeInOut, startDelay: 0.5});
					}
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('funkinAVI/menu/selectSfx'));
					//FlxTween.tween(camGame, {zoom: 6}, 2, {ease: FlxEase.cubeInOut, startDelay: 0.5});
				}
			});
		}
	}

	var lastCurSelected:Int = 1;
	var arrowX:Float = 0;
	var arrowY:Float = 0;

	private function updateSelection()
	{
		// reset all selections
		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.alpha = 0.45;
			spr.color = FlxColor.WHITE;
			spr.updateHitbox();
		});

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

		// don't use <, worst mistake of my carrer
		if (menuItems.members[Math.floor(curSelected)].alpha == 0.45)
		{
			menuItems.members[Math.floor(curSelected)].color = FlxColor.RED;
			menuItems.members[Math.floor(curSelected)].alpha = 1;
		}

		menuItems.members[Math.floor(curSelected)].updateHitbox();

		lastCurSelected = Math.floor(curSelected);
		if (!isHitboxFixed) 
			isHitboxFixed = true;
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