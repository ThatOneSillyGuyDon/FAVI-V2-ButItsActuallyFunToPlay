package states.menus;

class Brainrot extends MusicBeatState
{
	var subwaySurfers:VideoSprite;
	var gameplay:VideoSprite;

	//WHERE THE HELL IS THE FAMILY GUY

	override function create()
	{
		subwaySurfers = new VideoSprite(false);
		subwaySurfers.load(Paths.video('brainrot/subway_surfers'), [VideoSprite.muted]);
		subwaySurfers.play();
		subwaySurfers.x += 200;
		subwaySurfers.y -= 250;
		subwaySurfers.scale.x = subwaySurfers.scale.x * 2;
		subwaySurfers.scale.y = subwaySurfers.scale.y / 3;
		add(subwaySurfers);
		subwaySurfers.addCallback("onEnd", () -> {
			FlxG.sound.music.fadeIn(4, 0, 0.7);
			MusicBeatState.switchState(new MainMenuState());
		});
		
		gameplay = new VideoSprite(false);
		gameplay.load(Paths.video('brainrot/${FlxG.random.int(1,2)}'));
		gameplay.play();
		gameplay.y -= 150;
		gameplay.scale.y = gameplay.scale.y / 2;
		add(gameplay);
	}

	override function update(elapsed:Float)
	{
		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.sound.music.fadeIn(4, 0, 0.7);
			MusicBeatState.switchState(new MainMenuState());
		}
		super.update(elapsed);
	}
}