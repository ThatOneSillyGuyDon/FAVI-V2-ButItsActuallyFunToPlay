package states.options;

import flash.text.TextField;
import lime.utils.Assets;
import haxe.Json;
import flixel.input.keyboard.FlxKey;

class OptionsState extends MusicBeatState
{
	var options:Array<String> = [
		'Preferences',
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
		graphic.setGraphicSize(FlxG.width, FlxG.height);
		graphic.updateHitbox();
		graphic.screenCenter();
		graphic.antialiasing = ClientPrefs.globalAntialiasing;
		add(graphic);

		var graphic:FlxSprite = new FlxSprite().loadGraphic(Paths.image('$dogshitPath/Untitled1595_20240710134131'));
		graphic.setGraphicSize(FlxG.width, FlxG.height);
		graphic.updateHitbox();
		graphic.screenCenter();
		graphic.antialiasing = ClientPrefs.globalAntialiasing;
		add(graphic);

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
			selectorLeft.scale.set(.55, .55);
		}
		if (controls.UI_RIGHT_P)
		{
			changeSelection(1);
			selectorRight.scale.set(.55, .55);
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
