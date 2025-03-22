package states.menus;

#if desktop
import sys.thread.Thread;
#end
import flash.system.System;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.keyboard.FlxKey;
#if (flixel <= "5.2.2")
	import flixel.system.FlxSound;
#else
	import flixel.sound.FlxSound;
#end
import flixel.system.ui.FlxSoundTray;
import haxe.Json;
import lime.app.Application;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;

import sys.FileSystem;
import sys.io.File;
//import flixel.graphics.FlxGraphic as FlixelGraphic;

class TitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public static var initialized:Bool = false;
	public var camZooming:Bool = false;

	var blackScreen:FlxSprite;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var credGroup:FlxGroup;
	var curWacky:Array<String> = [];

	// goofy ahh fix
	var isTweenCancelled = false;

	var whiteFade:FlxSprite;
	
	var fadeTween:FlxTween;

	var wackyImage:FlxSprite;

	var mustUpdate:Bool = false;

	var gradient:FlxSprite;

	public static var updateVersion:String = '';

	var defaultShader:FlxRuntimeShader;
	var defaultShader2:FlxRuntimeShader;

	var fade:FlxSprite;

	private var windowArray:Array<Any> = [
		"Also try Public Bathroom Simulator",
		"Another Suicide Mouse mod in big 2025",
		"Comically Large Spoon",
		"snas uddertail",
		"K i l l .",
		"Funny Date Fact...",
		"Fun Fact: Beep Bap Brip Skippity Bop",
		"Episode 1 is finally here, WOOOOOO",
		"Sample Text",
		"R.I.P: Shipy's SNS mod",
		"Stfu, I'm playing Minecraft",
		"Stfu, I'm playing Fortnite",
		"Stop asking for suicidal remixes",
		"Why did Everett & Lilith enter these horrific cartoons in the first place?",
		GameData.birthdayLocky == 'beaten' ? "Muckney, realest one out there." : "One of our characters is the realest one out there, but you gotta meet him first!",
		"We late, but we late in style",
		"ur adopted *insert get out sfx*",
		"MOUSE RAP. MOUSE RAP",
		"I'm shutting down your game now, fuck you",
		"How's life, buddy?",
		"mmmm, B E A N S .",
		"Grunt mod is dead.",
		"Vs Dead Bart is cancelled",
		"Funkin.exe is the next WORST thing",
		"Hi, wanna see me glitch?",
		"R.I.P: Welcome Old",
		"POV: You have a joke from 2022 that you edited 3 years later",
		".edud ssarg emos hcuot og ot deen uoy ,das yrev tsuj ,yltsenoh ,das si thaT ?sdrawkcab txet siht fo lla gnidaer otni troffe hcum os gnittup enigamI - iva.niknuF",
		"Play Substance of Happiness!",
		"Now with more depression!",
		"Now with more suicide!",
		"FNAF but with mice",
		"No, we're not doing thicc Lilith fan-service art",
		"i suck at swimming",
		"What the fuck do you mean 'we have a couch song'?",
		"Next Update: Episode 2",
		"I have your IP Address, but i can't put it here because of my limitations",
		"fuckin.mp3 - i juss shat meseff",
		"Subscribe to Dunkin Funkin (haha, yes, shameless advertising)",
		"Fun Fact: S",
		"a",
		" ",
		"What do you want me to say?",
		"I'm running out of things to say here...",
		"This random message serves no purpose to the game or the lore",
		"I feel... ALIVE!",
		"Ah yes, this is a very original and very well thought out message for the game to randomly pick",
		"Stop asking for art of official female versions of the characters in this mod",
		"Help, my basement full of children I kidnapped is screaming, what do I do?",
		"I got uranium up my ass",
		"The horny detector has detected someone here in this game, I wonder who it is...",
		"Fuck you *inverts your game*",
		"MCM is a good mod",
		"h o g .",
		"HOOOG RIDDDAAAAAAAAAAAA *plays Clash Royale loading screen theme*",
		"WE ARE GOING TO BEAT YOU TO DEATH.",
		"X2 Remixes are real.",
		//Community-Made Random Messages
		"A mod about a very unfortunate mouse.",
		"Imagine Having More Than 50 Members?!?!?!",
		"Delusional is in, now STOP ASKING FOR IT",
		"Its been 40 years and the mouse still hasn't regained sanity",
		"freddy fazbear.",
		"We know what to do for V3",
		"Among us is not funny *nerd face*",
		"Discord bots are goofy aaaahhhhh",
		"Whoopsie looks like i gave the suicidal mouse a gun",
		"This is the window title 69, literally", //funi number
		"What the dog doin?",
		"There's a Red Spy in the Base!",
		"fuckin.mp3 - jsjsjsdjdsjdsjadsjjads",
		"Lemon Demon got no iPhone",
		"The Update Y'all were waiting for",
		"Mickey finds the forbidden sandwich",
		"Dev Note: Add a bomb shop link in the messages",
		"We tried our best to improve everything just to prevent hating as much as possible",
		"Go touch grass",
		"Mod Includes: PC Crashing and Banger Songs",
		"What was the square guy's name again?",
		"Let's be honest, Mods are carrying FNF",
		"Let's be honest, the Base Game can't be top'd",
		"Now better than ever!",
		"Over 100+ Messages!",
		"Your childhood friend is back!",
		"Youtube Kids is the best at having totally not bad videos!",
		"People skip this part, let's be honest",
		"when he, when he at the, he at the street, the street next door.",
		"fnf is cancelled go home.", // keeping this one
		"I've entered the mainframe, PREPARE TO LOSE YOUR PC!",
		"I live in your walls.",
		"greggreg my beloved",
		"Send help, I've spent nearly 3 years coding for this mod",
		"You found the Most Difficult message ever!!!1111!1",
		"Congratulations, you won, now get out.",
		"I ate your doorframe now.",
		"Man sure i love when your own mod gets leaked (i don't)",
		"Imagine the credits for the messages",
		"Mickey getting bitches, 100% real no fake",
		"Lets Goku mcdonalds, Y'know what im saiyan?",
		"Walter",
		"Imagine waiting 3 years for a singular Friday Night Funkin' mod update"
		/*"T H E  'C O R E', D E S T R O Y  I T !",
		"THE 'CORE' CONTAINS THE EVIL"*/
	];

	// unlocks debug
    // stolen from full restored lol
	var keyCombo:Array<FlxKey> = [
		FlxKey.UP, FlxKey.UP, FlxKey.DOWN, FlxKey.DOWN, FlxKey.LEFT, FlxKey.RIGHT, FlxKey.LEFT, FlxKey.RIGHT, FlxKey.B, FlxKey.A, FlxKey.ENTER
	];
	var keyIdx = 0;

	var path:String = "Funkin_avi/title";

	override public function create():Void
	{	
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();
		
		#if DISCORD_RPC
		DiscordClient.changePresence("Title Screen", 'Waiting to start...', 'icon', 'clock'); // dw, I'll make sure to update the RPC shit, if anything, I'm gonna end up making a seperate RPC for this version of the engine
		#end

		curWacky = FlxG.random.getObject(getIntroTextShit());

		// DEBUG BULLSHIT
		super.create();

		Application.current.window.title = 'Funkin.avi - ${windowArray[FlxG.random.int(0, windowArray.length-1)]}';
		AppIcon.changeIcon("newIcon");

		defaultShader2 = new FlxRuntimeShader(Shaders.monitorFilter, null, 140);
		if(ClientPrefs.shaders)
			{
				FlxG.camera.setFilters(
					[
						new openfl.filters.ShaderFilter(defaultShader2)
					]);
			}

		curWacky = FlxG.random.getObject(getIntroTextShit());

		#if windows
		backend.windows.CppAPI.darkMode();
        #end

		#if Freeplay
		MusicBeatState.switchState(new FreeplayCategories());
		#end

		startIntro();

		FlxG.mouse.load(Paths.image('UI/funkinAVI/mouses/Hand').bitmap);
		FlxG.mouse.visible = true;

		closedState = false;
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxText;

	function startIntro()
	{
		Conductor.bpm = (50);
		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite();
		bg.loadGraphic(Paths.image('$path/titleSky'), false);
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		var buildings1:FlxBackdrop = new FlxBackdrop(Paths.image('$path/buildings2'), X, 0, 0);
		buildings1.screenCenter();
		buildings1.velocity.set(-250, 0);
		buildings1.antialiasing = ClientPrefs.globalAntialiasing;
		add(buildings1);

		if (!ClientPrefs.lowQuality)
		{
			var blackShit1:FlxBackdrop = new FlxBackdrop(Paths.image('$path/blackShit2'), X, 0, 0);
			blackShit1.screenCenter();
			blackShit1.alpha = 0.47;
			blackShit1.velocity.set(-300, 0);
			blackShit1.antialiasing = ClientPrefs.globalAntialiasing;
			add(blackShit1);

			var dark:FlxSprite = new FlxSprite().loadGraphic(Paths.image('$path/buildingDark'));
			dark.screenCenter();
			dark.antialiasing = ClientPrefs.globalAntialiasing;
			add(dark);
		}

		var buildings2:FlxBackdrop = new FlxBackdrop(Paths.image('$path/buildings1'), X, 0, 0);
		buildings2.screenCenter();
		buildings2.velocity.set(-350, 0);
		buildings2.antialiasing = ClientPrefs.globalAntialiasing;
		add(buildings2);

		if (!ClientPrefs.lowQuality)
		{
			var blackShit2:FlxBackdrop = new FlxBackdrop(Paths.image('$path/blackShit1'), X, 0, 0);
			blackShit2.screenCenter();
			blackShit2.velocity.set(-400, 0);
			blackShit2.antialiasing = ClientPrefs.globalAntialiasing;
			add(blackShit2);
		}

		logoBl = new FlxSprite(150, 0);
		logoBl.loadGraphic(Paths.image(('$path/titleLogo')));
		logoBl.antialiasing = ClientPrefs.globalAntialiasing;
		logoBl.updateHitbox();
		logoBl.setGraphicSize(Std.int(logoBl.width * 0.85));
		logoBl.screenCenter();
		add(logoBl);

		var vignette:FlxSprite = new FlxSprite().loadGraphic(Paths.image('$path/titleVignette'));
		vignette.screenCenter();
		vignette.antialiasing = ClientPrefs.globalAntialiasing;
		add(vignette);

		titleText = new FlxText(24, 600, 1200, "Click Anywhere Or Press Enter to Start", 96);
		titleText.setFormat(Paths.font('MagicOwlFont.otf'), 60, FlxColor.fromRGB(255, 255, 255), CENTER, OUTLINE, FlxColor.BLACK);
		titleText.borderSize = 1.5;
		titleText.antialiasing = ClientPrefs.globalAntialiasing;
		add(titleText);

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		blackScreen.scale.set(FlxG.width * 3, FlxG.height * 3);
		blackScreen.scrollFactor.set();
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "", true);
		credTextShit.screenCenter();

		credTextShit.visible = false;

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		if(FlxG.sound.music == null || FlxG.sound.music.volume == 0) {
			FlxG.sound.playMusic(Paths.music('aviOST/rottenPetals'), 0);

			FlxG.sound.music.fadeIn(4, 0, 0.7);
		}

		whiteFade = new FlxSprite().makeGraphic(1, 1, 0xFFFFFFFF);
		whiteFade.scale.set(FlxG.width * 3, FlxG.height * 3);
		whiteFade.scrollFactor.set();
		whiteFade.alpha = 0;
		add(whiteFade);

		if(!ClientPrefs.lowQuality) {
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
		}
		
		if (initialized)
			skipIntro();
		else
			initialized = true;

		windowFixesAndEvents(); // changes window names, shutting down the game, etc	
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}
	var transitioning:Bool = false;
	private static var playJingle:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null && !closedState)
			Conductor.songPosition = FlxG.sound.music.time;

		var pressedEnter:Bool = FlxG.mouse.justPressed || FlxG.keys.justPressed.ENTER;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		// CHEAT CODE FOR DEBUG MODE
		// DO NOT TELL THIS TO ABSOLUTELY ANYONE ON RELEASE
		if (keyIdx <= keyCombo.length - 1)
		{
			if (FlxG.keys.firstJustPressed() == keyCombo[keyIdx])
			{
				keyIdx++;
				if (keyIdx >= keyCombo.length)
				{
					Main.debug = true;
					FlxG.sound.play(Paths.sound("funkinAVI/easterEggSound"));
				}
			}
			else if (FlxG.keys.firstJustPressed() != FlxKey.NONE)
				keyIdx = 0;
		}

		/**
		 * closing in a cool way
		 */
		if (FlxG.keys.justPressed.ESCAPE && !pressedEnter)
			{
				FlxG.sound.music.fadeOut(3);
				FlxTween.tween(FlxG.sound.music, {pitch: 0.001}, 2.5);
				FlxG.camera.fade(FlxColor.BLACK, 3, false, function()
				{
					Sys.exit(0);
				}, false);
			}

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		// EASTER EGG

		if (initialized && !transitioning && skippedIntro)
		{
			if(pressedEnter)
			{
				FlxG.camera.flash(FlxColor.WHITE, 1);
				FlxG.sound.play(Paths.sound('funkinAVI/menu/selectSfx'), 0.7);

				transitioning = true;

				FlxTween.tween(logoBl, {y: 2000}, 3, {ease: FlxEase.quadIn});
				FlxTween.tween(titleText, {y: 2000}, 3, {ease: FlxEase.quadIn});

				new FlxTimer().start(1.3, function(tmr:FlxTimer){
					closedState = true;
					MusicBeatState.switchState(new MainMenuState());
				});
			}
		}

		if (initialized && pressedEnter && !skippedIntro)
		{
			skipIntro();
		}

		FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, FlxMath.bound(1 - (elapsed * 1.925), 0, 1));
		logoBl.scale.x = FlxMath.lerp(0.85, logoBl.scale.x, FlxMath.bound(1 - (elapsed * 1.995), 0, 1));
		logoBl.scale.y = FlxMath.lerp(0.85, logoBl.scale.y, FlxMath.bound(1 - (elapsed * 1.995), 0, 1));

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>, ?offset:Float = 0)
	{
		for (i in 0...textArray.length)
		{
			var money:FlxText = new FlxText(0, 0, FlxG.width, textArray[i], 52);
			money.setFormat(Paths.font("DisneyFont.ttf"), 52, FlxColor.WHITE, CENTER);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String, ?offset:Float = 0)
	{
		var coolText:FlxText = new FlxText(0, 0, FlxG.width, text, 52);
		coolText.setFormat("assets/fonts/DisneyFont.ttf", 52, FlxColor.WHITE, CENTER);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200;
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	private var sickBeats:Int = 0; //Basically curBeat but won't be skipped if you hold the tab or resize the screen
	public static var closedState:Bool = false;
	override function beatHit()
	{
		super.beatHit();

		if(!closedState) {
			FlxG.camera.zoom += 0.035;

			// logo doesn't have animation, we make one by ourselfs instead
			logoBl.scale.x += 0.03;
			logoBl.scale.y += 0.03;

			sickBeats++;
			switch (sickBeats)
			{
				case 1:
					createCoolText(["Dunkin' Funkin' Team"], 15);
				case 2:
					addMoreText('Presents', 15);
				case 3:
					deleteCoolText();
				case 4:
					createCoolText(['The sights of hell...'], -40);
				case 5:
					addMoreText('..that awaits you.', -40);
				case 6:
					deleteCoolText();
				case 7:
					createCoolText([curWacky[0]]);
				case 8:
					addMoreText(curWacky[1]);
				case 9:
					deleteCoolText();
				case 10:
					addMoreText('Enjoy');
				case 11:
					addMoreText('Your Stay...');
				case 12:
					deleteCoolText();
				case 13:
					addMoreText('Funkin.avi');
				case 14:
					addMoreText('2.0');
				case 15:
					if(!isTweenCancelled)
					fadeTween = FlxTween.tween(whiteFade, {alpha: 1}, 2, {ease: FlxEase.quartInOut});
				case 16:
					if(!isTweenCancelled) {
					fadeTween.cancel();
					whiteFade.alpha = 0;	
					}
					skipIntro();		
				}
		}
	}

	var skippedIntro:Bool = false;
	var increaseVolume:Bool = false;
	function skipIntro():Void
	{
		if (!skippedIntro)
		{
				remove(credGroup);
				FlxG.camera.flash(FlxColor.BLACK, 4);
		}
			logoBl.angle = -4;
			isTweenCancelled = true;
			if (fadeTween != null) fadeTween.cancel();
			whiteFade.alpha = 0;

			new FlxTimer().start(0.01, function(tmr:FlxTimer)
			{
			   if (logoBl.angle == -4)
					FlxTween.angle(logoBl, logoBl.angle, 4, 4, {ease: FlxEase.quartInOut});
			   if (logoBl.angle == 4)
					FlxTween.angle(logoBl, logoBl.angle, -4, 4, {ease: FlxEase.quartInOut});

	        }, 0);

			skippedIntro = true;
	}
	
	function windowFixesAndEvents()
		{
			if(Application.current.window.title.contains("Funkin.avi - Hi, wanna see me glitch?"))
				{
					new FlxTimer().start(3, function(tmr:FlxTimer)
						{
							Application.current.window.title = "Funkin.avi - I'm starting to glitch now, oooooo";
							new FlxTimer().start(3, function(tmr:FlxTimer)
							{
								Application.current.window.title = "Funkin.avi - That's cool, ain't it?";
								new FlxTimer().start(1, function(tmr:FlxTimer)
								{
									Application.current.window.title = "Funkin.avi - Wait...";
									new FlxTimer().start(1, function(tmr:FlxTimer)
									{
										Application.current.window.title = "Funkin.avi - What's going on here?";
										new FlxTimer().start(1, function(tmr:FlxTimer)
										{
											Application.current.window.title = "Funkin.avi - Why am I still glitching?";
											new FlxTimer().start(1, function(tmr:FlxTimer)
											{
												Application.current.window.title = "Funkin.avi - oh no...";
												new FlxTimer().start(1, function(tmr:FlxTimer)
												{
													Application.current.window.title = "Funkin.avi - oh god, oh fuck, PLAYER, PLEASE HELP ME!";
													new FlxTimer().start(1, function(tmr:FlxTimer)
													{
														Application.current.window.title = "Funkin.avi - I BEG OF YOU";
														new FlxTimer().start(1, function(tmr:FlxTimer)
														{
															Application.current.window.title = "Funkin.avi - JUST GO TO THE MAIN MENU ALREADY, I CAN'T STOP AAAAAAAAAAAAAAAAAAAAAAA";
															new FlxTimer().start(1, function(tmr:FlxTimer)
															{
																Application.current.window.title = "Funkin.avi - AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
																new FlxTimer().start(1, function(tmr:FlxTimer)
																{
																	Application.current.window.title = "Funkin.avi - WHAT ARE YOU WAITING FOR??????";
																	new FlxTimer().start(1, function(tmr:FlxTimer)
																	{
																		Application.current.window.title = "Funkin.avi - JUST GO ALREADY, JUST FUCKING PRESS ENTER";
																		new FlxTimer().start(1, function(tmr:FlxTimer)
																		{
																			Application.current.window.title = "Funkin.avi - OH GOD, THE GLITCH IS GETTING WORSE";
																			new FlxTimer().start(1, function(tmr:FlxTimer)
																			{
																				Application.current.window.title = "Funkin.avi - WHY DID I THINK THIS WAS A GOOD IDEA?";
																				new FlxTimer().start(1, function(tmr:FlxTimer)
																				{
																					Application.current.window.title = "Funkin.avi - OH THE MISERY EVERYBODY WANNA BE MY ENEMY MY ENEMY";
																					new FlxTimer().start(1, function(tmr:FlxTimer)
																						{
																							Application.current.window.title = "Funkin.avi - Hi, wanna see me glitch?";
																						});
																				});
																			});
																		});
																	});
																});
															});
														});
													});
												});
											});
										});
									});
								});
							});
						});
				}
				else if(Application.current.window.title.contains("Funkin.avi - I'm shutting down your game now, fuck you"))
					{
						new FlxTimer().start(2, function(tmr:FlxTimer){
							System.exit(0);
						});
					}
				else if(Application.current.window.title.contains('Funkin.avi - Fuck you *inverts your game*'))
				{
					if (ClientPrefs.shaders)
					{
						final invert = new FlxRuntimeShader("#pragma header
						uniform float binaryIntensity;
						uniform float negativity;
						void main(){
							vec2 uv = openfl_TextureCoordv.xy;
							
							// get snapped position
							float psize = 0.04 * binaryIntensity;
							float psq = 1.0 / psize;
							float px = floor(uv.x * psq + 0.5) * psize;
							float py = floor(uv.y * psq + 0.5) * psize;
							
							vec4 colSnap = texture2D(bitmap, vec2(px, py));
							
							float lum = pow(1.0 - (colSnap.r + colSnap.g + colSnap.b) / 3.0, binaryIntensity);
							
							float qsize = psize * lum;
							float qsq = 1.0 / qsize;
							float qx = floor(uv.x * qsq + 0.5) * qsize;
							float qy = floor(uv.y * qsq + 0.5) * qsize;
							float rx = (px - qx) * lum + uv.x;
							float ry = (py - qy) * lum + uv.y;
							vec4 color = flixel_texture2D(bitmap, vec2(rx, ry));
							gl_FragColor = mix(color, vec4(1.0 - color.r, 1.0 - color.g, 1.0 - color.b, color.a) * color.a, negativity);
						}", null, 120);
						invert.setFloat('binaryIntensity', 1000);
						FlxG.game.setFilters([new ShaderFilter(invert)]);
						FlxTween.num(0, 1, .5, null, num -> invert.setFloat('negativity', num));
					}
					else
					{
						Application.current.window.title = 'Funkin.avi - ${windowArray[FlxG.random.int(0, windowArray.length-1)]}';
						windowFixesAndEvents();
					}
				}	
				else if(Application.current.window.title.contains("Funkin.avi - .edud ssarg emos hcuot og ot deen uoy ,das yrev tsuj ,yltsenoh ,das si thaT ?sdrawkcab txet siht fo lla gnidaer otni troffe hcum os gnittup enigamI - iva.niknuF"))
					{
						Application.current.window.title = ".edud ssarg emos hcuot og ot deen uoy ,das yrev tsuj ,yltsenoh ,das si thaT ?sdrawkcab txet siht fo lla gnidaer otni troffe hcum os gnittup enigamI - iva.niknuF";
					}
				else if(Application.current.window.title.contains("Funkin.avi - fuckin.mp3 - jsjsjsdjdsjdsjadsjjads"))
					{
						Application.current.window.title = "fuckin.mp3 - jsjsjsdjdsjdsjadsjjads";
					}
				else if(Application.current.window.title.contains('Funkin.avi - fuckin.mp3 - i juss shat meseff'))
					{
						Application.current.window.title = "fuckin.mp3 - i juss shat meseff";
					}
				else if(Application.current.window.title.contains("Funkin.avi -  "))
					{
						Application.current.window.title = " ";
					}
					else if(Application.current.window.title.contains('Funkin.avi - Funny Date Fact...'))
						{
							// this one's special because we gotta prevent spoilers for the newies
							if (GameData.tgLock == 'locked' && GameData.blessLock == 'locked')
								Application.current.window.title = "Funkin.avi - Two of our characters are dating, this is canon.";
							else if (GameData.tgLock == 'locked' && GameData.blessLock == 'beaten')
								Application.current.window.title = "Funkin.avi - A Special Guest & White Noise are dating, this is canon.";
							if (GameData.tgLock == 'beaten' && GameData.blessLock == 'locked')
								Application.current.window.title = "Funkin.avi - Mr. Smiles & A Special Guest are dating, this is canon.";
							else Application.current.window.title = "Funkin.avi - Mr. Smiles & White Noise are dating, this is canon.";
						}
		}
}