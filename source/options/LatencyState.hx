package options;

import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import haxe.Timer;
import flixel.FlxCamera;

class LatencyState extends MusicBeatSubstate
{
  var visualOffsetText:FlxText;
  var offsetText:FlxText;

  var blocks:FlxTypedGroup<FlxSprite>;

  var songPosVis:FlxSprite;
  var songVisFollowVideo:FlxSprite;
  var songVisFollowAudio:FlxSprite;

  var beatTrail:FlxSprite;
  var diffGrp:FlxTypedGroup<FlxText>;
  var offsetsPerBeat:Array<Null<Int>> = [];
  var swagSong:HomemadeMusic;

  var previousVolume:Float;

  var stateCamera:FlxCamera;
  
  var prevPersistentDraw:Bool;
  var prevPersistentUpdate:Bool;

  var noteGrp:FlxTypedGroup<Note>;
	var strumLine:FlxSprite;

  override function create()
  {
    super.create();

    prevPersistentDraw = FlxG.state.persistentDraw;
    prevPersistentUpdate = FlxG.state.persistentUpdate;

    FlxG.state.persistentDraw = false;
    FlxG.state.persistentUpdate = false;

    stateCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height);
    stateCamera.bgColor = FlxColor.BLACK;
    FlxG.cameras.add(stateCamera);

    var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
    add(bg);

    if (FlxG.sound.music != null)
    {
      previousVolume = FlxG.sound.music.volume;
      FlxG.sound.music.volume = 0;
    }
    else
      previousVolume = 1;

    swagSong = new HomemadeMusic();
    swagSong.loadEmbedded(Paths.sound('soundTest'), true);
    swagSong.looped = true;
    swagSong.play();
    FlxG.sound.list.add(swagSong);

    Conductor.bpm = 60;

    diffGrp = new FlxTypedGroup<FlxText>();
    add(diffGrp);

    for (beat in 0...Math.floor(swagSong.length / (Conductor.stepCrochet * 2)))
    {
      var beatTick:FlxSprite = new FlxSprite(songPosToX(beat * (Conductor.stepCrochet * 2)), FlxG.height - 15);
      beatTick.makeGraphic(2, 15);
      beatTick.alpha = 0.3;
      add(beatTick);

      var offsetTxt:FlxText = new FlxText(songPosToX(beat * (Conductor.stepCrochet * 2)), FlxG.height - 26, 0, "");
      offsetTxt.alpha = 0.5;
      diffGrp.add(offsetTxt);

      offsetsPerBeat.push(null);
    }

    songVisFollowAudio = new FlxSprite(0, FlxG.height - 20).makeGraphic(2, 20, FlxColor.YELLOW);
    add(songVisFollowAudio);

    songVisFollowVideo = new FlxSprite(0, FlxG.height - 20).makeGraphic(2, 20, FlxColor.BLUE);
    add(songVisFollowVideo);

    songPosVis = new FlxSprite(0, FlxG.height - 20).makeGraphic(2, 20, FlxColor.RED);
    add(songPosVis);

    beatTrail = new FlxSprite(0, songPosVis.y).makeGraphic(2, 20, FlxColor.PURPLE);
    beatTrail.alpha = 0.7;
    add(beatTrail);

    blocks = new FlxTypedGroup<FlxSprite>();
    add(blocks);

    for (i in 0...8)
    {
      var block = new FlxSprite(2, ((FlxG.height / 8) + 2) * i).makeGraphic(Std.int(FlxG.height / 8), Std.int((FlxG.height / 8) - 4));
      block.alpha = 0.1;
      blocks.add(block);
    }

    noteGrp = new FlxTypedGroup<Note>();
		add(noteGrp);

		for (i in 0...32)
		{
			var note:Note = new Note(Conductor.crochet * i, 1);
			noteGrp.add(note);
		}

    var strumlineBG:FlxSprite = new FlxSprite();
    add(strumlineBG);

    strumLine = new FlxSprite(FlxG.width / 2, 100).makeGraphic(FlxG.width, 5);
    strumLine.screenCenter();
		add(strumLine);

    strumlineBG.x = strumLine.x;
    strumlineBG.makeGraphic(Std.int(strumLine.width), FlxG.height, 0xFFFFFFFF);
    strumlineBG.alpha = 0.1;

    visualOffsetText = new FlxText();
    visualOffsetText.setFormat(Paths.font("vcr.ttf"), 20);
    visualOffsetText.x = (FlxG.height / 8) + 10;
    visualOffsetText.y = 10;
    visualOffsetText.fieldWidth = strumLine.x - visualOffsetText.x - 10;
    add(visualOffsetText);

    offsetText = new FlxText();
    offsetText.setFormat(Paths.font("vcr.ttf"), 20);
    offsetText.x = strumLine.x + strumLine.width + 10;
    offsetText.y = 10;
    offsetText.fieldWidth = FlxG.width - offsetText.x - 10;
    add(offsetText);
    
    var strumlineBG:FlxSprite = new FlxSprite();
    strumlineBG.screenCenter(X);
    strumlineBG.makeGraphic(Std.int(strumLine.width), FlxG.height, 0xFFFFFFFF);
    strumlineBG.alpha = 0.1;
    add(strumlineBG);

    visualOffsetText = new FlxText();
    visualOffsetText.setFormat(Paths.font("vcr.ttf"), 20);
    visualOffsetText.x = (FlxG.height / 8) + 10;
    visualOffsetText.y = 10;
    visualOffsetText.fieldWidth = strumLine.x - visualOffsetText.x - 10;
    add(visualOffsetText);

    offsetText = new FlxText();
    offsetText.setFormat(Paths.font("vcr.ttf"), 20);
    offsetText.x = strumLine.x + strumLine.width + 10;
    offsetText.y = 10;
    offsetText.fieldWidth = FlxG.width - offsetText.x - 10;
    add(offsetText);

    var helpText:FlxText = new FlxText();
    helpText.setFormat(Paths.font("vcr.ttf"), 20);
    helpText.text = "Press BACK to return to main menu";
    helpText.x = FlxG.width - helpText.width;
    helpText.y = FlxG.height - (helpText.height * 2) - 2;
    add(helpText);
  }

  override public function close():Void
  {
    cleanup();
    super.close();
  }

  function cleanup():Void
  {
    if (FlxG.sound.music != null)
    {
      FlxG.sound.music.volume = previousVolume;
    }

    swagSong.stop();
    FlxG.sound.list.remove(swagSong);

    FlxG.cameras.remove(stateCamera);

    FlxG.state.persistentDraw = prevPersistentDraw;
    FlxG.state.persistentUpdate = prevPersistentUpdate;
  }

  override function stepHit()
  {
    if (curStep % 4 == 2)
    {
      blocks.members[((curBeat % 8) + 1) % 8].alpha = 0.5;
    }

    super.stepHit();
  }

  override function beatHit()
  {
    if (curBeat % 8 == 0) blocks.forEach(blok -> {
      blok.alpha = 0.1;
    });

    blocks.members[curBeat % 8].alpha = 1;

    super.beatHit();
  }

  override function update(elapsed:Float)
  {
    Conductor.songPosition = swagSong.time;

    songPosVis.x = songPosToX(Conductor.songPosition);
    songVisFollowAudio.x = songPosToX(Conductor.songPosition - ClientPrefs.data.noteOffset);
    songVisFollowVideo.x = songPosToX(Conductor.songPosition - ClientPrefs.data.ratingOffset);

    visualOffsetText.text = "Visual Offset: " + ClientPrefs.data.noteOffset + "ms";
    visualOffsetText.text += "\n\nYou can press SPACE+Left/Right to change this value.";
    visualOffsetText.text += "\n\nYou can hold SHIFT to step 1ms at a time";

    offsetText.text = "INPUT Offset (Left/Right to change): " + ClientPrefs.data.ratingOffset + "ms";
    offsetText.text += "\n\nYou can hold SHIFT to step 1ms at a time";

    var avgOffsetInput:Float = 0;

    var loopInd:Int = 0;
    for (offsetThing in offsetsPerBeat)
    {
      if (offsetThing == null) continue;
      avgOffsetInput += offsetThing;
      loopInd++;
    }

    avgOffsetInput /= loopInd;

    offsetText.text += "\n\nEstimated average input offset needed: " + avgOffsetInput;

    var multiply:Int = 10;

    if (FlxG.keys.pressed.SHIFT) multiply = 1;

    if (FlxG.keys.pressed.CONTROL || FlxG.keys.pressed.SPACE)
    {
      if (FlxG.keys.justPressed.RIGHT)
      {
        ClientPrefs.data.noteOffset += 1 * multiply;
      }

      if (FlxG.keys.justPressed.LEFT)
      {
        ClientPrefs.data.noteOffset -= 1 * multiply;
      }
    }
    else
    {
      if (FlxG.keys.anyJustPressed([LEFT, RIGHT]))
      {
        if (FlxG.keys.justPressed.RIGHT)
        {
          ClientPrefs.data.ratingOffset += 1 * multiply;
        }

        if (FlxG.keys.justPressed.LEFT)
        {
          ClientPrefs.data.ratingOffset -= 1 * multiply;
        }

        offsetsPerBeat = [];
        diffGrp.forEach(memb -> memb.text = "");
      }
    }

    if (controls.BACK)
    {
      close();
    }

    super.update(elapsed);
  }

  function songPosToX(pos:Float):Float
  {
    return FlxMath.remapToRange(pos, 0, swagSong.length, 0, FlxG.width);
  }
}

class HomemadeMusic extends FlxSound
{
  public var prevTimestamp:Int = 0;

  public function new()
  {
    super();
  }

  var prevTime:Float = 0;

  override function update(elapsed:Float)
  {
    super.update(elapsed);
    if (prevTime != time)
    {
      prevTime = time;
      prevTimestamp = Std.int(Timer.stamp() * 1000);
    }
  }

  public function getTimeWithDiff():Float
  {
    return time + (Std.int(Timer.stamp() * 1000) - prevTimestamp);
  }
}
