package states.menus;

import lime.ui.MouseCursor;
import openfl.ui.Mouse;
import openfl.events.MouseEvent;
import lime.app.Application;
import flash.system.System;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.input.keyboard.FlxKey;
import flixel.input.keyboard.FlxKeyboard;
import haxe.io.Path;
import openfl.net.SharedObject;
import openfl.net.SharedObjectFlushStatus;
import sys.io.File;

using StringTools;


class VideoShit extends MusicBeatState
{	
	// from PlayState.HX
	public var videoSprite:VideoSprite;

	override function create()
	{

		super.create();

		// yes
		openfl.Lib.application.window.title = "Funkin.avi - get trolled lmfao";
		
		
		playVideoSprite("copy_58A06747-BA36-4B9B-9176-24215AAAA120", true, -300,-100,0.8,0.8);

		playVideoSprite("Come_here_squidward", true, 500, 200, 4.2, 4);

		DiscordClient.changePresence('Funkin.avi', 'Main Menu', 'icon', 'mouse');

	}
	override function update(elapsed:Float)
	{

		super.update(elapsed);
	}

	// from PlayState.HX
	public function playVideoSprite(name:String, ?vis:Bool = true, x:Float = 0, y:Float = 0, scaleX:Float = 1, scaleY:Float = 1){
		videoSprite = new VideoSprite(false);
		videoSprite.scrollFactor.set();
		videoSprite.scale.set(scaleX, scaleY);
		videoSprite.x = x;
		videoSprite.y = y;
		videoSprite.visible = vis;
		videoSprite.onEndCallback = ()->{
			trace("video gone");
			remove(videoSprite);
			videoSprite.kill();
		};


		videoSprite.onStartCallback = ()->{
			//im pr sure this is redundant now with hxvlc not starting vid until play is called but whatyever lol
			if(vis) videoSprite.visible=true;
		};

		// this is weird but oh well! it works tho!
		videoSprite.addCallback("onEnd", () -> ermidfk());

		videoSprite.load(Paths.video(name));
		videoSprite.play();
		add(videoSprite);
	}

	// i just find it easier
	function ermidfk()
	{
		FlxG.sound.playMusic(Paths.music('aviOST/rottenPetals'), 1);
		FlxG.sound.music.fadeIn(0.3, 0, 0.2);
		MusicBeatState.switchState(new MainMenu());
	}
}

