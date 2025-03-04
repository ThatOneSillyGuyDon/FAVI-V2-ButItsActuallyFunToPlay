package backend;

import haxe.Timer;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFormat;
import flixel.math.FlxMath;
#if gl_stats
import openfl.display._internal.stats.Context3DStats;
import openfl.display._internal.stats.DrawCallContext;
#end
#if flash
import openfl.Lib;
#end

#if openfl
import openfl.system.System;
#end

/**
	The FPS class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
**/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class Framerate extends TextField
{
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var currentFPS(default, null):Float;

	public var curMemory:Float;
	public var peakMemory:Float;
	public var realAlpha:Float = 1;
	public var lagging:Bool = false;
	public var forceUpdateText(default, set):Bool = false;
	public var font:String = '';

	@:noCompletion private var cacheCount:Int;
	@:noCompletion private var currentTime:Float;
	@:noCompletion private var times:Array<Float>;

	public function new(x:Float = 10, y:Float = 10)
	{
		super();

		this.x = x;
		this.y = y;

		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat(openfl.utils.Assets.getFont("assets/fonts/disneyFreeplayFont.ttf").fontName /*your standards are lame Jason lol*/, 12, 0xFFFFFF);
		font = openfl.utils.Assets.getFont("assets/fonts/disneyFreeplayFont.ttf").fontName;
		autoSize = LEFT;
		multiline = true;
		text = "FPS: ";

		cacheCount = 0;
		currentTime = 0;
		times = [];

		#if flash
		addEventListener(Event.ENTER_FRAME, function(e)
		{
			var time = Lib.getTimer();
			__enterFrame(time - currentTime);
		});
		#end
	}

	// Event Handlers
	@:noCompletion
	private #if !flash override #end function __enterFrame(deltaTime:Float):Void
	{
		currentTime += deltaTime;
		times.push(currentTime);

		while (times[0] < currentTime - 1000)
		{
			times.shift();
		}

		var aggressor:Float = 1;

		var currentCount = times.length;
		currentFPS = (currentCount + cacheCount) / 2;

		if (currentFPS > ClientPrefs.framerate) currentFPS = ClientPrefs.framerate;

		if (currentCount != cacheCount /*&& visible*/)
		{
			updateText();
		}

		cacheCount = currentCount;
	}

	private function set_forceUpdateText(value:Bool):Bool
		{
			updateText();
			return value;
		}
	
	private function updateText():Void
	{
		text = "FPS: " + Math.round(currentFPS);

		var ms:Float = FlxG.elapsed;
		ms *= 1000;

		lagging = false;

		// why am I doing this? well, why tf not? (don)
		// can't complain brah
		switch (Type.getClass(FlxG.state))
		{
			case PlayState:
				switch (PlayState.SONG.song)
				{
					case "Birthday":
						if (font != openfl.utils.Assets.getFont("assets/fonts/spunchBobs.otf").fontName)
						{
							setTextFormat(new TextFormat(openfl.utils.Assets.getFont("assets/fonts/spunchBobs.otf").fontName, 10, 0xFFD1D1D1));
							font = openfl.utils.Assets.getFont("assets/fonts/spunchBobs.otf").fontName;
						}
					case "Malfunction":
						if (font != openfl.utils.Assets.getFont("assets/fonts/Retro Gaming.ttf").fontName)
						{
							setTextFormat(new TextFormat(openfl.utils.Assets.getFont("assets/fonts/Retro Gaming.ttf").fontName, 9, 0x292929));
							font = openfl.utils.Assets.getFont("assets/fonts/Retro Gaming.ttf").fontName;
						}
					case "Isolated Beta" | "Isolated Old" | "Isolated Legacy" | "Lunacy Legacy" | "Delusional Legacy" | "Hunted Legacy" | "Twisted Grins Legacy" | "Mercy Legacy" | "Cycled Sins Legacy" | "Malfunction Legacy":
						if (font != "_sans")
						{
							setTextFormat(new TextFormat("_sans", 12, 0xFFD1D1D1));
							font = "_sans";
						}
					default:
						if (font != openfl.utils.Assets.getFont("assets/fonts/disneyFreeplayFont.ttf").fontName)
						{
							setTextFormat(new TextFormat(openfl.utils.Assets.getFont("assets/fonts/disneyFreeplayFont.ttf").fontName, 12, 0xFFD1D1D1));
							font = openfl.utils.Assets.getFont("assets/fonts/disneyFreeplayFont.ttf").fontName;
						}
				}
			
			default:
				if (font != openfl.utils.Assets.getFont("assets/fonts/disneyFreeplayFont.ttf").fontName)
				{
					setTextFormat(new TextFormat(openfl.utils.Assets.getFont("assets/fonts/disneyFreeplayFont.ttf").fontName, 12, 0xFFD1D1D1));
					font = openfl.utils.Assets.getFont("assets/fonts/disneyFreeplayFont.ttf").fontName;
				}
		}

		textColor = (Type.getClass(FlxG.state) == PlayState && PlayState.SONG.song == "Malfunction" ? 0x1F282E : 0xFFC2C2C2);
		
		if (currentFPS <= ClientPrefs.framerate / 2)
		{
			textColor = 0xFF0000;
			lagging = true;
		}

		curMemory = backend.MemoryRate.obtainMemory();
		if (curMemory >= peakMemory)
			peakMemory = curMemory;

		if (ClientPrefs.debugInfo)
		{
			text += '\nRAM: ${formatMemory(Std.int(curMemory))} (${formatMemory(Std.int(peakMemory))} peak)';
			text += '\nFunkin.avi v2.0.0';
		}
	}

	public var textAfter:String = '';

	public static function formatMemory(num:UInt):String
	{
		var size:Float = num;
		var data = 0;
		var dataTexts = ["B", "KB", "MB", "GB"];
		while (size > 1024 && data < dataTexts.length - 1)
		{
			data++;
			size = size / 1024;
		}

		size = Math.round(size * 100) / 100;
		var formatSize:String = formatAccuracy(size);
		return '${formatSize} ${dataTexts[data]}';
	}

	public static function formatAccuracy(value:Float)
	{
		var conversion:Map<String, String> = [
			'0' => '0.00',
			'0.0' => '0.00',
			'0.00' => '0.00',
			'00' => '00.00',
			'00.0' => '00.00',
			'00.00' => '00.00', // gotta do these as well because lazy
			'000' => '000.00'
		]; // these are to ensure you're getting the right values, instead of using complex if statements depending on string length

		var stringVal:String = Std.string(value);
		var converVal:String = '';
		for (i in 0...stringVal.length)
		{
			if (stringVal.charAt(i) == '.')
				converVal += '.';
			else
				converVal += '0';
		}

		var wantedConversion:String = conversion.get(converVal);
		var convertedValue:String = '';

		for (i in 0...wantedConversion.length)
		{
			if (stringVal.charAt(i) == '')
				convertedValue += wantedConversion.charAt(i);
			else
				convertedValue += stringVal.charAt(i);
		}

		if (convertedValue.length == 0)
			return '$value';

		return convertedValue;
	}
}
