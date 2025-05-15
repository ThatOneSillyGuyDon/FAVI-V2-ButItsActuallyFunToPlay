package substates;

class ResetScoreSubState extends MusicBeatSubstate
{
	var bg:FlxSprite;
	var optionsCam:FlxCamera = new FlxCamera();
	var alphabetArray:Array<FlxText> = [];
	var icon:HealthIcon;
	var onYes:Bool = false;
	var yesText:FlxText;
	var noText:FlxText;

	var song:String;
	var difficulty:Int;
	var week:Int;

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
		name += ' (' + CoolUtil.difficulties[difficulty] + ')?';

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.camera = optionsCam;
		bg.scrollFactor.set();
		add(bg);

		var tooLong:Float = (name.length > 18) ? 0.8 : 1; //Fucking Winter Horrorland
		var text:FlxText = new FlxText(0, 180, FlxG.width, "Reset the score of", 60);
		text.setFormat(Paths.font("DisneyFont.ttf"), 60, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		text.screenCenter(X);
		alphabetArray.push(text);
		text.borderSize = 1.25;
		text.alpha = 0;
		text.camera = optionsCam;
		add(text);

		var text:FlxText = new FlxText(0, text.y + 90, FlxG.width, name, 60);
		text.setFormat(Paths.font("DisneyFont.ttf"), 60, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		text.scale.x = tooLong;
		text.camera = optionsCam;
		text.screenCenter(X);
		if(week == -1) text.x += 60 * tooLong;
		text.borderSize = 1.25;
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

		yesText = new FlxText(0, text.y + 150, FlxG.width, "Yes", 60);
		yesText.setFormat(Paths.font("DisneyFont.ttf"), 60, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		yesText.screenCenter(X);
		yesText.borderSize = 1.25;
		yesText.camera = optionsCam;
		yesText.x -= 200;
		add(yesText);

		noText = new FlxText(0, text.y + 150, FlxG.width, "No", 60);
		noText.setFormat(Paths.font("DisneyFont.ttf"), 60, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		noText.screenCenter(X);
		noText.borderSize = 1.25;
		noText.camera = optionsCam;
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
			FlxG.sound.play(Paths.sound('scrollMenu'), 1);
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