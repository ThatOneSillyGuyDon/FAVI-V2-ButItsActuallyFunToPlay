package states.options;

import flash.text.TextField;
import lime.utils.Assets;
import haxe.Json;
import flixel.input.keyboard.FlxKey;

class VisualsUISubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Visuals and UI';
		rpcTitle = 'Visuals & UI Settings Menu'; //for Discord Rich Presence

		var option:Option = new Option('Language',
			"Choose your language (Languages that aren't english don't affect on images!)",
			'language',
			'string',
			['English', 'Español']);
		addOption(option);

		var option:Option = new Option('Note Splashes',
			"If unchecked, hitting \"Sick!\" notes won't show particles.",
			'noteSplashes',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Hide HUD',
			'If checked, hides most HUD elements.',
			'hideHud',
			'bool',
			false);
		addOption(option);
		
		var option:Option = new Option('Flashing Lights',
			"Uncheck this if you're sensitive to flashing lights!",
			'flashing',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Epilepsy',
			"Uncheck this to reduce amount of flashing lights!",
			'epilepsy',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Shaders', //Name
		'If unchecked, disables shaders.\nIt\'s used for some visual effects, and also CPU intensive for weaker PCs.', //Description
		'shaders', //Save data variable name
		'bool', //Variable type
		true); //Default value
		addOption(option);

		var option:Option = new Option('Anti-Aliasing',
		'If unchecked, disables anti-aliasing, increases performance\nat the cost of sharper visuals.',
		'globalAntialiasing',
		'bool',
		true);
		option.showBoyfriend = true;
		option.onChange = onChangeAntiAliasing; //Changing onChange is only needed if you want to make a special interaction after it changes the value
		addOption(option);

		var option:Option = new Option('Camera Zooms',
			"If unchecked, the camera won't zoom in on a beat hit.",
			'camZooms',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Score Text Zoom on Hit',
			"If unchecked, disables the Score text zooming\neverytime you hit a note.",
			'scoreZoom',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Health Bar Transparency',
			'How much transparent should the health bar and icons be.',
			'healthBarAlpha',
			'percent',
			1);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);

		var option:Option = new Option('GPU Caching', // Name
			"If checked, your GPU's VRAM can be used to store some textures.\nOnly enable if you have a good graphics card!", // Description
			'useGPUCaching', // Save data variable name
			'bool', // Variable type
			false); // Default value
		addOption(option);
		
		#if !mobile
		var option:Option = new Option('FPS Counter',
			'If unchecked, hides FPS Counter.',
			'showFPS',
			'bool',
			true);
		addOption(option);
		option.onChange = onChangeFPSCounter;

		var option:Option = new Option('Show Debug Info',
			'If checked, adds additional information to the framerate counter (memory and mod version).',
			'debugInfo',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Framerate',
		"Pretty self explanatory, isn't it?",
		'framerate',
		'int',
		60);
		addOption(option);

		option.minValue = 60;
		option.maxValue = 240;
		option.displayFormat = '%v';
		option.onChange = onChangeFramerate;
		#end

		var option:Option = new Option('Combo Stacking',
			"If unchecked, Ratings and Combo won't stack, saving on System Memory and making them easier to read",
			'comboStacking',
			'bool',
			true);
		addOption(option);

		super();
	}

	#if !mobile
	function onChangeFPSCounter()
	{
		if(Main.fpsVar != null)
			Main.fpsVar.visible = ClientPrefs.showFPS;
	}

	function onChangeFramerate()
	{
		if(ClientPrefs.framerate > FlxG.drawFramerate)
		{
			FlxG.updateFramerate = ClientPrefs.framerate;
			FlxG.drawFramerate = ClientPrefs.framerate;
		}
		else
		{
			FlxG.drawFramerate = ClientPrefs.framerate;
			FlxG.updateFramerate = ClientPrefs.framerate;
		}
	}
	#end

	function onChangeAntiAliasing()
		{
			for (sprite in members)
			{
				var sprite:Dynamic = sprite; //Make it check for FlxSprite instead of FlxBasic
				var sprite:FlxSprite = sprite; //Don't judge me ok
				if(sprite != null && (sprite is FlxSprite) && !(sprite is FlxText)) {
					sprite.antialiasing = ClientPrefs.globalAntialiasing;
				}
			}
		}
}
