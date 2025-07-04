package objects;

import flixel.group.FlxGroup;
import flixel.ui.FlxBar;
import flixel.util.FlxStringUtil;

import states.menus.FreeplayState;

/**
 * Music player used for Freeplay
 */
@:access(states.menus.FreeplayState)
class MusicPlayer extends FlxGroup 
{
	public var instance:FreeplayState;

	public var playing(get, never):Bool;
	public var paused(get, never):Bool;

	public var playingMusic:Bool = false;
	public var curTime:Float;

	var songBG:FlxSprite;
	var songTxt:FlxText;
	var timeTxt:FlxText;
	var progressBar:FlxBar;

	var wasPlaying:Bool;

	public function new(instance:FreeplayState)
	{
		super();

		this.instance = instance;

		var xPos:Float = FlxG.width * 0.7;

		songBG = new FlxSprite(xPos - 6, 0).makeGraphic(1, 100, 0xFF000000);
		songBG.alpha = 0.6;
		if (FreeplayState.freeplayMenuList == 2)
			add(songBG);
		
		if (FreeplayState.freeplayMenuList == 2)
		{
			songTxt = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
			songTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
			add(songTxt);

			timeTxt = new FlxText(xPos, songTxt.y + 60, 0, "", 32);
			timeTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
			add(timeTxt);

			progressBar = new FlxBar(timeTxt.x, timeTxt.y + timeTxt.height, LEFT_TO_RIGHT, Std.int(timeTxt.width), 8, null, "", 0, Math.POSITIVE_INFINITY);
			progressBar.createFilledBar(FlxColor.WHITE, FlxColor.BLACK);
			add(progressBar);
		}
		else
		{
			songTxt = new FlxText(830, 570, 0, "", 32);
			songTxt.setFormat(Paths.font("newFreeplayFont.ttf"), 32, FlxColor.WHITE, CENTER);
			add(songTxt);

			timeTxt = new FlxText(songTxt.x - 20, songTxt.x + 60, 0, "", 32);
			timeTxt.setFormat(Paths.font("newFreeplayFont.ttf"), 32, FlxColor.WHITE, CENTER);
			add(timeTxt);

			songTxt.x = 830;
			songTxt.y = 570;
			songTxt.alignment = CENTER;
			timeTxt.x = songTxt.x - 20;
			timeTxt.y = songTxt.y + 60;
			timeTxt.alignment = CENTER;

			progressBar = new FlxBar(timeTxt.x, timeTxt.y + timeTxt.height, LEFT_TO_RIGHT, Std.int(timeTxt.width), 8, null, "", 0, Math.POSITIVE_INFINITY);
			progressBar.createFilledBar(FlxColor.WHITE, FlxColor.GRAY);
			add(progressBar);
		}

		switchPlayMusic();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!playingMusic)
		{
			return;
		}

		if (paused && !wasPlaying)
			songTxt.text = 'PLAYING: ' + instance.songs[FreeplayState.curSelected].songName + ' (PAUSED)';
		else
			songTxt.text = 'PLAYING: ' + instance.songs[FreeplayState.curSelected].songName;

		positionSong();

		if (instance.controls.UI_LEFT_P)
		{
			if (playing)
				wasPlaying = true;

			pauseOrResume();

			curTime = FlxG.sound.music.time - 1000;
			instance.holdTime = 0;

			if (curTime < 0)
				curTime = 0;

			FlxG.sound.music.time = curTime;
		}
		if (instance.controls.UI_RIGHT_P)
		{
			if (playing)
				wasPlaying = true;

			pauseOrResume();

			curTime = FlxG.sound.music.time + 1000;
			instance.holdTime = 0;

			if (curTime > FlxG.sound.music.length)
				curTime = FlxG.sound.music.length;

			FlxG.sound.music.time = curTime;
		}
	
		updateTimeTxt();

		if(instance.controls.UI_LEFT || instance.controls.UI_RIGHT)
		{
			instance.holdTime += elapsed;
			if(instance.holdTime > 0.5)
			{
				curTime += 40000 * elapsed * (instance.controls.UI_LEFT ? -1 : 1);
			}

			var difference:Float = Math.abs(curTime - FlxG.sound.music.time);
			if(curTime + difference > FlxG.sound.music.length) curTime = FlxG.sound.music.length;
			else if(curTime - difference < 0) curTime = 0;

			FlxG.sound.music.time = curTime;

			updateTimeTxt();
		}

		if(instance.controls.UI_LEFT_R || instance.controls.UI_RIGHT_R)
		{
			FlxG.sound.music.time = curTime;

			if (wasPlaying)
			{
				pauseOrResume(true);
				wasPlaying = false;
			}

			updateTimeTxt();
		}
	
		if (instance.controls.RESET)
		{
			FlxG.sound.music.time = 0;

			updateTimeTxt();
		}
	}

	public function pauseOrResume(resume:Bool = false) 
	{
		if (resume)
		{
			FlxG.sound.music.resume();
		}
		else 
		{
			FlxG.sound.music.pause();
		}
		positionSong();
	}

	public function switchPlayMusic()
	{
		FlxG.autoPause = (!playingMusic && ClientPrefs.data.autoPause);
		active = visible = playingMusic;

		instance.scoreBG.visible = instance.diffText.visible = instance.scoreText.visible = !playingMusic; //Hide Freeplay texts and boxes if playingMusic is true
		songTxt.visible = timeTxt.visible = songBG.visible = progressBar.visible = playingMusic; //Show Music Player texts and boxes if playingMusic is true

		instance.holdTime = 0;

		if (playingMusic)
		{
			positionSong();
			
			progressBar.setRange(0, FlxG.sound.music.length);
			progressBar.setParent(FlxG.sound.music, "time");
			progressBar.numDivisions = 1600;

			updateTimeTxt();
		}
		else
		{
			progressBar.setRange(0, Math.POSITIVE_INFINITY);
			progressBar.setParent(null, "");
			progressBar.numDivisions = 0;

			instance.positionHighscore();
		}
		progressBar.updateBar();
	}

	function positionSong() 
	{
		var length:Int = instance.songs[FreeplayState.curSelected].songName.length;
		var shortName:Bool = length < 5; // Fix for song names like Ugh, Guns
		if (FreeplayState.freeplayMenuList == 2)
		{
			//Bro why tf is the math like this like what crack was ShadowMario Smoking when he made this????
			songTxt.x = FlxG.width - songTxt.width - 6;
			if (shortName)
				songTxt.x -= 10 * length - length;
			songBG.scale.x = FlxG.width - songTxt.x + 12;
			if (shortName) 
				songBG.scale.x += 6 * length;
			songBG.x = FlxG.width - (songBG.scale.x / 2);
			timeTxt.x = Std.int(songBG.x + (songBG.width / 2));
			timeTxt.x -= timeTxt.width / 2;
			if (shortName)
				timeTxt.x -= length - 5;
		}
		else
		{
			//RAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
			songTxt.screenCenter(X).x += 400;
			timeTxt.screenCenter(X).x += 400;
		}

		progressBar.setGraphicSize(Std.int(songTxt.width), 5);
		progressBar.y = songTxt.y + songTxt.height + 10;
		progressBar.x = songTxt.x + songTxt.width / 2 - 15;
		if (shortName)
		{
			progressBar.scale.x += length / 2;
			progressBar.x -= length - 10;
		}
	}

	function updateTimeTxt()
	{
		var text = FlxStringUtil.formatTime(FlxG.sound.music.time / 1000, false) + ' / ' + FlxStringUtil.formatTime(FlxG.sound.music.length / 1000, false);
		timeTxt.text = '< ' + text + ' >';
	}

	function get_playing():Bool 
	{
		return FlxG.sound.music.playing;
	}

	function get_paused():Bool 
	{
		@:privateAccess return FlxG.sound.music._paused;
	}
}