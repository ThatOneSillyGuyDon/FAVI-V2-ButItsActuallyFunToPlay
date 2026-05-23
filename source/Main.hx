package;

import funkin.utils.WindowUtil;

import openfl.Lib;
import openfl.display.Sprite;
import openfl.display.StageScaleMode;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.input.keyboard.FlxKey;

import funkin.backend.DebugDisplay;

@:nullSafety(Strict)
class Main extends Sprite
{
	public static final PSYCH_VERSION:String = '0.5.2h';
	public static final NMV_VERSION:String = '1.0';
	public static final FUNKIN_VERSION:String = '0.2.7';
	
	public static final startMeta =
		{
			width: 1280,
			height: 720,
			fps: 60,
			skipSplash: #if debug true #else false #end,
			startFullScreen: false,
			initialState: funkin.states.TitleState
		};
		
	static function __init__()
	{
		funkin.utils.MacroUtil.haxeVersionEnforcement();
		
		openfl.utils._internal.Log.level = openfl.utils._internal.Log.LogLevel.INFO;
	}
	
	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}
	
	public function new()
	{
		super();
		
		#if (CRASH_HANDLER && !debug)
		funkin.backend.CrashHandler.init();
		#end
		
		initHaxeUI();
		
		WindowUtil.resetWindow();
		
		// load save data before creating FlxGame
		funkin.data.Highscore.initSave();
		
		ClientPrefs.loadDefaultKeys();
		ClientPrefs.setupSave();
		
		DataUSMM.prepareData();
		
		addChild(new funkin.backend.FunkinGame(startMeta.width, startMeta.height, Init, startMeta.fps, startMeta.fps, true, startMeta.startFullScreen));
		
		// prevent accept button when alt+enter is pressed
		FlxG.stage.addEventListener(openfl.events.KeyboardEvent.KEY_DOWN, (e) -> {
			if (e.keyCode == FlxKey.ENTER && e.altKey) e.stopImmediatePropagation();
		}, false, 100);
		
		DebugDisplay.init();
		
		FlxG.signals.gameResized.add(onResize);
		
		#if DISABLE_TRACES
		haxe.Log.trace = (v:Dynamic, ?infos:haxe.PosInfos) -> {}
		#end
	}
	
	@:access(flixel.FlxCamera)
	static function onResize(w:Int, h:Int)
	{
		final scale:Float = Math.max(1, Math.min(w / FlxG.width, h / FlxG.height));
		
		if (FlxG.cameras != null)
		{
			for (i in FlxG.cameras.list)
			{
				if (i != null && i.filters != null) resetSpriteCache(i.flashSprite);
			}
		}
		
		if (FlxG.game != null)
		{
			resetSpriteCache(FlxG.game);
		}
	}
	
	@:nullSafety(Off)
	public static function resetSpriteCache(sprite:Sprite):Void
	{
		if (sprite == null) return;
		@:privateAccess
		{
			sprite.__cacheBitmap = null;
			sprite.__cacheBitmapData = null;
		}
	}
	
	function initHaxeUI():Void
	{
		#if haxeui_core
		haxe.ui.Toolkit.init();
		haxe.ui.Toolkit.theme = 'dark';
		haxe.ui.Toolkit.autoScale = false;
		haxe.ui.focus.FocusManager.instance.autoFocus = false;
		haxe.ui.tooltips.ToolTipManager.defaultDelay = 200;
		#end
	}
}
