package states.options;

import flash.text.TextField;
import lime.utils.Assets;
import haxe.Json;
import flixel.input.keyboard.FlxKey;

class OptionsState extends MusicBeatState
{
	var options:Array<String> = [
		'Preferences',
		'Graphics',
		'Gameplay',
		'Controls'
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
			case 'Graphics':
					openSubState(new GraphicsSettingsSubState());
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

	var shit:FlxText;

	override function create()
	{
		#if desktop
		DiscordClient.changePresence("Options Menu", "Changing settings...", "icon", "gear");
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

		if (!ClientPrefs.lowQuality)
		{
			var gradient:FlxSprite = new FlxSprite().loadGraphic(Paths.image('Funkin_avi/filters/gradient'));
			gradient.scrollFactor.set(0, 0);
			gradient.setGraphicSize(Std.int(gradient.width * 0.75));
			gradient.updateHitbox();
			gradient.screenCenter();
			gradient.antialiasing = true;
			gradient.scale.x += .1;
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

		shit = new FlxText(0, FlxG.height * 0.1, 0);
		shit.setFormat(Paths.font("disneyFreeplayFont.ttf"), 40, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		add(shit);

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

		if (controls.UI_LEFT_P)
		{
			changeSelection(-1);
		}
		if (controls.UI_RIGHT_P)
		{
			changeSelection(1);
		}

		if (FlxG.mouse.justPressed)
		{
			if (FlxG.mouse.overlaps(art))
			{
				openSelectedSubstate(options[curSelected]);
			}
		}

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState((FAVIPauseSubState.toOptions ? new PlayState() : new MainMenuState()));
			if (FAVIPauseSubState.toOptions)
			{
				FlxG.mouse.visible = false;
				FAVIPauseSubState.toOptions = false;
			}
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
		shit.text = '< ${options[curSelected]} >';
		shit.x = (FlxG.width - shit.width) * .5;

		switch (curSelected)
		{
			case 0:
				art.setPosition(((FlxG.width - art.width) / 2) + 150, ((FlxG.height - art.height) / 2) + 200);
				art.scale.set(.7, .7);
				art.updateHitbox();
				art.screenCenter();
				art.y += 100;
			case 1:
				art.setPosition(((FlxG.width - art.width) / 2) + 170, ((FlxG.height - art.height) / 2) + 170);
				art.scale.set(.35, .35);
				art.updateHitbox();
				art.screenCenter();
				art.y += 100;
			case 2:
				art.setPosition(((FlxG.width - art.width) / 2) + 150, ((FlxG.height - art.height) / 2) + 200);
				art.scale.set(.35, .35);
				art.updateHitbox();
				art.screenCenter();
				art.y += 100;

			default:
				art.setPosition(((FlxG.width - art.width) / 2) + 150, ((FlxG.height - art.height) / 2) + 200);
				art.scale.set(.5, .5);
				art.updateHitbox();
				art.screenCenter();
				art.y += 100;
		}

		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}