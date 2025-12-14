package states.menus;

class CutsceneState extends MusicBeatState
{
    var vidToPlay:VideoSprite;
    var pauseIcon:FlxSprite;

    var cutsceneButtons:FlxTypedGroup<FlxSprite>;
	var cutsceneOptions:Array<String> = [
        'episodeStart', 
        'devilishIntro',
        'isolatedIntro',
        'lunacyIntro',
        'deluLyrics',
        'minniePart',
        'mickeyDeath'
    ];
    var curSelected:Int = 0;

    var camVideo:FlxCamera;
    var camOther:FlxCamera;

    var canUseControls:Bool = true;

    var fpTitle:FlxText;
    
    override function create()
    { 
        #if desktop
		DiscordClient.changePresence('Cutscene Gallery', 'Browsing...', 'icon', 'mouse');
		#end

        openfl.Lib.application.window.title = "Funkin.avi - Cutscene Gallery";

        camVideo = new FlxCamera();
        camOther = new FlxCamera();

        camVideo.bgColor.alpha = 0;
        camOther.bgColor.alpha = 0;

        FlxG.cameras.add(camVideo, false);
        FlxG.cameras.add(camOther, false);

        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('Funkin_avi/category/menuBG'));
        bg.screenCenter();
        add(bg);

        cutsceneButtons = new FlxTypedGroup<FlxSprite>();
		add(cutsceneButtons);
		for (i in 0...cutsceneOptions.length)
		{
			var offset = 108 - (Math.max(cutsceneOptions.length, 4) - 4) * 80;
			var menuItem = new FlxSprite(0, (i * 100) + offset);
			menuItem.updateHitbox();
			menuItem.loadGraphic(Paths.image('Funkin_avi/cutsceneMenu/cutscenes/' + cutsceneOptions[i]));
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItem.x += 560;
			cutsceneButtons.add(menuItem);
            menuItem.scale.set(0.14, 0.14);
            menuItem.alpha = 0.45;
			switch (menuItem.ID)
			{
				case 0:
					menuItem.x -= 300;
					menuItem.y = 130;
				case 1:
					menuItem.x -= 100;
					menuItem.y = 130;
				case 2:
					menuItem.x += 100;
					menuItem.y = 130;
				case 3:
					menuItem.x += 300;
					menuItem.y = 130;
				case 4:
					menuItem.x -= 200;
					menuItem.y = 260;
				case 5:
					menuItem.y = 260;
				case 6:
                    menuItem.x += 200;
					menuItem.y = 260;
			}
			menuItem.antialiasing = ClientPrefs.data.antialiasing;
			menuItem.updateHitbox();

		}
        
        fpTitle = new FlxText(0, 40, 1280, "Cutscene Gallery");
        fpTitle.setFormat(Paths.font('Oceanic_Cocktail_Demo.otf'), 65, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
        fpTitle.screenCenter(X);
        fpTitle.borderSize = 3;
        add(fpTitle);

        pauseIcon = new FlxSprite().loadGraphic(Paths.image('Funkin_avi/cutsceneMenu/pauseIcon'));
        pauseIcon.cameras = [camVideo];
        pauseIcon.visible = false;
        pauseIcon.screenCenter();
        
        super.create();

        if(!ClientPrefs.data.lowQuality) {
			var scratchStuff:FlxSprite = new FlxSprite();
			scratchStuff.frames = Paths.getSparrowAtlas('Funkin_avi/filters/scratchShit');
			scratchStuff.animation.addByPrefix('idle', 'scratch thing 1', 24, true);
			scratchStuff.animation.play('idle');
			scratchStuff.screenCenter();
            scratchStuff.cameras = [camOther];
			scratchStuff.scale.x = 1.1;
			scratchStuff.scale.y = 1.1;
			add(scratchStuff);

			var grain:FlxSprite = new FlxSprite();
			grain.frames = Paths.getSparrowAtlas('Funkin_avi/filters/Grainshit');
			grain.animation.addByPrefix('idle', 'grains 1', 24, true);
			grain.animation.play('idle');
			grain.screenCenter();
            grain.cameras = [camOther];
			grain.scale.x = 1.1;
			grain.scale.y = 1.1;
			add(grain);
		}

        FlxG.mouse.load(Paths.image('favi/ui/Cursor').bitmap);
		FlxG.mouse.visible = true;
    }

    override function update(elapsed:Float)
    {
        if (canUseControls)
        {
            if (controls.BACK)
            {
                FlxG.sound.play(Paths.sound("cancelMenu"));
                if (FlxG.random.bool(8) && GameData.episode1FPLock == "unlocked")
                {
                    FlxG.sound.music.fadeOut(0.5);
                    MusicBeatState.switchState(new states.menus.legacy.LegacyMenuState());
                }
                else
                    MusicBeatState.switchState(new MainMenuState());
            }
            
            if (FlxG.mouse.justMoved)
                for (i in 0...cutsceneButtons.length)
                {
                    if (FlxG.mouse.overlaps(cutsceneButtons.members[i]) || (FlxG.mouse.overlaps(cutsceneButtons.members[curSelected]) && cutsceneButtons.members[curSelected].alpha == 0.45))
                        changeSelection(i);
                    else if (!FlxG.mouse.overlaps(cutsceneButtons.members[i]))
                    {
                        cutsceneButtons.members[i].setColorTransform(1, 1, 1, 1, 0, 0, 0, 0);
                        cutsceneButtons.members[i].alpha = 0.45;
                    }
                }
            if (FlxG.mouse.overlaps(cutsceneButtons.members[curSelected]) && FlxG.mouse.justPressed)
                playVideo(cutsceneOptions[curSelected]);
        }

        if (!canUseControls) //For when you are playing a video
        {
            if (controls.BACK)
            {
                vidToPlay.pause();
                vidToPlay.visible = false;
                canUseControls = true;
                remove(pauseIcon);
                FlxG.sound.play(Paths.sound('cancelMenu'));
                FlxG.sound.music.fadeIn(0.5, 0, 0.8);
                FlxG.camera.fade(FlxColor.BLACK, 0.5, true);
            }
            
            if (FlxG.keys.justPressed.SPACE)
            {
                pauseIcon.visible = !pauseIcon.visible;
                if (pauseIcon.visible)
                    vidToPlay.pause();
                else
                    vidToPlay.resume();
            }
        }

        super.update(elapsed);
    }

    function changeSelection(selection:Int)
	{
		if (selection != curSelected)
			FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'));

		if (selection < 0)
			selection = cutsceneButtons.length - 1;
		if (selection >= cutsceneButtons.length)
			selection = 0;
		curSelected = selection;

		for (i in 0...cutsceneOptions.length)
		{   
            var menuItem:FlxSprite = cutsceneButtons.members[i];
			if (i == selection)
			{
				menuItem.setColorTransform(2, 2, 2, 1, 0, 0, 0, 0);
				menuItem.alpha = 1.0;
			}
			else
			{
				menuItem.setColorTransform(1, 1, 1, 1, 0, 0, 0, 0);
				menuItem.alpha = 0.45;
			}
		}
		curSelected = selection;
	}

    function playVideo(vidName:String)
    {
        FlxG.camera.fade(FlxColor.BLACK, 0.5, false);
        FlxG.sound.music.fadeOut(0.5, 0, function(twn:FlxTween)
        {
            canUseControls = false;
            
            vidToPlay = makeVideo(vidToPlay, vidName);
            add(vidToPlay);

            vidToPlay.setVideoTime(0);
            vidToPlay.restart();
            
            vidToPlay.play();
            vidToPlay.visible = true;

            pauseIcon.visible = false;
            add(pauseIcon);
        });
    }

    // Stealing this from Episode1Street.hx
	private function makeVideo(videoObject:VideoSprite, name:String):VideoSprite {
		videoObject = cast Paths.getCachedVideo(name);
		if (videoObject == null) {
			videoObject = new VideoSprite(false);
			videoObject.visible = false;
			videoObject.load(Paths.video(name));
            videoObject.cameras = [camVideo];
			videoObject.addCallback("onEnd", () -> {
				videoObject.visible = false;
                canUseControls = true;
                remove(pauseIcon);
                FlxG.sound.music.fadeIn(0.5, 0, 0.8);
                FlxG.camera.fade(FlxColor.BLACK, 0.5, true);
			});
			Paths.cacheVideo(name, videoObject);
		} 
        else 
        {
			videoObject.visible = false;
		}
        videoObject.setVideoTime(0);
		trace("Video Created, calling " + name);
		return videoObject;
	}
}