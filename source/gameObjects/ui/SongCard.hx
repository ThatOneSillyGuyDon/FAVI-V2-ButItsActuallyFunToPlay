package gameObjects.ui;

class SongCard extends FlxSpriteGroup
{	
	// JSON Var Helpers
	public var fontStuff:String = "vcr.ttf";
	public var lineThing:String = "-";

	// Card Setup
	public var songBanner:FlxSprite;
	public var songBannerText:FlxText;

	// Health Icons
	public var opponentIcon:HealthIcon;
	public var playerIcon:HealthIcon;

	public var isLegacy:Bool = false;

	public function new()
	{
		super();

		switch (PlayState.SONG.song)
		{
			case 'Devilish Deal' | 'Isolated' | 'Lunacy' | 'Hunted' | 'Birthday' | 'War Dilemma' | 'Laugh Track' | 'Twisted Grins' | 'Whimsical Bar Blues':
				fontStuff = "DisneyFont.ttf";
			case 'Delusional':
				fontStuff = "satanFont.ttf";
			case 'Bless':
				fontStuff = "MagicOwlFont.otf";
			case "Dont Cross":
				fontStuff = "PhantomMuff Full Letters 1.1.5.ttf";
			case 'Cycled Sins':
				fontStuff = "calibri-regular.ttf";
			case 'Mercy':
				fontStuff = "splatter.otf";
			case 'Malfunction':
				fontStuff = "m40.ttf";
			case 'Isolated Old' | 'Isolated Beta' | "Isolated Legacy" | 'Lunacy Legacy' | 'Delusional Legacy' | 'Hunted Legacy' | 'Twisted Grins Legacy' | 'Mercy Legacy' | 'Cycled Sins Legacy' | 'Malfunction Legacy':
				isLegacy = true;
				fontStuff = "vcr.ttf";
				lineThing = "";
			default: 
				fontStuff = "vcr.ttf";
		}

		songBanner = new FlxSprite(0, 0).makeGraphic(999, 136, FlxColor.WHITE);
		songBanner.scrollFactor.set();
		songBanner.blend = ADD;
		songBanner.alpha = 0;
		songBanner.antialiasing = ClientPrefs.data.antialiasing;
		songBanner.screenCenter(XY);
		add(songBanner);

		var songName:String = PlayState.SONG.song;
		if(PlayState.SONG.song == "Dont Cross") songName = "Don't Cross!";

		songBannerText = new FlxText(0, 0, 600, '$lineThing $songName $lineThing\nBy: ${FreeplayState.getArtistName()}');
		songBannerText.setFormat(Paths.font(fontStuff), 36, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		songBannerText.scrollFactor.set();
		songBannerText.borderSize = 1.25;
		songBannerText.alpha = 0;
		songBannerText.screenCenter(XY);
		add(songBannerText);

		if (!isLegacy)
		{
			opponentIcon = new HealthIcon(PlayState.instance.dad.healthIcon, false);
			opponentIcon.x = 260;
			opponentIcon.scale.set(0.8, 0.8);
			opponentIcon.animation.curAnim.curFrame = 2;
			opponentIcon.alpha = 0.001;
			opponentIcon.screenCenter(Y);
			add(opponentIcon);

			playerIcon = new HealthIcon(PlayState.instance.boyfriend.healthIcon, true);
			playerIcon.x = 850;
			playerIcon.scale.set(0.8, 0.8);
			playerIcon.animation.curAnim.curFrame = 2;
			playerIcon.alpha = 0.001;
			playerIcon.screenCenter(Y);
			add(playerIcon);
		}
	}

	// This is a function in case you want the card to show up later in the song instead of instantly
	public function playCardAnim(delaySet:Float = 0, time:Float = 1, ease:String = 'linear')
	{	
		if (!isLegacy)
		{
			FlxTween.tween(songBanner, {alpha: 0.5}, time, {ease: PlayState.returnTweenEase(ease), startDelay: delaySet});

			FlxTween.tween(songBannerText, {alpha: 1}, time + 0.5, {ease: PlayState.returnTweenEase(ease), startDelay: delaySet});

			FlxTween.tween(opponentIcon, {alpha: 1}, time + 0.7, {ease: PlayState.returnTweenEase(ease), startDelay: delaySet});

			FlxTween.tween(playerIcon, {alpha: 1}, time + 0.7, {ease: PlayState.returnTweenEase(ease), startDelay: delaySet});

		}
		else
		{
			FlxTween.tween(songBanner, {alpha: 0.5}, 1, {ease: FlxEase.circOut,
				onComplete: function(twn:FlxTween)
				{
					FlxTween.tween(songBanner, {alpha: 0}, 1.5, {ease: FlxEase.circIn, startDelay: 4});
				}
			});

			FlxTween.tween(songBannerText, {alpha: 1}, 1, {ease: FlxEase.circOut,
				onComplete: function(twn:FlxTween)
				{
					FlxTween.tween(songBannerText, {alpha: 0}, 1.5, {ease: FlxEase.circIn, startDelay: 4});
				}
			});
		}
	}

	public function removeCardAnim(delaySet:Float = 0, time:Float = 1, ease:String = 'linear')
	{	
		FlxTween.tween(songBanner, {alpha: 0}, time, {ease: PlayState.returnTweenEase(ease), startDelay: delaySet});
		FlxTween.tween(songBannerText, {alpha: 0}, time + 0.5, {ease: PlayState.returnTweenEase(ease), startDelay: delaySet});
		FlxTween.tween(opponentIcon, {alpha: 0}, time + 0.7, {ease: PlayState.returnTweenEase(ease), startDelay: delaySet});
		FlxTween.tween(playerIcon, {alpha: 0}, time + 0.7, {ease: PlayState.returnTweenEase(ease), startDelay: delaySet});
	}

	override function add(Object:FlxSprite):FlxSprite
	{
		if (Std.isOfType(Object, FlxText))
			cast(Object, FlxText).antialiasing = ClientPrefs.data.antialiasing;
		if (Std.isOfType(Object, FlxSprite))
			cast(Object, FlxSprite).antialiasing = ClientPrefs.data.antialiasing;
		return super.add(Object);
	}
}