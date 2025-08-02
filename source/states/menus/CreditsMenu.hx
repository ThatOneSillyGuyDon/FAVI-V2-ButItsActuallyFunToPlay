package states.menus;

import flixel.text.FlxText.FlxTextFormat;
import flixel.text.FlxText.FlxTextFormatMarkerPair;
import haxe.Json;
import openfl.filters.ShaderFilter;
import sys.io.File;
/** Credit shit or smth !!

How it Works:

* [Name of Contributor, Icon, Work They've Done, Description/Quote, X Value of Icon, Y Value of Icon, Size of Icon, Bool for in case someone has a stupidly long description]
*/
typedef CreditStuff = {
	devs:Array<Dynamic>
}

class CreditsMenu extends MusicBeatState
{
	public static var creditArray:Array<Dynamic>;

	var curSelected:Int = 0;

	var creditIconSprite:FlxSprite;
	var creditDescText:FlxText;
	var creditNameText:FlxText;
	var creditWorkText:FlxText;
	var backdrop:FlxBackdrop;

	var background:FlxSprite;
	var dark:FlxSprite;
	var box:FlxSprite;
	var boxOverlay:FlxSprite;
	var daStrip:FlxSprite;
	var creditIconText:FlxSprite;
	var teelSquares:FlxSprite;

	var cool_1980_shader:FlxRuntimeShader;

	var upArrow:FlxText;
	var downArrow:FlxText;
	
	var maxLength = 1;

	var path:String;

	var daJson:String = null;
	var creditThing:CreditStuff;

	var redTextMarker = new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.RED, true, true), '^red^');
	var demosSigmaBlueThing = new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.fromRGB(38, 168, 255), true, true), '^demo^');

	var fuckingCameraSoTheMenuDoesntFuckUpOrWhateverCauseFlixelIsEVIL:FlxCamera;

	override function create()
	{
		fuckingCameraSoTheMenuDoesntFuckUpOrWhateverCauseFlixelIsEVIL = new FlxCamera();

		FlxG.cameras.reset(fuckingCameraSoTheMenuDoesntFuckUpOrWhateverCauseFlixelIsEVIL);
		FlxG.cameras.setDefaultDrawTarget(fuckingCameraSoTheMenuDoesntFuckUpOrWhateverCauseFlixelIsEVIL, true);

		openfl.Lib.application.window.title = "Funkin.avi - Credits";

		path = 'Funkin_avi/credits';
		
		DiscordClient.changePresence('Credits', 'Look at all these cool people!', 'icon', 'book');

		FlxG.sound.playMusic(Paths.music('aviOST/curtainCall'));

		//Conductor.bpm = (164);

		persistentUpdate = true;

		creditThing = jsonStuff();
		creditArray = creditThing.devs;

		background = new FlxSprite().loadGraphic(Paths.image('$path/theLight'));
		background.screenCenter();
		background.antialiasing = ClientPrefs.globalAntialiasing;
		add(background);
		FlxTween.tween(background, {alpha: 0.25}, 2, {ease: FlxEase.expoInOut, type: PINGPONG});

		// thank you shadow mario fnf
		backdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0xFFFFFF, 0x33FFFFFF));
		backdrop.velocity.set(40, 40);
		backdrop.alpha = 0;
		backdrop.setGraphicSize(Std.int(backdrop.width * 0.6));
		FlxTween.tween(backdrop, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
		backdrop.antialiasing = ClientPrefs.globalAntialiasing;
		add(backdrop);

		dark = new FlxSprite().loadGraphic(Paths.image('$path/darkness'));
		dark.screenCenter();
		dark.antialiasing = ClientPrefs.globalAntialiasing;
		add(dark);

		daStrip = new FlxSprite().loadGraphic(Paths.image('$path/filmstrip'));
		daStrip.screenCenter();
		daStrip.antialiasing = ClientPrefs.globalAntialiasing;
		add(daStrip);

		box = new FlxSprite().loadGraphic(Paths.image('$path/iconFrame'));
		box.screenCenter();
		box.antialiasing = ClientPrefs.globalAntialiasing;
		add(box);

		teelSquares = new FlxSprite().loadGraphic(Paths.image('$path/teelbeSpecial'));
		teelSquares.screenCenter().x -= 120;
		teelSquares.setGraphicSize(Std.int(box.width * 0.6));
		teelSquares.antialiasing = ClientPrefs.globalAntialiasing;
		teelSquares.alpha = 0;
		add(teelSquares);

		upArrow = new FlxText(270, 100, 0, ">");
		upArrow.setFormat(Paths.font('disneyFreeplayFont.ttf'), 120, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		upArrow.angle = -90;
		upArrow.borderSize = 3;
		add(upArrow);

		downArrow = new FlxText(250, 500, 0, ">");
		downArrow.setFormat(Paths.font('disneyFreeplayFont.ttf'), 120, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		downArrow.angle = 90;
		downArrow.borderSize = 3;
		add(downArrow);

		creditDescText = new FlxText(FlxG.width * 0.52, FlxG.height * 0.6, 500, creditArray[curSelected][3]);
		creditDescText.setFormat(Paths.font('disneyFreeplayFont.ttf'), 40, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		creditDescText.borderSize = 1.3;
		creditDescText.antialiasing = ClientPrefs.globalAntialiasing;
		add(creditDescText);

		creditNameText = new FlxText(FlxG.width * 0.22, FlxG.height * 0.3, FlxG.width, creditArray[curSelected][0]);
		creditNameText.setFormat(Paths.font('Oceanic_Cocktail_Demo.otf'), 70, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		creditNameText.borderSize = 1.3;
		creditNameText.antialiasing = ClientPrefs.globalAntialiasing;
		add(creditNameText);

		creditWorkText = new FlxText(FlxG.width * 0.52, FlxG.height * 0.41, 500, creditArray[curSelected][2]);
		creditWorkText.setFormat(Paths.font('MagicOwlFont.otf'), 30, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		creditWorkText.borderSize = 1.3;
		creditWorkText.antialiasing = ClientPrefs.globalAntialiasing;
		add(creditWorkText);

		creditIconSprite = new FlxSprite(creditArray[curSelected][4],
			creditArray[curSelected][5]).loadGraphic(Paths.image('$path/icons/${creditArray[curSelected][1]}'));
		creditIconSprite.setGraphicSize(Std.int(creditIconSprite.width * creditArray[curSelected][6]));
		creditIconSprite.antialiasing = ClientPrefs.globalAntialiasing;
		add(creditIconSprite);

		boxOverlay = new FlxSprite().loadGraphic(Paths.image('$path/frameOverlay'));
		boxOverlay.screenCenter();
		boxOverlay.antialiasing = ClientPrefs.globalAntialiasing;
		add(boxOverlay);

		cool_1980_shader = new FlxRuntimeShader(Shaders.vhsFilter, null, 130);
		var monitor = new FlxRuntimeShader(Shaders.monitorFilter, null, 140);

		if (ClientPrefs.shaders)
			fuckingCameraSoTheMenuDoesntFuckUpOrWhateverCauseFlixelIsEVIL.setFilters([
				//new ShaderFilter(cool_1980_shader), // yeah so like no offense im very sorry but it isn't really readable AT ALL, you can uncomment if you want to idm
				new ShaderFilter(monitor)
			]);

		if (!ClientPrefs.lowQuality)
		{
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

		changeSelection();
		super.create();
	}

	var shaderTime:Float = 0;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		// dont mind me adding this funny
		// yes i used the numbers because why not
		FlxG.camera.shake(creditArray[curSelected][0].toLowerCase() == "malyplus" ? 0.01 : 0);
		Conductor.songPosition = FlxG.sound.music != null ? FlxG.sound.music.time : 0;

		teelSquares.alpha = FlxMath.lerp(creditArray[curSelected][0].toLowerCase() == "teelbe" ? FlxG.random.float(.2, 1) : 0, teelSquares.alpha, .85);

		upArrow.y = FlxMath.lerp(100, upArrow.y, CoolUtil.boundTo(1 - (elapsed * 15), 0, 1));
		downArrow.y = FlxMath.lerp(500, downArrow.y, CoolUtil.boundTo(1 - (elapsed * 15), 0, 1));

		if (ClientPrefs.shaders)
			cool_1980_shader.setFloat('time', Conductor.songPosition / 1000);

		if (controls.UI_UP_P)
		{
			changeSelection(-1);
			upArrow.y -= 25;
		}
		else if (controls.UI_DOWN_P)
		{
			changeSelection(1);
			downArrow.y += 25;
		}

		if (controls.BACK)
		{
			MusicBeatState.switchState(new MainMenuState());
			Conductor.bpm = (50); // changes back to titlescreen bpm
			FlxG.sound.playMusic(Paths.music('aviOST/rottenPetals'), 1); // resets music back to menu music
			FlxG.sound.music.fadeIn();
		}

		if(FlxG.mouse.wheel != 0)
			changeSelection(-1 * FlxG.mouse.wheel);
	}

	override function destroy()
	{
		super.destroy();
	}

	function jsonStuff()
	{
		//daJson = MiscShit.creditsMenu;
		daJson = File.getContent(Paths.getPath('data/credits.json', TEXT, null));

		if (daJson != null && daJson.length > 0) {
			return cast Json.parse(daJson);
		}

		return null;
	}

	private function changeSelection(newSelect:Int = 0)
	{
		curSelected += newSelect;
		if (curSelected < 0)
			curSelected = creditArray.length - 1;
		if (curSelected >= creditArray.length)
			curSelected = 0;

		creditNameText.text = creditArray[curSelected][0] != null ? creditArray[curSelected][0] : 'unknown';
		creditDescText.text = creditArray[curSelected][3] != null ? creditArray[curSelected][3] : 'unknown';
		creditDescText.applyMarkup(creditDescText.text, [redTextMarker, demosSigmaBlueThing]);
		creditWorkText.text = creditArray[curSelected][2] != null ? creditArray[curSelected][2] : 'has not worked';
		creditIconSprite.loadGraphic(Paths.image('$path/icons/${creditArray[curSelected][1]}'));
		creditIconSprite.setGraphicSize(Std.int(creditIconSprite.width * creditArray[curSelected][6]));
		creditIconSprite.setPosition(creditArray[curSelected][4], creditArray[curSelected][5]);

		FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'), 0.6);

		reloadText(creditArray[curSelected][7]);

		//trace('huh: credits edition');
	}

	@:noCompletion
	private function reloadText(long)
	{
		if (long)
		{
			switch (creditArray[curSelected][0].toLowerCase())
			{
				case 'domingo' | 'retrojogador':
					creditNameText.y = FlxG.height * 0.1;
					creditWorkText.y = FlxG.height * 0.21;
					creditDescText.fieldWidth = 1000;
					creditDescText.x = FlxG.width * 0.32;
					creditDescText.y = FlxG.height * 0.195;
					creditDescText.scale.set(0.6, 0.6);

				case 'writer anon':
					creditNameText.y = FlxG.height * 0.1;
					creditWorkText.y = FlxG.height * 0.21;
					creditDescText.fieldWidth = 1000;
					creditDescText.x = FlxG.width * 0.32;
					creditDescText.y = FlxG.height * 0.2;
					creditDescText.scale.set(0.6, 0.6);

				case 'yama haki / toko':
					creditNameText.y = FlxG.height * 0.02;
					creditWorkText.y = FlxG.height * 0.11;
					creditDescText.fieldWidth = 1080;
					creditDescText.x = FlxG.width * 0.28;
					creditDescText.y = FlxG.height * -0.12;
					creditDescText.scale.set(0.5, 0.5);

				case 'purg':
					creditNameText.y = FlxG.height * 0.06;
					creditWorkText.y = FlxG.height * 0.15;
					creditDescText.fieldWidth = 1000;
					creditDescText.x = FlxG.width * 0.32;
					creditDescText.y = FlxG.height * -0.02;
					creditDescText.scale.set(0.6, 0.6);

				default:
					creditNameText.y = FlxG.height * 0.1;
					creditWorkText.y = FlxG.height * 0.21;
					creditDescText.fieldWidth = 1000;
					creditDescText.x = FlxG.width * 0.32;
					creditDescText.y = FlxG.height * 0.16;
					creditDescText.scale.set(0.6, 0.6);
			}
		}
		else
		{ // reload reasons
			switch (creditArray[curSelected][0].toLowerCase())
			{
				case 'thatonesillyguy // don':
					creditDescText.fieldWidth = 500;
					creditDescText.x = FlxG.width * 0.52;
					creditDescText.y = FlxG.height * 0.5;
					creditDescText.scale.set(1, 1);
					creditNameText.y = FlxG.height * 0.3;
					creditWorkText.y = FlxG.height * 0.41;
					creditDescText.scale.set(0.8, 0.8);

				case 'jason':
					creditDescText.fieldWidth = 500;
					creditDescText.x = FlxG.width * 0.52;
					creditDescText.y = FlxG.height * 0.5;
					creditDescText.scale.set(1, 1);
					creditNameText.y = FlxG.height * 0.3;
					creditWorkText.y = FlxG.height * 0.41;

				default:
					creditDescText.fieldWidth = 500;
					creditDescText.x = FlxG.width * 0.52;
					creditDescText.y = FlxG.height * 0.6;
					creditDescText.scale.set(1, 1);
					creditNameText.y = FlxG.height * 0.3;
					creditWorkText.y = FlxG.height * 0.41;
			}
		}
	}
}
