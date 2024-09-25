package states.options;

import flash.text.TextField;
import lime.utils.Assets;
import haxe.Json;
import flixel.input.keyboard.FlxKey;

class OptionsState extends MusicBeatState
{
	var options:Array<String> = [
		'Preferences',
		'Controls',
		'Gameplay',
	];

	private static var curSelected:Int = 0;
	public static var menuBG:FlxSprite;
	var dogshitPath:String = 'Funkin_avi/options';

	function openSelectedSubstate(label:String)
	{
		switch (label)
		{
			case 'Preferences':
				openSubState(new VisualsUISubState());
			case 'Controls':
				openSubState(new ControlsSubState());
			case 'Gameplay':
				openSubState(new GameplaySettingsSubState());
		/*	case 'Note Colors':
				openSubState(new NotesSubState());
			case 'Controls':
				openSubState(new ControlsSubState());
			case 'Graphics':
				openSubState(new GraphicsSettingsSubState());
			case 'Gameplay':
				openSubState(new GameplaySettingsSubState());
			case 'Adjust Delay and Combo':
				LoadingState.loadAndSwitchState(new NoteOffsetState());*/
		}
	}

	var selectorLeft:FlxSprite;
	var selectorRight:FlxSprite;

	var art:FlxSprite;
	var optionText:FlxSprite;

	var iForgot:FlxSprite;

	override function create()
	{
		#if desktop
		DiscordClient.changePresence("Options Menu", null);
		#end

		FlxG.stage.window.title = "Funkin.avi - Settings";

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('$dogshitPath/background'));
		bg.setGraphicSize(FlxG.width, FlxG.height);
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		art = new FlxSprite().loadGraphic(Paths.image('$dogshitPath/art_${options[curSelected].toLowerCase()}'));
		art.scale.set(.7, .7);
		art.updateHitbox();
		art.screenCenter();
		art.y += 100;
		art.antialiasing = ClientPrefs.globalAntialiasing;
		add(art);

		optionText = new FlxSprite(0, 0, Paths.image('$dogshitPath/icon_${options[curSelected].toLowerCase()}'));
		optionText.screenCenter();
		optionText.scale.set(.64, .64);
		optionText.y -= 200;
		optionText.antialiasing = ClientPrefs.globalAntialiasing;
		add(optionText);

		selectorLeft = new FlxSprite(optionText.x - 20, 70).loadGraphic(Paths.image('$dogshitPath/arrow'));
		//selectorLeft.y -= 50;
		selectorLeft.scale.set(.6, .6);
		selectorLeft.antialiasing = ClientPrefs.globalAntialiasing;
		add(selectorLeft);

		selectorRight = new FlxSprite(optionText.x + optionText.width - 190, 70).loadGraphic(Paths.image('$dogshitPath/arrow'));
		//selectorRight.y -= 50;
		selectorRight.scale.set(.6, .6);
		selectorRight.antialiasing = ClientPrefs.globalAntialiasing;
		selectorRight.flipX = true;
		add(selectorRight);
		
		var graphic:FlxSprite = new FlxSprite().loadGraphic(Paths.image('$dogshitPath/IMG_1017'));
		graphic.setGraphicSize(FlxG.width + 20, FlxG.height);
		graphic.updateHitbox();
		graphic.screenCenter();
		graphic.antialiasing = ClientPrefs.globalAntialiasing;
		add(graphic);

		var graphic:FlxSprite = new FlxSprite().loadGraphic(Paths.image('$dogshitPath/Untitled1595_20240710134131'));
		graphic.setGraphicSize(FlxG.width + 20, FlxG.height);
		graphic.updateHitbox();
		graphic.screenCenter();
		graphic.antialiasing = ClientPrefs.globalAntialiasing;
		add(graphic);

		if (!ClientPrefs.lowQuality)
		{
			var gradient:FlxSprite = new FlxSprite().loadGraphic(Paths.image('Funkin_avi/filters/gradient'));
			gradient.scrollFactor.set(0, 0);
			gradient.setGraphicSize(Std.int(gradient.width * 0.75));
			gradient.updateHitbox();
			gradient.screenCenter();
			gradient.antialiasing = true;
			add(gradient);

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

		curSelected = 0;

		var wip:FlxText = new FlxText(0, FlxG.height * 0.95, 0, "This menu is NOT finished yet! Expect some obvious bugs!", 32);
		wip.setFormat(Paths.font("disneyFreeplayFont.ttf"), 15, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		add(wip);

		changeSelection();
		ClientPrefs.saveSettings();

		super.create();
	}

	override function closeSubState()
	{
		super.closeSubState();
		ClientPrefs.saveSettings();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		selectorLeft.scale.set(FlxMath.lerp(.6, selectorLeft.scale.x, FlxMath.bound(1 - (elapsed * 3), 0, 1)), FlxMath.lerp(.6, selectorLeft.scale.y, FlxMath.bound(1 - (elapsed * 3), 0, 1)));
		selectorRight.scale.set(FlxMath.lerp(.6, selectorRight.scale.x, FlxMath.bound(1 - (elapsed * 3), 0, 1)), FlxMath.lerp(.6, selectorRight.scale.y, FlxMath.bound(1 - (elapsed * 3), 0, 1)));

		if (controls.UI_LEFT_P)
		{
			changeSelection(-1);
			selectorLeft.scale.set(.5, .5);
		}
		if (controls.UI_RIGHT_P)
		{
			changeSelection(1);
			selectorRight.scale.set(.5, .5);
		}

		if (FlxG.mouse.justPressed)
		{
			if (FlxG.mouse.overlaps(selectorLeft))
			{
				changeSelection(-1);
				selectorLeft.scale.set(.5, .5);
			}
			else if (FlxG.mouse.overlaps(selectorRight))
			{
				changeSelection(1);
				selectorRight.scale.set(.5, .5);
			}
			else if (FlxG.mouse.overlaps(art))
			{
				openSelectedSubstate(options[curSelected]);
			}
		}

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState((FAVIPauseSubState.toOptions ? new PlayState() : new MainMenu()));
			if (FAVIPauseSubState.toOptions)
				FAVIPauseSubState.toOptions = false;
		}

		if (controls.ACCEPT)
		{
			openSelectedSubstate(options[curSelected]);
		}
	}

	function changeSelection(change:Int = 0)
	{
		curSelected = FlxMath.wrap(curSelected + change, 0, options.length - 1);

		art.loadGraphic(Paths.image('$dogshitPath/art_${options[curSelected].toLowerCase()}'));
		optionText.loadGraphic(Paths.image('$dogshitPath/icon_${options[curSelected].toLowerCase()}'));

		selectorLeft.x = optionText.x - 20;
		selectorRight.x = optionText.x + optionText.width - 190;

		switch (curSelected)
		{
			case 1:
				art.setPosition(((FlxG.width - art.width) / 2) + 170, ((FlxG.height - art.height) / 2) + 170);

			default:
				art.setPosition(((FlxG.width - art.width) / 2) + 150, ((FlxG.height - art.height) / 2) + 200);
		}

		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}