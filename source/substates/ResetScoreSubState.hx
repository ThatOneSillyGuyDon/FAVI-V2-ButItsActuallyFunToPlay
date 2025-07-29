package substates;

class ResetScoreSubState extends MusicBeatSubstate
{
	var bg:FlxSprite;
	var optionsCam:FlxCamera = new FlxCamera();
	var alphabetArray:Array<FlxTextAlphabet> = [];
	var icon:HealthIcon;
	var onYes:Bool = false;
	var yesText:FlxTextAlphabet;
	var noText:FlxTextAlphabet;

	var song:String;
	var difficulty:Int;
	var week:Int;

	var tiles:FlxBackdrop;

	// Week -1 = Freeplay
	public function new(song:String, difficulty:Int, character:String, week:Int = -1)
	{
		this.song = song;
		this.difficulty = difficulty;
		this.week = week;
		FlxG.cameras.add(optionsCam,false);
		optionsCam.bgColor = FlxColor.TRANSPARENT;
		super();

		var name:String = song;
		if(week > -1) {
			name = WeekData.weeksLoaded.get(WeekData.weeksList[week]).weekName;
		}
		name += '?';

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.camera = optionsCam;
		bg.scrollFactor.set();
		add(bg);

		tiles = new FlxBackdrop(Paths.image("Funkin_avi/pause/ui/mickeyTiles"), XY, 0, 0);
		tiles.alpha = 0.2;
		tiles.velocity.set(50, 30);
		tiles.camera = optionsCam;
		tiles.color = FlxColor.fromRGB(65, 88, 94);
		tiles.blend = OVERLAY;
		add(tiles);

		var tooLong:Float = (name.length > 18) ? 0.8 : 1; //Fucking Winter Horrorland
		var text:FlxTextAlphabet = new FlxTextAlphabet(0, 180, "Reset the score of", true);
		text.setFormat(Paths.font("newFreeplayFont.ttf"), 70, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		text.screenCenter(X);
		alphabetArray.push(text);
		text.alpha = 0;
		text.camera = optionsCam;
		add(text);
		var text:FlxTextAlphabet = new FlxTextAlphabet(0, text.y + 90, name, true);
		text.scale.x = tooLong;
		text.setFormat(Paths.font("newFreeplayFont.ttf"), 70, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		text.camera = optionsCam;
		text.screenCenter(X);
		if(week == -1) text.x += 60 * tooLong;
		alphabetArray.push(text);
		text.alpha = 0;
		add(text);
		if(week == -1) {
			icon = new HealthIcon(character);
			icon.setGraphicSize(Std.int(icon.width * tooLong));
			icon.updateHitbox();
			icon.camera = optionsCam;
			icon.setPosition(text.x - icon.width + (10 * tooLong), text.y - 30);
			icon.alpha = 0;
			add(icon);
		}

		yesText = new FlxTextAlphabet(0, text.y + 150, 'Yes', true);
		yesText.screenCenter(X);
		yesText.camera = optionsCam;
		yesText.setFormat(Paths.font("newFreeplayFont.ttf"), 70, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		yesText.x -= 200;
		add(yesText);
		noText = new FlxTextAlphabet(0, text.y + 150, 'No', true);
		noText.screenCenter(X);
		noText.camera = optionsCam;
		noText.setFormat(Paths.font("newFreeplayFont.ttf"), 70, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		noText.x += 200;
		add(noText);
		updateOptions();
	}

	override function update(elapsed:Float)
	{
		bg.alpha += elapsed * 1.5;
		if(bg.alpha > 0.6) bg.alpha = 0.6;

		for (i in 0...alphabetArray.length) {
			var spr = alphabetArray[i];
			spr.alpha += elapsed * 2.5;
		}
		if(week == -1) icon.alpha += elapsed * 2.5;

		if(controls.UI_LEFT_P || controls.UI_RIGHT_P) {
			FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'), 1);
			onYes = !onYes;
			updateOptions();
		}
		if(controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'), 1);
			FlxG.cameras.remove(optionsCam);
			close();
		} else if(controls.ACCEPT) {
			if(onYes) {
				if(week == -1) {
					Highscore.resetSong(song, difficulty);
				} else {
					Highscore.resetWeek(WeekData.weeksList[week], difficulty);
				}
			}
			FlxG.sound.play(Paths.sound('cancelMenu'), 1);
			FlxG.cameras.remove(optionsCam);
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
		if(week == -1) icon.animation.curAnim.curFrame = confirmInt;
	}
}