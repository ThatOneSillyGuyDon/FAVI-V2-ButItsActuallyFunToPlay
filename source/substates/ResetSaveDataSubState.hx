package substates;

class ResetSaveDataSubState extends MusicBeatSubstate
{
	var bg:FlxSprite;
	var tiles:FlxBackdrop;

	var warning:FlxTextAlphabet;
	var desc:FlxTextAlphabet;

	var onYes:Bool = false;
	var yesText:FlxTextAlphabet;
	var noText:FlxTextAlphabet;

	public function new()
	{
		super();

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.scrollFactor.set();

		tiles = new FlxBackdrop(Paths.image("Funkin_avi/pause/ui/mickeyTiles"), XY, 0, 0);
		tiles.velocity.set(50, 30);
		tiles.color = FlxColor.fromRGB(65, 88, 94);
		tiles.blend = OVERLAY;

		warning = new FlxTextAlphabet(0, 150, "", true);
		warning.setFormat(Paths.font("newFreeplayFont.ttf"), 50, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		warning.screenCenter(X).x -= 100;
		warning.applyMarkup('*~WARNING~*',
			[
				new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.RED), "*")
			]
		);

		desc = new FlxTextAlphabet(200, 250, "", true);
		desc.setFormat(Paths.font("newFreeplayFont.ttf"), 35, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		desc.applyMarkup('You are about to *PERMANENTLY DELETE* your save data.\nAre you sure you want to *delete* your save data?\n*It cannot be recovered once deleted.*',
			[
				new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.RED), "*")
			]
		);

		for (i in [bg, tiles, warning, desc])
		{
			i.alpha = 0;
			add(i);
		}

		yesText = new FlxTextAlphabet(0, desc.y + 150, 'Yes', true);
		yesText.screenCenter(X);
		yesText.setFormat(Paths.font("newFreeplayFont.ttf"), 70, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		yesText.x -= 200;
		yesText.alpha = 0.6;
		add(yesText);
		noText = new FlxTextAlphabet(0, desc.y + 150, 'No', true);
		noText.screenCenter(X);
		noText.setFormat(Paths.font("newFreeplayFont.ttf"), 70, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		noText.x += 200;
		noText.alpha = 1;
		add(noText);
		updateOptions();
	}

	override function update(elapsed:Float)
	{
		bg.alpha += elapsed * 1.5;
		if(bg.alpha > 0.6) bg.alpha = 0.6;

		tiles.alpha += elapsed * 1.5;
		if(tiles.alpha > 0.2) tiles.alpha = 0.2;

		warning.alpha += elapsed * 1.5;
		if(warning.alpha > 1) warning.alpha = 1;

		desc.alpha += elapsed * 1.5;
		if(desc.alpha > 1) desc.alpha = 1;

		if(controls.UI_LEFT_P || controls.UI_RIGHT_P) {
			FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'), 1);
			onYes = !onYes;
			updateOptions();
		}
		if(controls.BACK) 
		{
			MainMenuState.selectedSomethin = false;
			FlxG.sound.play(Paths.sound('cancelMenu'), 1);
			close();
		} else if(controls.ACCEPT) {
			FlxG.sound.play(Paths.sound('cancelMenu'), 1);
			if(onYes) {
				GameData.resetData();
				TitleState.initialized = TitleState.closedState = false;
				FlxG.sound.music.fadeOut(0.3);
				FlxG.camera.fade(FlxColor.BLACK, 0.5, false, FlxG.resetGame, false);
			}
			else {
				MainMenuState.selectedSomethin = false;
			}
			close();
		}
		
		super.update(elapsed);
	}

	function updateOptions() {
		var scales:Array<Float> = [0.75, 1];
		var alphas:Array<Float> = [0.6, 1.25];
		var confirmInt:Int = onYes ? 1 : 0;

		yesText.alpha = alphas[confirmInt];
		yesText.scale.set(scales[confirmInt], scales[confirmInt]);
		noText.alpha = alphas[1 - confirmInt];
		noText.scale.set(scales[1 - confirmInt], scales[1 - confirmInt]);
	}
}