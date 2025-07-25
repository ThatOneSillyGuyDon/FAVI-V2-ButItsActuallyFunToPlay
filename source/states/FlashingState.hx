package states;

import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;

class FlashingState extends MusicBeatState
{
	public static var leftState:Bool = false;
	var warnText:FlxSprite;
	public static var pitchedMusic:FlxSound;

	override function create()
	{
		super.create();

		FlxG.sound.playMusic(Paths.music("aviOST/gameOver/amIReal", "shared"));
		FlxG.sound.music.pitch = 0.45;

		var fog:FlxBackdrop = new FlxBackdrop(Paths.image("Funkin_avi/warning/warningFog"), X, 0, 0);
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image("Funkin_avi/warning/warningBG"));
		var sign:FlxSprite = new FlxSprite().loadGraphic(Paths.image("Funkin_avi/warning/warningSign"));
		warnText = new FlxSprite().loadGraphic(Paths.image("Funkin_avi/warning/warningConfirm"));
		var vignette:FlxSprite = new FlxSprite().loadGraphic(Paths.image("Funkin_avi/warning/warningVignette"));

		fog.velocity.set(100, 0);
		warnText.visible = false;

		for (i in [fog, bg, sign, warnText, vignette])
			add(i);
	}

	override function update(elapsed:Float)
	{
		if(!leftState) {
			if (controls.ACCEPT) {
				leftState = true;
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				FlxG.sound.play(Paths.sound('funkinAVI/menu/confirmEpisode'));
				FlxG.camera.zoom += 0.1;
				FlxG.camera.fade(FlxColor.BLACK, 1.5);
				FlxTween.tween(FlxG.camera, {zoom: 1}, 1, {ease: FlxEase.circOut});
				warnText.visible = true;
				FlxTween.tween(warnText, {alpha: 0}, 2, {onComplete: function(twn:FlxTween)
				{
					MusicBeatState.switchState(new WarningSettings());
				}});
			}
		}
		super.update(elapsed);
	}
}