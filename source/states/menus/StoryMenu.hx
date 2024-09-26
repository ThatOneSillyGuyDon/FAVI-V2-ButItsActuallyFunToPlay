package states.menus;

import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import lime.app.Application;
import sys.FileSystem;
import flash.system.System;

class StoryMenu extends MusicBeatState
{
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();

	var scoreText:FlxText;
	var curDifficulty:Int = 1;

	static var lastDifficulty:String = '';

	var weekCharacters:Array<Array<String>> = [];
	var bookImages:Array<String> = ['depression']; // For sum reason it dosent work brah, time to activate my secret mind - malyplus


	var bgSprite:FlxSprite;
	var txtWeekTitle:FlxText;

	static var curWeek:Int = 0;

	var txtTracklist:FlxText;

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;
	var bookStuff:FlxTypedGroup<FlxSprite>;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var loadedWeeks:Array<WeekData> = [];

	var book:FlxSprite;
	var spoopy:FlxSprite;
	var ispy:FlxSprite;
	var gradient:FlxSprite;
	
	var booksimage:FlxSprite;
	var weekshitcausepsychhatesme:FlxSprite;

	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	var defaultShader:FlxRuntimeShader;
	var defaultShader2:FlxRuntimeShader;
	var blur:FlxRuntimeShader;

	override function create()
	{
		super.create();

		defaultShader = new FlxRuntimeShader(Shaders.grayScale, null, 140);
		defaultShader2 = new FlxRuntimeShader(Shaders.monitorFilter, null, 140);
		blur = new FlxRuntimeShader(Shaders.theBlurOf87, null, 140);
		FlxG.camera.setFilters(
			[
				new openfl.filters.ShaderFilter(defaultShader2)
			]);

		PlayState.isStoryMode = true;
		WeekData.reloadWeekFiles(true);
		if(curWeek >= WeekData.weeksList.length) curWeek = 0;
		persistentUpdate = persistentDraw = true;

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		DiscordClient.changePresence('CHOOSING A WEEK', 'Campaign Story Menu');

		spoopy = new FlxSprite().loadGraphic(Paths.image('Funkin_avi/storymenu/spoopy'));
		spoopy.scrollFactor.set(0, 0);
		spoopy.setGraphicSize(Std.int(spoopy.width * 1.05));
		spoopy.updateHitbox();
		spoopy.scale.set(0.8, 0.8);
		spoopy.screenCenter();
		spoopy.antialiasing = true;
		add(spoopy);

		book = new FlxSprite().loadGraphic(Paths.image('Funkin_avi/storymenu/lethimbook'));
		book.scrollFactor.set(0, 0);
		book.setGraphicSize(Std.int(book.width * 1.1));
		book.updateHitbox();
		book.screenCenter();
		book.scale.set(0.85, 0.85);
		book.antialiasing = true;
		book.alpha = 1;
		if (ClientPrefs.shaders) book.shader = blur;
		add(book);

		ispy = new FlxSprite().loadGraphic(Paths.image('Funkin_avi/storymenu/i_spy'));
		ispy.scrollFactor.set(0, 0);
		ispy.updateHitbox();
		ispy.screenCenter();
		ispy.scale.set(0.8, 0.8);
		ispy.antialiasing = true;
		if (ClientPrefs.shaders) ispy.shader = blur;
		add(ispy);

		bookStuff = new FlxTypedGroup<FlxSprite>();
		add(bookStuff);

		/*for (i in 0...bookImage.length)
		{
			var image:FlxSprite = new FlxSprite(100, 0).loadGraphic(Paths.image('Funkin_avi/storymenu/bookPics/' + bookImage[i]));
			image.ID = i;
			image.angle = FlxG.random.float(-15, 18);
			image.alpha = 0.0001;
			image.scale.set(0.45, 0.45);
			bookStuff.add(image);
		}*/


		// I have a present simple for you

		booksimage = new FlxSprite(100, 0);
		booksimage.angle = FlxG.random.float(-15, 18);
		booksimage.alpha = 0.0001;
		booksimage.scale.set(0.45, 0.45);
		add(booksimage); // Istg, i need to learn some day about the arrays ugh


		scoreText = new FlxText(10, 10, 0, "SCORE: 49324858", 36);
		scoreText.setFormat(Paths.font("vcr"), 32);

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat(Paths.font("vcr"), 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;

		var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("DisneyFont"), 32);
		rankText.size = scoreText.size;
		rankText.screenCenter(X);

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		var yellowBG:FlxSprite = new FlxSprite(0, 56).makeGraphic(FlxG.width, 400, 0xFFF9CF51);

		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		//add(blackBarThingie);

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		var num:Int = 0;
		for (i in 0...WeekData.weeksList.length)
			{
				var weekFile:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
				var isLocked:Bool = weekIsLocked(WeekData.weeksList[i]);
				if(!isLocked || !weekFile.hiddenUntilUnlocked)
				{
					loadedWeeks.push(weekFile);
					WeekData.setDirectoryFromWeek(weekFile);
					var weekThing:MenuItem = new MenuItem(0, yellowBG.y + yellowBG.height + 10, WeekData.weeksList[i]);
					weekThing.y += ((weekThing.height + 20) * num);
					weekThing.targetY = num;
					grpWeekText.add(weekThing);
	
					weekThing.screenCenter(X);
					weekThing.antialiasing = ClientPrefs.globalAntialiasing;
					// weekThing.updateHitbox();
	
					// Needs an offset thingie
					if (isLocked)
					{
						var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
						lock.frames = ui_tex;
						lock.animation.addByPrefix('lock', 'lock');
						lock.animation.play('lock');
						lock.ID = i;
						lock.antialiasing = ClientPrefs.globalAntialiasing;
						grpLocks.add(lock);
					}
					num++;
				}
			}

		WeekData.setDirectoryFromWeek(loadedWeeks[0]);

		difficultySelectors = new FlxGroup();

		leftArrow = new FlxSprite(grpWeekText.members[0].x + grpWeekText.members[0].width + 10, grpWeekText.members[0].y + 150);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		difficultySelectors.add(leftArrow);

		//
		sprDifficulty = new FlxSprite(0, leftArrow.y);
		sprDifficulty.antialiasing = true;
		difficultySelectors.add(sprDifficulty);

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		if(lastDifficulty == '')
		{
			lastDifficulty = CoolUtil.defaultDifficulty;
		}
		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(lastDifficulty)));

		rightArrow = new FlxSprite(leftArrow.x + 376, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		difficultySelectors.add(rightArrow);

		//add(yellowBG);
		add(grpWeekCharacters);

		txtTracklist = new FlxText(1070, 90, 0, "Tracks", 38);
		txtTracklist.setFormat(Paths.font("DisneyFont"), 32, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		txtTracklist.borderSize = 2;
		add(txtTracklist);
		// add(rankText);
		//add(scoreText);
		add(txtWeekTitle);

		add(difficultySelectors);

		if(!ClientPrefs.lowQuality) 
		{
			var scratch:FlxSprite = new FlxSprite();
			scratch.frames = Paths.getSparrowAtlas('Funkin_avi/filters/scratchShit');
			scratch.animation.addByPrefix('idle', 'scratch thing 1', 24, true);
			scratch.animation.play('idle');
			scratch.screenCenter();
			scratch.scale.x = 1.1;
			scratch.scale.y = 1.1;
			add(scratch);
	
			var grain:FlxSprite = new FlxSprite();
			grain.frames = Paths.getSparrowAtlas('Funkin_avi/filters/Grainshit');
			grain.animation.addByPrefix('idle', 'grains 1', 24, true);
			grain.animation.play('idle');
			grain.screenCenter();
			grain.scale.x = 1.1;
			grain.scale.y = 1.1;
			add(grain);
		}

		gradient = new FlxSprite().loadGraphic(Paths.image('Funkin_avi/filters/gradient'));
		gradient.scrollFactor.set(0, 0);
		gradient.setGraphicSize(Std.int(gradient.width * 1));
		gradient.updateHitbox();
		gradient.screenCenter();
		gradient.antialiasing = true;
		add(gradient);

		// very unprofessional yoshubs!

		changeWeek();
		changeDifficulty();
		updateText();
	}

	inline function checkProgression(week:String):Bool
	{
		// here we check if the target week is locked;
		var weekProgress:WeekData = WeekData.weeksLoaded.get(week);
		return weekProgress.startUnlocked;
	}

	override function update(elapsed:Float)
	{
		if (curWeek == 0) // idk with one works so erm fuck
		{
			booksimage.loadGraphic(Paths.image('Funkin_avi/storymenu/bookPics/depression'));
			booksimage.alpha = 1;
		}
		else
		{
			booksimage.alpha = 0.0001; // fack you its going to disapear mode
		}


		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 30, 0, 1)));
		if(Math.abs(intendedScore - lerpScore) < 10) lerpScore = intendedScore;

		if (scoreText != null)
			scoreText.text = "WEEK SCORE:" + lerpScore;

		if (FlxG.sound.music != null && FlxG.sound.music.playing)
			Conductor.songPosition = FlxG.sound.music.time;

		if (grpLocks != null)
		{
			grpLocks.forEach(function(lock:FlxSprite)
			{
				lock.y = grpWeekText.members[lock.ID].y;
			});
		}

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;

		var rightP = controls.UI_RIGHT_P;
		var leftP = controls.UI_LEFT_P;

		if (!movedBack)
		{
			if (!selectedWeek && (leftArrow != null && rightArrow != null))
			{
				/*if (leftP)
				{
					changeWeek(-1);
					FlxG.sound.play(Paths.sound('scrollMenu'));
					booksimage.angle = FlxG.random.float(-15, 18);
				}

				if (rightP)
				{
					changeWeek(1);
					FlxG.sound.play(Paths.sound('scrollMenu'));
					booksimage.angle = FlxG.random.float(-15, 18); // yes
				}*/

				if(FlxG.mouse.wheel != 0)
				{
					FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'), 0.4);
					changeWeek(-FlxG.mouse.wheel);
					changeDifficulty();
				}

				// WE DONT NEED IT GRAHHHH CAUSE ONLY HARD MODE IS IN THIS MOD I THINK!!!!!!!!!!!!!!!!!!! - MalyPlus
				/*if (controls.UI_RIGHT)
					rightArrow.animation.play('press')
				else
					rightArrow.animation.play('idle');

				if (controls.UI_LEFT)
					leftArrow.animation.play('press');
				else
					leftArrow.animation.play('idle');

				if (controls.UI_RIGHT_P)
					changeDifficulty(1);
				else if (controls.UI_LEFT_P)
					changeDifficulty(-1);
				else if (upP || downP)
					changeDifficulty();*/
				if (leftP || rightP)
				{
					changeDifficulty(); // nothing special, just in case
				}

				if(FlxG.keys.justPressed.CONTROL)
				{
					persistentUpdate = false;

					// Funni - MalyPlus
					lime.app.Application.current.window.title = "Nah you thought you would be able to use BotPlay? nah.. im gonna shut down this app.";
					new FlxTimer().start(0.3, function(tmr:FlxTimer)
					{
						System.exit(0);
					});


					// nah we aint letting them use botplay
					//openSubState(new GameplayChangersSubstate());
				}
				else if(controls.RESET)
				{
					persistentUpdate = false;
					openSubState(new ResetScoreSubState('', curDifficulty, '', curWeek));
					//FlxG.sound.play(Paths.sound('scrollMenu'));
				}
			}

			if (controls.ACCEPT)
			{
				selectWeek();
			}
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			MusicBeatState.switchState(new MainMenu());
		}

		super.update(elapsed);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (!weekIsLocked(loadedWeeks[curWeek].fileName))
			{
				if (stopspamming == false)
				{
					FlxG.sound.play(Paths.sound('funkinAVI/menu/confirmEpisode'));
					grpWeekText.members[curWeek].startFlashing();
					stopspamming = true;
				}
	
				// We can't use Dynamic Array .copy() because that crashes HTML5, here's a workaround.
				var songArray:Array<String> = [];
				var leWeek:Array<Dynamic> = loadedWeeks[curWeek].songs;
				for (i in 0...leWeek.length) {
					songArray.push(leWeek[i][0]);
				}
	
				// Nevermind that's stupid lmao
				PlayState.storyPlaylist = songArray;
				PlayState.isStoryMode = true;
				selectedWeek = true;

				var songLowercase:String = Paths.formatToSongPath(PlayState.storyPlaylist[0]);
	
				var diffic = CoolUtil.getDifficultyFilePath(curDifficulty);
				if(diffic == null) diffic = '';
	
				PlayState.storyDifficulty = curDifficulty;
	
				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, songLowercase);
				PlayState.campaignScore = 0;
				PlayState.campaignMisses = 0;
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					LoadingState.loadAndSwitchState(new PlayState(), true);
					FreeplayState.destroyFreeplayVocals();
				});
			} else {
				FlxG.sound.play(Paths.sound('cancelMenu'));
			}
	}

	var difficultyTween:FlxTween;

	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficulties.length-1;
		if (curDifficulty >= CoolUtil.difficulties.length)
			curDifficulty = 0;

		WeekData.setDirectoryFromWeek(loadedWeeks[curWeek]);

		var coolDifficulty:String = CoolUtil.difficulties[curDifficulty];
		var diffGraphic:FlxGraphic = Paths.image('menudifficulties/' + CoolUtil.swapSpaceDash(coolDifficulty));

		if (sprDifficulty.graphic != diffGraphic)
		{
			sprDifficulty.loadGraphic(diffGraphic);
			sprDifficulty.x = leftArrow.x + 60;
			sprDifficulty.x += (308 - sprDifficulty.width) / 3;
			sprDifficulty.y = leftArrow.y - 15;
			sprDifficulty.alpha = 0;

			if (difficultyTween != null)
				difficultyTween.cancel();
			difficultyTween = FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07, {
				onComplete: function(twn:FlxTween)
				{
					difficultyTween = null;
				}
			});
		}
		lastDifficulty = coolDifficulty;

		intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);

		FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07);
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek = FlxMath.wrap(curWeek + change, 0, WeekData.weeksList.length - 1);

		var lockedWeek:Bool = checkProgression(WeekData.weeksList[curWeek]);
		difficultySelectors.visible = !lockedWeek;

		var storyName:String = WeekData.weeksLoaded.get(WeekData.weeksList[curWeek]).storyName;
		txtWeekTitle.text = storyName.toUpperCase();
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);



		lime.app.Application.current.window.title = "Funkin.avi - Story Menu - " + storyName;

		var bullShit:Int = 0;

		for (item in grpWeekText.members)
		{
			switch (curWeek)
			{
				case 0:
					item.x = 20;
				case 1:
					item.x = -20;
				case 2:
					item.x = 150;
			}
			item.targetY = bullShit - curWeek;
			if (item.targetY == 0 && !lockedWeek) {
				item.alpha = 1;
			} else {
				item.alpha = 0;
			}
			bullShit++;
		}

		FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'));

		changeDifficulty();
		updateText();
	}

	
	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!weekCompleted.exists(leWeek.weekBefore) || !weekCompleted.get(leWeek.weekBefore)));
	}
	
	function updateText()
	{
		var weekArray:Array<String> = loadedWeeks[curWeek].weekCharacters;
		for (i in 0...grpWeekCharacters.length) {
			grpWeekCharacters.members[i].changeCharacter(weekArray[i]);
		}

		var leWeek:WeekData = loadedWeeks[curWeek];
		var stringThing:Array<String> = [];
		for (i in 0...leWeek.songs.length) {
			stringThing.push(leWeek.songs[i][0]);
		}
		
		txtTracklist.text = "Tracks\n";

		for (i in stringThing)
			txtTracklist.text += "\n" + CoolUtil.dashToSpace(i);

		txtTracklist.text += "\n"; // pain
		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);

		switch (curWeek)
		{
			case 0:
				txtTracklist.x = 870;
			case 1:
				txtTracklist.x = 805;
			case 2:
				txtTracklist.x = 915;
		}

		intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);
	}
}
