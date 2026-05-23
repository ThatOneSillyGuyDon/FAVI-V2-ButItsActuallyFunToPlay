package funkin.states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

import funkin.game.shaders.ColorSwap;
import funkin.data.WeekData;
import funkin.objects.Alphabet;
import funkin.states.options.OptionsState;

@:nullSafety
class TitleState extends MusicBeatState
{
	public static var initialized:Bool = false;
	public static var closedState:Bool = false;
	
	var skippedIntro:Bool = false;
	var transitioning:Bool = false;
	
	var title:FlxText = new FlxText(0, 50, 1280, "untitled suicide mouse mod.");
	var curSelected:Int = 0;
	var freeplay:FlxText = new FlxText(0, 250, 1280, "");
	var options:FlxText = new FlxText(0, 250, 1280, "");
	var quit:FlxText = new FlxText(0, 250, 1280, "");
	var hasPressedQuit:Bool = false;
	
	public static function init():Void
	{
		FunkinAssets.cache.clearStoredMemory();
		FunkinAssets.cache.clearUnusedMemory();
		
		// for some reason the plugin scripts dont run sometimes when first loaded. oh well
		funkin.scripting.PluginsManager.prepareSignals();
		funkin.scripting.PluginsManager.populate();
		
		if (FlxG.save.data.flashing == null && !FlashingState.leftState)
		{
			CoolUtil.setTransSkip();
			FlxG.switchState(FlashingState.new);
		}
	}
	
	override public function create():Void
	{
		init();
		
		initStateScript();
		
		startIntro();
		
		super.create();
		
		persistentUpdate = true;
		
		FlxG.mouse.visible = false;
	}
	
	function startIntro()
	{
		if (!initialized)
		{
			FunkinSound.playMusic(Paths.music('freakyMenu'), 0);
		}
		
		Conductor.bpm = 102;
		
		if (scriptGroup.call('onStartIntro') != ScriptConstants.STOP_FUNC)
		{
			title.setFormat(Paths.font("menuFont.ttf"), 50, FlxColor.WHITE, "center");
			title.screenCenter(X);
			add(title);
			
			for (i in [freeplay, options, quit])
			{
				i.setFormat(Paths.font("menuFont.ttf"), 36, FlxColor.WHITE, "center");
				i.screenCenter(X);
				add(i);
			}
			
			freeplay.text = "freeplay";
			options.text = "options";
			quit.text = "quit";
			
			options.y += 100;
			quit.y += 200;
		}
		
		if (initialized)
		{
			skipIntro();
		}
		else
		{
			initialized = true;
		}
		
		scriptGroup.call('onCreatePost', []);
	}
	
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null) Conductor.songPosition = FlxG.sound.music.time;
		
		switch (curSelected)
		{
			case 0:
				freeplay.color = 0xff0000;
				options.color = quit.color = 0xffffff;
			case 1:
				options.color = 0xff0000;
				freeplay.color = quit.color = 0xffffff;
			case 2:
				quit.color = 0xff0000;
				freeplay.color = options.color = 0xffffff;
		}
		if (controls.UI_UP_P || controls.UI_DOWN_P)
		{
			FlxG.sound.play(Paths.sound("scrollMenu"), 0.5);
			if (controls.UI_UP_P) curSelected--;
			else curSelected++;
		}
		if (curSelected > 2 && !hasPressedQuit) curSelected = 0;
		if (curSelected > 1 && hasPressedQuit) curSelected = 0;
		if (curSelected < 0 && !hasPressedQuit) curSelected = 2;
		if (curSelected < 0 && hasPressedQuit) curSelected = 1;
		
		final pressedEnter:Bool = FlxG.gamepads.lastActive?.justPressed.START || FlxG.keys.justPressed.ENTER || controls.ACCEPT;
		
		if (!transitioning && skippedIntro)
		{
			if (pressedEnter && scriptGroup.call('onEnter', []) != ScriptConstants.STOP_FUNC)
			{
				if (freeplay.color == 0xff0000) 
				{
					FlxG.switchState(() -> new FreeplayState());
				}
				if (options.color == 0xff0000) 
				{
					FlxG.switchState(() -> new OptionsState());
					OptionsState.onPlayState = false;
				}
				if (quit.color == 0xff0000)
				{
					hasPressedQuit = true;
					FlxTween.tween(quit, {y: 750, alpha: 0.001, angle: 6}, 3, {ease: FlxEase.quadOut});
				}
			}
		}
		
		super.update(elapsed);
	}
	
	var sickBeats:Int = 0; // Basically curBeat but won't be skipped if you hold the tab or resize the screen
	
	override function beatHit()
	{
		super.beatHit();
		
		if (!closedState)
		{
			sickBeats++;
			scriptGroup.set('curBeat', sickBeats);
		}
		
		if (!closedState)
		{
			switch (sickBeats)
			{
				case 1:
					FunkinSound.playMusic(Paths.music('freakyMenu'), 0);
					skipIntro();
			}
		}
	}
	
	public function skipIntro():Void
	{
		if (scriptGroup.call('onSkipIntro', []) != ScriptConstants.STOP_FUNC && !skippedIntro)
		{
			skippedIntro = true;
		}
	}
}
