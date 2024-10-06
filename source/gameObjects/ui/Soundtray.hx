package gameObjects.ui;

import openfl.Lib;
import flixel.system.ui.FlxSoundTray;
import flixel.tweens.FlxTween;
import flixel.system.FlxAssets;
import flixel.tweens.FlxEase;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.utils.Assets;

/**
 *  Extends the default flixel soundtray, but with some art
 *  and lil polish!
 *
 *  Gets added to the game in Main.hx, right after FlxGame is new'd since it's a `Sprite` rather than `FlxObject`
 */
class Soundtray extends FlxSoundTray
{
  var graphicScale:Float = 0.5;
  var lerpYPos:Float = 0;
  var alphaTarget:Float = 0;

  var volumeMaxSound:String;

  public function new()
  {
    // calls super, then removes all children to add our own
    // graphics
    super();
    removeChildren();

    var bg:Bitmap = new Bitmap(Assets.getBitmapData(Paths.getPath('images/Funkin_avi/soundtray/volumebox.png', IMAGE)));
    bg.scaleX = graphicScale;
    bg.scaleY = graphicScale;
    addChild(bg);

    y = -height;
    visible = false;

    // clear the bars array entirely, it was initialized
    // in the super class
    _bars = [];

    // 1...11 due to how block named the assets,
    // we are trying to get assets bars_1-10
    for (i in 1...11)
    {
        var backingBar:Bitmap = new Bitmap(Assets.getBitmapData(Paths.getPath('images/Funkin_avi/soundtray/bars_$i.png', IMAGE)));
        backingBar.x = 9;
        backingBar.y = 5;
        backingBar.scaleX = graphicScale - .05;
        backingBar.scaleY = graphicScale - .05;
        addChild(backingBar);
        backingBar.alpha = 0.4;

        var bar:Bitmap = new Bitmap(Assets.getBitmapData(Paths.getPath('images/Funkin_avi/soundtray/bars_$i.png', IMAGE)));
        bar.x = 9;
        bar.y = 5;
        bar.scaleX = graphicScale - .05;
        bar.scaleY = graphicScale - .05;
        addChild(bar);
        _bars.push(bar);
    }

    y = -height;
    screenCenter();

    volumeUpSound = Paths.soundString("funkinAVI/menu/scrollSfx");
    volumeDownSound = Paths.soundString("funkinAVI/menu/scrollSfx");
    volumeMaxSound = Paths.soundString("cancelMenu");

    trace("Custom tray added!");
  }

  override public function update(MS:Float):Void
  {
    y = coolLerp(y, lerpYPos, 0.1);
    alpha = coolLerp(alpha, alphaTarget, 0.25);

    // Animate sound tray thing
    if (_timer > 0)
    {
      _timer -= (MS / 1000);
      alphaTarget = 1;
    }
    else if (y >= -height)
    {
      lerpYPos = -height;
      alphaTarget = 0;
    }

    if (y <= -height)
    {
      visible = false;
      active = false;

      #if FLX_SAVE
      // Save sound preferences
      if (FlxG.save.isBound)
      {
        FlxG.save.data.mute = FlxG.sound.muted;
        FlxG.save.data.volume = FlxG.sound.volume;
        FlxG.save.flush();
      }
      #end
    }
  }

  /**
   * Makes the little volume tray slide out.
   *
   * @param	up Whether the volume is increasing.
   */
  override public function show(up:Bool = false):Void
  {
    _timer = 1;
    lerpYPos = 0;
    visible = true;
    active = true;
    var globalVolume:Int = Math.round(FlxG.sound.volume * 10);

    if (FlxG.sound.muted)
    {
      globalVolume = 0;
    }

    if (!silent)
    {
      var sound = up ? volumeUpSound : volumeDownSound;

      if (globalVolume == 10) sound = volumeMaxSound;

      if (sound != null) FlxG.sound.load(sound).play();
    }

    for (i in 0..._bars.length)
    {
      if (i < globalVolume)
      {
        _bars[i].visible = true;
      }
      else
      {
        _bars[i].visible = false;
      }
    }
  }

  override function screenCenter() {
    super.screenCenter();

    scaleX = _defaultScale;
    scaleY = _defaultScale;

    x = (0.45 * (Lib.current.stage.stageWidth - _width * _defaultScale) - FlxG.game.x);
  }

    public static function coolLerp(base:Float, target:Float, ratio:Float):Float
    {
        return base + cameraLerp(ratio) * (target - base);
    }

    public static function cameraLerp(lerp:Float):Float
    {
        return lerp * (FlxG.elapsed / (1 / 60));
    }
}