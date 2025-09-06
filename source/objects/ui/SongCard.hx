package objects.ui;

class SongCard extends FlxSpriteGroup
{	
	// JSON Var Helpers
	public var fontStuff:String = "vcr.ttf";

	// Base Card Setup
	public var cardTxt:FlxText;
	public var cardSprite:FlxSprite;

	// Legacy Card Setup
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
			case 'Devilish Deal' | 'Isolated' | 'Lunacy' | 'Hunted' | 'Birthday':
				fontStuff = "DisneyFont.ttf";
			case 'Delusional':
				fontStuff = "satanFont.ttf";
			case 'Bless':
				fontStuff = "MagicOwlFont.otf";
			case "Don't Cross!":
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
			default: 
				fontStuff = "vcr.ttf";
		}

		if (!isLegacy)
		{
			cardSprite = new FlxSprite();
			cardSprite.makeGraphic(600, 350, 0xFF000000);
			cardSprite.screenCenter();
			cardSprite.alpha = 0.001;
			add(cardSprite);

			cardTxt = new FlxText(cardSprite.x, cardSprite.y, 0, '- ${PlayState.SONG.song} -\nBy: ${FreeplayState.getArtistName()}');
			cardTxt.setFormat(Paths.font(fontStuff), 42, FlxColor.WHITE, CENTER);
			cardTxt.screenCenter();
			cardTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
			cardTxt.alpha = 0.001;
			add(cardTxt);

			opponentIcon = new HealthIcon(PlayState.instance.dad.healthIcon, false);
			opponentIcon.x = 260;
			opponentIcon.y = 130;
			opponentIcon.animation.curAnim.curFrame = 2;
			opponentIcon.alpha = 0.001;
			add(opponentIcon);

			playerIcon = new HealthIcon(PlayState.instance.boyfriend.healthIcon, true);
			playerIcon.x = 850;
			playerIcon.y = 460;
			playerIcon.animation.curAnim.curFrame = 2;
			playerIcon.alpha = 0.001;
			add(playerIcon);
		}
		else
		{
			songBanner = new FlxSprite(0, 0).makeGraphic(999, 136, FlxColor.WHITE);
			songBanner.scrollFactor.set();
			songBanner.blend = ADD;
			songBanner.alpha = 0;
			songBanner.antialiasing = ClientPrefs.data.antialiasing;
			songBanner.screenCenter(XY);
			add(songBanner);

			songBannerText = new FlxText(0, 0, 600, '${PlayState.SONG.song}\nBy: ${FreeplayState.getArtistName()}');
			songBannerText.setFormat(Paths.font(fontStuff), 36, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songBannerText.scrollFactor.set();
			songBannerText.borderSize = 1.25;
			songBannerText.alpha = 0;
			songBannerText.screenCenter(XY);
			add(songBannerText);
		}
	}

	// This is a function in case you want the card to show up later in the song instead of instantly
	public function playCardAnim(delaySet:Float = 0)
	{	
		if (!isLegacy)
		{
			FlxTween.tween(cardSprite, {alpha: 1}, 1.5, {ease: FlxEase.sineInOut, startDelay: delaySet,
				onComplete: function(twn:FlxTween)
				{
					FlxTween.tween(cardSprite, {alpha: 0}, 1.5, {ease: FlxEase.sineInOut, startDelay: 3.5});
				}
			});
			FlxTween.tween(opponentIcon, {alpha: 1}, 2.2, {ease: FlxEase.sineInOut, startDelay: delaySet,
				onComplete: function(twn:FlxTween)
				{
					FlxTween.tween(opponentIcon, {alpha: 0}, 2.2, {ease: FlxEase.sineInOut, startDelay: 3.5});
				}
			});
			FlxTween.tween(playerIcon, {alpha: 1}, 2.2, {ease: FlxEase.sineInOut, startDelay: delaySet,
				onComplete: function(twn:FlxTween)
				{
					FlxTween.tween(playerIcon, {alpha: 0}, 2.2, {ease: FlxEase.sineInOut, startDelay: 3.5});
				}
			});
			FlxTween.tween(cardTxt, {alpha: 1}, 2, {ease: FlxEase.sineInOut, startDelay: delaySet,
				onComplete: function(twn:FlxTween)
				{
					FlxTween.tween(cardTxt, {alpha: 0}, 2, {ease: FlxEase.sineInOut, startDelay: 3.5});
				}
			});
		}
		else
		{
			FlxTween.tween(songBanner, {alpha: 0.5}, 1, {ease: FlxEase.circOut, startDelay: delaySet,
				onComplete: function(twn:FlxTween)
				{
					FlxTween.tween(songBanner, {alpha: 0}, 1.5, {ease: FlxEase.circIn, startDelay: 4});
				}
			});

			FlxTween.tween(songBannerText, {alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: delaySet,
				onComplete: function(twn:FlxTween)
				{
					FlxTween.tween(songBannerText, {alpha: 0}, 1.5, {ease: FlxEase.circIn, startDelay: 4});
				}
			});
		}
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