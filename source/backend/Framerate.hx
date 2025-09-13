package backend;

import flixel.FlxG;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.system.System;
import openfl.events.Event;

/**
	The FPS class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
**/
class Framerate extends TextField
{
	/**
		The current frame rate, expressed as frames-per-second.
	**/
	public static var currentFPS(default, null):Int;

	/**
		The number of frames rendered in the last second.
	**/
	@:noCompletion private static var times:Array<Int> = [];

	/**
		The number of milliseconds to wait before updating the TextField. 
	**/
	public static final updateInterval:Int = 250; // keep this high

	public var font:String = '';

	/**
		The current memory usage
	**/
	public var memoryMegas(get, never):Float;
	@:isVar public var memoryPeak(get, default):Float;

	public function new(x:Float = 0, y:Float = 0)
	{
		super();

		this.x = x;
		this.y = y;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat(openfl.utils.Assets.getFont("assets/fonts/disneyFreeplayFont.ttf").fontName /*your standards are lame Jason lol*/, 12, 0xFFFFFF);
        // https://en.wikipedia.org/wiki/Game_design
		font = openfl.utils.Assets.getFont("assets/fonts/disneyFreeplayFont.ttf").fontName;
		multiline = false;
		wordWrap = false;
		autoSize = LEFT;
		background = false;
		cacheAsBitmap = false;
		addEventListener(Event.DEACTIVATE, _ -> focus = false);
		addEventListener(Event.ACTIVATE, _ -> focus = true);
	}

	private static var then:Int = 0;
	private static var now:Int = 0;
	private static var focus:Bool = true;
	private static var mouseCheck:Bool = false;

	private override function __enterFrame(deltaTime:Float):Void
	{
		if (!focus || !visible)
			return;

		if (memoryMegas > memoryPeak) 
            memoryPeak = memoryMegas;

		now = lime.system.System.getTimer();
		times.push(now);
		while (times[0] < now - 1000)
			times.shift();

		if (now - then < updateInterval)
			return;

		then = now;
		currentFPS = times.length < FlxG.updateFramerate ? times.length : FlxG.updateFramerate;
		text = 'FPS: ${currentFPS}\n'; // The frametime is currently a lie. Using deltaTime causes the TextField to regen more frequently, which is hideously memory intensive.
		// this is technically very bad but apperently compiler breaks itself
		if (ClientPrefs.data.debugInfo) 
			text += 'RAM: ${flixel.util.FlxStringUtil.formatBytes(memoryMegas)} (${flixel.util.FlxStringUtil.formatBytes(memoryPeak)} peak)\nFunkin.avi v2.5.0\n'; // <-- still retarded

		textColor = currentFPS < (FlxG.drawFramerate * 0.5) ? 0xFFFF0000 : (Type.getClass(FlxG.state) == PlayState && PlayState.SONG.song == "Malfunction" ? 0x1F282E : 0xFFC2C2C2);
	
        // why am I doing this? well, why tf not? (don)
		// can't complain brah
        // avi if adding quadrillion unnecesarry things was a job (i'd be rich)
		// also could've done better #justsaying
        if (Type.getClass(FlxG.state) == PlayState)
        {
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
        } else {
            if (font != openfl.utils.Assets.getFont("assets/fonts/disneyFreeplayFont.ttf").fontName)
            {
                setTextFormat(new TextFormat(openfl.utils.Assets.getFont("assets/fonts/disneyFreeplayFont.ttf").fontName, 12, 0xFFD1D1D1));
                font = openfl.utils.Assets.getFont("assets/fonts/disneyFreeplayFont.ttf").fontName;
            }
        }
    }
	
	inline function get_memoryMegas():Float
		return cpp.vm.Gc.memInfo64(cpp.vm.Gc.MEM_INFO_USAGE);

	inline function get_memoryPeak():Float
		return memoryPeak;
}
