package states.menus;

import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;


class StoryMenu extends MusicBeatState
{
	var scoreText:FlxText;
	var curDifficulty:Int = 1;

	static var lastDifficulty:String = '';

	var weekCharacters:Array<Array<String>> = [];
	var bookImage:Array<String> = ['depression'];

	var txtWeekTitle:FlxText;

	static var curWeek:Int = 0;

	var txtTracklist:FlxText;

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;
	var bookStuff:FlxTypedGroup<FlxSprite>;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var book:FlxSprite;
	var spoopy:FlxSprite;
	var ispy:FlxSprite;
	var gradient:FlxSprite;

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

		#if DISCORD_RPC
		Discord.changePresence('CHOOSING A WEEK', 'Campaign Story Menu');
		#end

		spoopy = new FlxSprite().loadGraphic(Paths.image('menus/Funkin_avi/storymenu/spoopy'));
		spoopy.scrollFactor.set(0, 0);
		spoopy.setGraphicSize(Std.int(spoopy.width * 1.05));
		spoopy.updateHitbox();
		spoopy.scale.set(0.8, 0.8);
		spoopy.screenCenter();
		spoopy.antialiasing = true;
		add(spoopy);

		book = new FlxSprite().loadGraphic(Paths.image('menus/Funkin_avi/storymenu/lethimbook'));
		book.scrollFactor.set(0, 0);
		book.setGraphicSize(Std.int(book.width * 1.1));
		book.updateHitbox();
		book.screenCenter();
		book.scale.set(0.85, 0.85);
		book.antialiasing = true;
		book.alpha = 1;
		if (!Init.trueSettings.get('Disable Screen Shaders')) book.shader = blur;
		add(book);

		ispy = new FlxSprite().loadGraphic(Paths.image('menus/Funkin_avi/storymenu/i_spy'));
		ispy.scrollFactor.set(0, 0);
		ispy.updateHitbox();
		ispy.screenCenter();
		ispy.scale.set(0.8, 0.8);
		ispy.antialiasing = true;
		if (!Init.trueSettings.get('Disable Screen Shaders')) ispy.shader = blur;
		add(ispy);

		bookStuff = new FlxTypedGroup<FlxSprite>();
		add(bookStuff);

		for (i in 0...bookImage.length)
		{
			var image:FlxSprite = new FlxSprite(100, 0).loadGraphic(Paths.image('menus/Funkin_avi/storymenu/bookPics/' + bookImage[i]));
			image.ID = i;
			image.angle = FlxG.random.float(-15, 18);
			image.alpha = 0.0001;
			image.scale.set(0.45, 0.45);
			bookStuff.add(image);
		}

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

		var ui_tex = Paths.getSparrowAtlas('menus/base/storymenu/campaign_menu_UI_assets');
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
					var weekThing:MenuItem = new MenuItem(0, bgSprite.y + 396, WeekData.weeksList[i]);
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
		var charArray:Array<String> = loadedWeeks[0].weekCharacters;
		for (char in 0...3)
		{
			var weekCharacterThing:MenuCharacter = new MenuCharacter((FlxG.width * 0.25) * (1 + char) - 150, charArray[char]);
			weekCharacterThing.y += 70;
			grpWeekCharacters.add(weekCharacterThing);
		}

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

		if (lastDifficulty == '' || lastDifficulty == null)
			lastDifficulty = CoolUtil.defaultDifficulty;

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

		if(!Init.trueSettings.get('Low Quality')) 
		{
			var scratch:FlxSprite = new FlxSprite();
			scratch.frames = Paths.getSparrowAtlas('filters/scratchShit');
			scratch.animation.addByPrefix('idle', 'scratch thing 1', 24, true);
			scratch.animation.play('idle');
			scratch.screenCenter();
			scratch.scale.x = 1.1;
			scratch.scale.y = 1.1;
			add(scratch);
	
			var grain:FlxSprite = new FlxSprite();
			grain.frames = Paths.getSparrowAtlas('filters/Grainshit');
			grain.animation.addByPrefix('idle', 'grains 1', 24, true);
			grain.animation.play('idle');
			grain.screenCenter();
			grain.scale.x = 1.1;
			grain.scale.y = 1.1;
			add(grain);
		}

		gradient = new FlxSprite().loadGraphic(Paths.image('filters/gradient'));
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
		var weekProgress = Main.weeksMap.get(week);
		return weekProgress.startsLocked;
	}

	override function update(elapsed:Float)
	{
		var lerpVal = Main.framerateAdjust(0.5);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, lerpVal));

		if (scoreText != null)
			scoreText.text = "WEEK SCORE:" + lerpScore;

		if (FlxG.sound.music != null && FlxG.sound.music.playing)
			base.song.Conductor.songPosition = FlxG.sound.music.time;

		if (grpLocks != null)
		{
			grpLocks.forEach(function(lock:FlxSprite)
			{
				lock.y = grpWeekText.members[lock.ID].y;
			});
		}

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;

		if (!movedBack)
		{
			if (!selectedWeek && (leftArrow != null && rightArrow != null))
			{
				if (upP)
				{
					changeWeek(-1);
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}

				if (downP)
				{
					changeWeek(1);
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}

				if(FlxG.mouse.wheel != 0)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					changeWeek(-FlxG.mouse.wheel);
					changeDifficulty();
				}

				if (controls.UI_RIGHT)
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
					changeDifficulty();

				if(FlxG.keys.justPressed.CONTROL)
				{
					persistentUpdate = false;
					openSubState(new GameplayChangersSubstate());
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
			Main.switchState(this, new MainMenu());
		}

		super.update(elapsed);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		var lockedWeek:Bool = checkProgression(Main.weeks[curWeek]);

		if (!lockedWeek)
		{
			if (!stopspamming)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));
				stopspamming = true;
			}

			var gameWeek = Main.weeksMap.get(Main.weeks[curWeek]);
			var weekSongs:Array<String> = [];

			// loop through week songs;
			for (song in 0...gameWeek.songs.length)
				weekSongs.push(gameWeek.songs[song].name);

			PlayState.storyPlaylist = (weekSongs != null ? weekSongs : ['test']);
			PlayState.gameplayMode = STORY;
			selectedWeek = true;

			var song:String = PlayState.storyPlaylist[0];
			var diff:String = '-' + CoolUtil.difficultyFromNumber(curDifficulty);

			if (!sys.FileSystem.exists(Paths.songJson(song, song + '-' + CoolUtil.defaultDifficulty.toLowerCase())))
				CoolUtil.defaultDifficulty = '';

			if (curDifficulty == 1)
				diff = CoolUtil.defaultDifficulty;

			if (song != null && diff != null)
			{
				PlayState.SONG = Song.loadFromJson(song.toLowerCase() + diff, song);
				CoolUtil.difficultyString = CoolUtil.difficultyFromNumber(curDifficulty);

				PlayState.storyDifficulty = curDifficulty;
				PlayState.storyWeek = curWeek;
				PlayState.campaignScore = 0;

				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					Main.switchState(this, new PlayState());
				});
			}
			else
			{
				stopspamming = false;
				selectedWeek = false;
			}
		}
	}

	var difficultyTween:FlxTween;

	function changeDifficulty(change:Int = 0):Void
	{
		var week = Main.weeksMap.get(Main.weeks[curWeek]);
		CoolUtil.difficulties = week.difficulties == null ? CoolUtil.difficultyArray : week.difficulties;
		curDifficulty = FlxMath.wrap(curDifficulty + change, 0, CoolUtil.difficulties.length - 1);

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

		intendedScore = ScoreUtils.getWeekScore(curWeek, curDifficulty);

		FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07);
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek = FlxMath.wrap(curWeek + change, 0, Main.weeks.length - 1);

		var lockedWeek:Bool = checkProgression(Main.weeks[curWeek]);
		difficultySelectors.visible = !lockedWeek;

		var storyName:String = Main.weeksMap.get(Main.weeks[curWeek]).storyName;
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

		FlxG.sound.play(Paths.sound('base/menus/scrollMenu'));

		changeDifficulty();
		updateText();
	}

	function updateText()
	{
		var gameWeek = Main.weeksMap.get(Main.weeks[curWeek]);
		var weekChars = gameWeek.characters;

		bookStuff.forEach(function(image:FlxSprite)
		{
			image.alpha	= 0.0001;
		});

		if (bookStuff.members[curWeek] != null)
			bookStuff.members[curWeek].alpha = 1;

		//for (sillyBooks in bookStuff)
		//	sillyBooks.angle = FlxG.random.float(-15, 18);
			
		for (i in 0...grpWeekCharacters.length)
			grpWeekCharacters.members[i].createCharacter(weekChars[i], true);
		txtTracklist.text = "Tracks\n";

		var stringThing:Array<String> = [];

		for (i in 0...gameWeek.songs.length)
			stringThing.push(gameWeek.songs[i].name);

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

		intendedScore = ScoreUtils.getWeekScore(curWeek, curDifficulty);
	}
}
