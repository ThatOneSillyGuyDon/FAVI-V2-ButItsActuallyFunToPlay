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
		[FlxKey.ZERO, FlxKey.NUMPADZERO],
		[FlxKey.THREE, FlxKey.NUMPADTHREE],
		[FlxKey.TWO, FlxKey.NUMPADTWO],
		[FlxKey.ONE, FlxKey.NUMPADONE],
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

	var windowShit:Array<Any> = [
		"Anyone up right now?",
		"Shipy's SNS Mickey & F.AVI Mickey will make love to each other",
		"We lied about Episode 2's release...",
		"I trapped Demolition in my basement.",
		"V3 will release next year, we need a fucking break",
		"Someone put an end to my misery. - Mickey 2023",
		"I dare you to press 7 on that keyboard of yours.",
		"Cock & ball torture.",
		"OKAY, YOU GOT DELUSIONAL, NOW STFU.",
		"Cast & Crew (Couch Song) is on Cognitive Crisis, cry about it.",
		"Look at that cute little devil, he c00t :3",
		"Do you like the new menu art?",
		"You're gonna love the final song.",
		"Malfunction isn't easy anymore, fuck you, skill issue B)",
		"Happy Birthday Muckney!",
		"Psych Engine basically corrupted all our shit, which is why it's on Another Engine now.",
		"SOMEONE PLEASE GIVE MICKEY HIS FUCKING SANDWICH",
		"Have fun, you'll be here for like an hour or longer.",
		"10 Seconds before I shut your fucking game again >:(",
		"Oh the misery, everybody wants to be my enemy.",
		"Sex, NOW.",
		"Quick, hide behind that conveniently shaped lamp!",
		"Welcome to hell",
		"blue lobster *jumpscare*",
		"hi. *starts dancing on the floor*",
		"sample text 2: electric boogaloo",
		"The bastard named squidward cheated on poor mickey :(",
		"D E A T H",
		"Man, i'm starving... *Fight or Flight plays*",
		"Shit, the mouse got a gun again.",
		"You should /kill @s NOW", // haha, funi Minecraft reference
		"Why are you here? FNF is still cancelled.",
		"This community is fr the big stinky.",
		"Go ahead, cancel us, you'll only make us come back stronger.",
		"NOOOOOOOOOOO, YOU CAN'T JUST CHEAT THE GAME!!!!!!!",
		"V3 Update in a Nutshell: Suicidal Remixes",
		"Mom, can we have Wednesday's Infidelity?",
		"GUYS, LOOK, IT'S SHIPY, SAY HELLO TO HER! :D",
		"Don't leave Muckney's party, please, you'll make him sad if you do :(",
		"It's about drive, it's about power, we stay hungry, we devour.",
		// i miss this one it was funny asf................
		// "Main Menu Music: idfk, you might've removed the damn menu music by going in and out of freeplay >:(",
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
		"peak mouse experience.",
		"Austin is the most horniest of the team lmao",
		"This mod was stressful to make, the organization was a mess lmao",
		"Funkin.AVI - Funkin.AVI - Funkin.AVI - Funkin.AVI - Funkin.AVI - Funkin.AVI - Funkin.AVI - Funkin.AVI - Funkin.AVI - Funkin.AVI - Funkin.avi",
		"Just like Domingo is constantly remaking Mickey's sprites, Dreupy is the Domingo of Delusional Recharts.",
		"Type \"HOWTODELUSIONAL\" for a special surprise :)",
		"When did Funkin.avi start development?",
		"I think one of the codes is a certain date",
		"This mod was an idea that started on 03/21/22, pretty crazy, right?",
		"Everyday is Muckney's Birthday",
		"there is no message, go play some minecraft",
		"THEY HIT THE FUCKING PENTAGON, SMILES",
		"Want a break from the ads? If you tap now to take a short servey, you'll recieve 30 minutes of ad-free music.",
		"I bet you're complaining that this isn't on Psych Engine right about now, silly kiddo",
		"Connection terminated. I'm sorry to interupt you Elizabeth, if you still even remember that name, but I'm afraid you've been misinformed." // yes.
	];

	var defaultShader:FlxRuntimeShader;
	var defaultShader2:FlxRuntimeShader;
	var darkFilter:FlxRuntimeShader;

	public var logContent:String;

	public function new(?logContent:String)
	{
		super();

		this.logContent = logContent;
	}

	// the create 'state'
	override function create()
	{
		if (!FlxG.mouse.visible)
			FlxG.mouse.visible = true;

		camGame = new FlxCamera(); // Main camera for objects and stuff

		camHUD = new FlxCamera(); // for the grain effect and etc
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		Paths.clearUnusedMemory();

		FlxG.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);

		super.create();

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

		openfl.Lib.application.window.title = "Funkin.AVI - " + windowShit[FlxG.random.int(0, windowShit.length - 1)];

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

		DiscordClient.changePresence('Funkin.avi', 'Main Menu', 'icon', 'mouse');

		// uh
		persistentUpdate = persistentDraw = true;

		eyes = new FlxSprite().loadGraphic(Paths.image('Funkin_avi/NEWmenu/HahaSadBoi'));
		eyes.scrollFactor.set(0, 0);
		eyes.screenCenter();
		eyes.updateHitbox();
		eyes.antialiasing = true;

		floor = new FlxSprite().loadGraphic(Paths.image('Funkin_avi/menu/floor'));
		floor.scrollFactor.set(0, 0);
		floor.setGraphicSize(Std.int(floor.width * 0.75));
		floor.updateHitbox();
		floor.screenCenter();
		floor.antialiasing = true;
		add(floor);

		if (!ClientPrefs.lowQuality)
		{
			blood = new FlxSprite().loadGraphic(Paths.image('Funkin_avi/menu/blood'));
			blood.scrollFactor.set(0, 0);
			blood.setGraphicSize(Std.int(blood.width * 0.75));
			blood.updateHitbox();
			blood.screenCenter();
			blood.antialiasing = true;
			add(blood);

			otherCoolDetail = new FlxSprite().loadGraphic(Paths.image('Funkin_avi/menu/coolDetails'));
			otherCoolDetail.scrollFactor.set(0, 0);
			otherCoolDetail.setGraphicSize(Std.int(otherCoolDetail.width * 0.75));
			otherCoolDetail.updateHitbox();
			otherCoolDetail.screenCenter();
			otherCoolDetail.antialiasing = true;
			add(otherCoolDetail);

			omgCamera = new FlxSprite().loadGraphic(Paths.image('Funkin_avi/menu/camera_in_a_cool_way'));
			omgCamera.scrollFactor.set(0, 0);
			omgCamera.setGraphicSize(Std.int(omgCamera.width * 0.75));
			omgCamera.updateHitbox();
			omgCamera.screenCenter();
			omgCamera.antialiasing = true;
			add(omgCamera);
		}

		datBook = new FlxSprite().loadGraphic(Paths.image('Funkin_avi/menu/book'));
		datBook.scrollFactor.set(0, 0);
		datBook.setGraphicSize(Std.int(datBook.width * 0.75));
		datBook.updateHitbox();
		datBook.screenCenter();
		datBook.antialiasing = true;
		add(datBook);

		if (!ClientPrefs.lowQuality)
		{
			moreCoolDetails = new FlxSprite().loadGraphic(Paths.image('Funkin_avi/menu/light'));
			moreCoolDetails.scrollFactor.set(0, 0);
			moreCoolDetails.setGraphicSize(Std.int(moreCoolDetails.width * 0.75));
			moreCoolDetails.updateHitbox();
			moreCoolDetails.screenCenter();
			moreCoolDetails.antialiasing = true;
			add(moreCoolDetails);

			arrow = new FlxSprite().loadGraphic(Paths.image('Funkin_avi/menu_arrow'));
			arrow.setGraphicSize(Std.int(arrow.width * 0.3));
			arrow.screenCenter(X);
			arrow.scrollFactor.set(0, 0);

			// i think colorTransform is better than a shader in this case. i don't know, i'm just doing theories
			/*if (!Init.trueSettings.get('Disable Screen Shaders'))
				arrow.shader = arrowFlash;*/
			add(arrow);

			gradient = new FlxSprite().loadGraphic(Paths.image('filters/gradient'));
			gradient.scrollFactor.set(0, 0);
			gradient.setGraphicSize(Std.int(gradient.width * 0.75));
			gradient.updateHitbox();
			gradient.screenCenter();
			gradient.antialiasing = true;
			add(gradient);
		}

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.set(0, 0.18);
		magenta.setGraphicSize(Std.int(magenta.width * 1.1));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = true;
		magenta.color = 0xFFfd719b;
		add(magenta);

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
			menuItem.loadGraphic(Paths.image('Funkin_avi/menu/buttons/' + optionShit[i]));
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItem.x -= 100;
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			menuItem.scrollFactor.set(0, scr);

			switch (menuItem.ID)
			{
				case 0:
					menuItem.y = 150;
				case 1:
					menuItem.y = 250;
				case 2:
					menuItem.y = 350;
				case 3:
					menuItem.y = 450;
			}

			menuItem.antialiasing = true;
			menuItem.updateHitbox();

			if (arrow != null)
				arrow.angle = 90;
		}

		// set the camera to actually follow the camera object that was created before
		FlxG.camera.follow(camFollowPos, null, 1);

		updateSelection();

		// from the base game lol
		var versionShit:FlxText = new FlxText(5, FlxG.height * 0.01, 0, 'Funkin.avi v2.0.0', 24);
		versionShit.setFormat(Paths.font("DisneyFont"), 30, 0xFFFFFFFF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFF000000);
		versionShit.scrollFactor.set();
		versionShit.cameras = [camHUD];
		add(versionShit);
 
		theBox = new MessageBox(-400, FlxG.height - 80, {
			text: 'Freeplay is Locked!', 
			subText: 'Complete Episode 1 to Unlock this Menu!',
			font: 'DisneyFont',
			camera: camHUD
		});
		add(theBox);

		if (!ClientPrefs.lowQuality)
		{
			var scratchStuff:FlxSprite = new FlxSprite();
			scratchStuff.frames = Paths.getSparrowAtlas('filters/scratchShit');
			scratchStuff.animation.addByPrefix('idle', 'scratch thing 1', 24, true);
			scratchStuff.animation.play('idle');
			scratchStuff.screenCenter();
			scratchStuff.scale.x = 1.1;
			scratchStuff.scale.y = 1.1;
			scratchStuff.cameras = [camHUD];
			add(scratchStuff);

			var grain:FlxSprite = new FlxSprite();
			grain.frames = Paths.getSparrowAtlas('filters/Grainshit');
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
			FlxTween.tween(cantaloupe.scale, {x: 2, y: 2}, 3, {ease: FlxEase.bounceOut, onComplete: _ -> FlxTween.tween(cantaloupe, {alpha: 0}, 3)});
			add(cantaloupe);

			FlxG.camera.shake(0.02, 5);

			FlxG.sound.play(Paths.sound('funkinAVI/fnaf_jumpscare'), 0.7, false, null, true, () -> cantaloupe.destroy());
		}
	}

	var selectedSomethin:Bool = false;
	var counterControl:Float = 0;

	override function update(elapsed:Float)
	{
		if (!CoolUtil.findCoreFile())
		{
			new FlxTimer().start(1.0, function(tmr:FlxTimer)
			{
				FlxG.switchState(new SafeModeState());
				FlxG.sound.music.volume = 0;
			});
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);

		if (FlxG.keys.justPressed.R)
		{
			var redGradient:FlxSprite = new FlxSprite(0, 0, Paths.image('UI/gimmicks/redGradient'));
			redGradient.setGraphicSize(Std.int(redGradient.width * 0.7));
			redGradient.screenCenter();
			redGradient.cameras = [camHUD];
			FlxTween.tween(redGradient, {alpha: 0.001}, 0.9);
			add(redGradient);

			FlxG.sound.play(Paths.sound('funkinAVI/oof'), 1, false, null, true, () -> redGradient.destroy());
		}

		// more optimized than tweens if i'm not wrong
		if (arrow != null) arrow.setPosition(FlxMath.lerp(arrowX, arrow.x, CoolUtil.boundTo(1 - (elapsed * 15), 0, 1)), FlxMath.lerp(arrowY, arrow.y, CoolUtil.boundTo(1 - (elapsed * 15), 0, 1)));

		if (FlxG.keys.justPressed.ANY)
		{
			var hitCorrectKey:Bool = false;
			var birthdayKey:Bool = false;

			for (i in 0...delutranceLmao[theCodeOrder].length)
			{
				if (FlxG.keys.checkStatus(delutranceLmao[theCodeOrder][i], JUST_PRESSED))
					hitCorrectKey = true;
			}

			for (b in 0...birthdayCode[theBirthdayCode].length)
			{
				if (FlxG.keys.checkStatus(birthdayCode[theBirthdayCode][b], JUST_PRESSED))
					birthdayKey = true;
			}

			if (hitCorrectKey)
			{
				if (theCodeOrder == (delutranceLmao.length - 1))
				{
					PlayState.storyDifficulty = 0;
					FlxG.sound.play(Paths.sound('funkinAVI/easterEggSound'));
					FlxG.camera.fade(FlxColor.BLACK, 1);
					camHUD.fade(FlxColor.BLACK, 1);
					FlxG.sound.music.fadeOut(0.7);
					PlayState.SONG = Song.loadFromJson('delutrance-hard', 'delutrance');
					PlayState.campaignScore = 0;
					PlayState.campaignMisses = 0;
					new FlxTimer().start(1.4, function(tmr:FlxTimer)
					{
						LoadingState.loadAndSwitchState(new PlayState());
						FlxG.sound.music.volume = 0;
					});
				}
				else
				{
					theCodeOrder++;
				}
			}
			else
			{
				theCodeOrder = 0;
				for (i in 0...delutranceLmao[0].length)
				{
					if (FlxG.keys.checkStatus(delutranceLmao[0][i], JUST_PRESSED))
						theCodeOrder = 1;
				}
			}

			if (birthdayKey)
			{
				if (theBirthdayCode == (birthdayCode.length - 1))
				{
					PlayState.storyDifficulty = 0;
					PlayState.SONG = Song.loadFromJson('birthday-hard', 'birthday');
					PlayState.campaignScore = 0;
					PlayState.campaignMisses = 0;
					FlxG.sound.music.fadeOut(0.7);
					FlxG.sound.play(Paths.sound('funkinAVI/easterEggSound'));
					FlxG.camera.fade(FlxColor.BLACK, 1);
					camHUD.fade(FlxColor.BLACK, 1);
					new FlxTimer().start(1.4, function(tmr:FlxTimer)
					{
						LoadingState.loadAndSwitchState(new PlayState());
						FlxG.sound.music.volume = 0;
					});
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

			if (theBirthdayCode == 1)
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

		if (ClientPrefs.shaders)
			darkFilter.setFloat('iTime', elapsed);

		// It actually makes sense since some pepole doesn't know we moved to a new engine or just think we ported the psych editor lol
		/*if (FlxG.keys.justPressed.SEVEN)
		{
			Main.switchState(this, new states.menus.PsychDebugTrollState());
		}
		else if (FlxG.keys.justPressed.EIGHT)
		{
			FlxG.switchState(new GameJoltLogin());
		}
		else if (FlxG.keys.justPressed.NINE)
		{
			FlxG.switchState(new states.menus.CharacterMenu());
		}
		else*/ 


		if (FlxG.keys.justPressed.SEVEN)
		{
			CoolUtil.browserLoad('https://www.youtube.com/watch?v=qj0v0bJiZ18&ab_channel=Xploshi'); // yes.. (Please move it to other state in case it cant be here lol)
		}

		if (FlxG.keys.justPressed.ONE)
		{
			GameData.unlockEverything();
			FlxG.sound.play(Paths.sound('funkinAVI/easterEggSound'));
		}

		if (Math.floor(curSelected) != lastCurSelected)
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

		if (FlxG.mouse.justPressed)
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
			MusicBeatState.switchState(new FreeplayCategories());

			if (GameData.episode1FPLock == 'unlocked' || GameData.muckneyLock == 'beaten')
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
				FlxTween.tween(camGame, {zoom: 6}, 2, {ease: FlxEase.cubeInOut, startDelay: 0.5});

				menuItems.forEach(function(spr:FlxSprite)
				{
					if (curSelected != spr.ID)
					{
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
						FlxFlicker.flicker(spr, 1, flashValue, false, false, function(flick:FlxFlicker)
						{
							switch (daChoice)
							{
								case 'freeplay':
									MusicBeatState.switchState(new FreeplayCategories());
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
					FlxG.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
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
					FlxTween.tween(camGame, {zoom: 6}, 2, {ease: FlxEase.cubeInOut, startDelay: 0.5});
				}
			});
		}
	}

	var lastCurSelected:Int = 0;
	var arrowX:Float = 0;
	var arrowY:Float = 0;

	private function updateSelection()
	{
		// reset all selections
		menuItems.forEach(function(spr:FlxSprite)
		{
			if (!ClientPrefs.shaders)
				spr.shader = null;
			spr.alpha = 0.45;
			spr.updateHitbox();
		});

		if (arrowTween != null)
			arrowTween.cancel();

		if (arrow != null)
		{
			switch (curSelected)
			{
				case 0:
					arrowX = -35;
					arrowY = 60;
				case 1:
					arrowX = 25;
					arrowY = 160;
				case 2:
					arrowX = 35;
					arrowY = 255;
				case 3:
					arrowX = 15;
					arrowY = 355;
			}

			/*arrowTween = FlxTween.tween(arrow, {
				x: arrowX,
				y: arrowY
			}, 0.1, {
				ease: FlxEase.quadOut,
				onComplete: function(twn:FlxTween)
				{
					arrowTween = null;
				}
			});*/
		}

		// don't use <, worst mistake of my carrer
		if (menuItems.members[Math.floor(curSelected)].alpha == 0.45)
		{
			menuItems.members[Math.floor(curSelected)].setColorTransform(1, 1, 1, 1, 0, 0, 0, 0);
			menuItems.members[Math.floor(curSelected)].alpha = 1;
		}

		menuItems.members[Math.floor(curSelected)].updateHitbox();

		lastCurSelected = Math.floor(curSelected);
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
