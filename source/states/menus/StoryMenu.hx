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
	var weekIcon:FlxSprite;
	var list:FlxSprite;

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

		defaultShader2 = new FlxRuntimeShader(Shaders.monitorFilter, null, 140);
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

		DiscordClient.changePresence('Story Menu', 'Selecting Episode...');

		book = new FlxSprite().loadGraphic(Paths.image('Funkin_avi/storymenu/storyBook' + (GameData.episode1FPLock == "unlocked" ? "-evil" : "")));
		book.scrollFactor.set(0, 0);
		book.setGraphicSize(Std.int(book.width * 1.1));
		book.updateHitbox();
		book.screenCenter();
		book.scale.set(1, 1);
		book.antialiasing = true;
		book.alpha = 1;
		add(book);

		bookStuff = new FlxTypedGroup<FlxSprite>();
		add(bookStuff);

		// I have a present simple for you

		booksimage = new FlxSprite();
		booksimage.antialiasing = ClientPrefs.globalAntialiasing;
		add(booksimage); // Istg, i need to learn some day about the arrays ugh

		weekIcon = new FlxSprite();
		weekIcon.antialiasing = ClientPrefs.globalAntialiasing;
		add(weekIcon);

		list = new FlxSprite();
		list.antialiasing = ClientPrefs.globalAntialiasing;
		add(list);


		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);

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
				num++;
			}
		}

		WeekData.setDirectoryFromWeek(loadedWeeks[0]);

		difficultySelectors = new FlxGroup();

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		if(lastDifficulty == '')
		{
			lastDifficulty = CoolUtil.defaultDifficulty;
		}
		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(lastDifficulty)));

		//add(yellowBG);
		add(grpWeekCharacters);

		if(!ClientPrefs.lowQuality) 
		{
			var fogShit:FlxSprite = new FlxSprite().loadGraphic(Paths.image('Funkin_avi/storymenu/supa_dark_mode'));
			fogShit.screenCenter();
			add(fogShit);

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
		// just got an idea but need to rename the files

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 30, 0, 1)));
		if(Math.abs(intendedScore - lerpScore) < 10) lerpScore = intendedScore;

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
				/*
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
			MusicBeatState.switchState(new MainMenuState());
		}

		super.update(elapsed);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
				if (stopspamming == false)
				{
					FlxG.sound.play(Paths.sound('funkinAVI/menu/confirmEpisode'));
					stopspamming = true;

					@:privateAccess
					{
						FlxG.camera._fxFlashColor = FlxColor.WHITE;
						FlxG.camera._fxFlashDuration = .5;
						FlxG.camera._fxFlashAlpha = .5;
					}
					new FlxTimer().start(.25, d -> FlxG.camera.fade(0x000000, .75));
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
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek = FlxMath.wrap(curWeek + change, 0, WeekData.weeksList.length - 1);

		var lockedWeek:Bool = checkProgression(WeekData.weeksList[curWeek]);
		difficultySelectors.visible = !lockedWeek;

		var storyName:String = WeekData.weeksLoaded.get(WeekData.weeksList[curWeek]).storyName;

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
		booksimage.loadGraphic(Paths.image('Funkin_avi/storymenu/art$curWeek' + (GameData.episode1FPLock == "unlocked" ? "-evil" : "")));
		weekIcon.loadGraphic(Paths.image('Funkin_avi/storymenu/title$curWeek' + (GameData.episode1FPLock == "unlocked" ? "-evil" : "")));
		list.loadGraphic(Paths.image('Funkin_avi/storymenu/songs$curWeek' + (GameData.episode1FPLock == "unlocked" ? "-evil" : "")));
	}
}
