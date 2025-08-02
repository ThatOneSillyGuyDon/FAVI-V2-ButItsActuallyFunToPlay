import flixel.input.keyboard.FlxKey;
import flixel.system.FlxAssets;
import flixel.FlxState;
import openfl.Lib;

/**
	This is the initialization class. if you ever want to set anything before the game starts or call anything then this is probably your best bet.
**/
class Init extends FlxState
{
    public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

    public override function create() {
        trace('Initializating...');

		super.create();
		
		ClientPrefs.loadDefaultKeys();
		FlxG.save.bind('funkin', CoolUtil.getSavePath());

        PlayerSettings.init();
		ClientPrefs.loadPrefs();
		Highscore.load();
		GameData.loadShit();

		AppIcon.changeIcon("newIcon");
		
		CoolUtil.createCoreFile();

        if (FlxG.save.data.weekCompleted != null) StoryMenu.weekCompleted = FlxG.save.data.weekCompleted;

        #if cpp
		// run the gc's for a little bit of perfomance improvements :]]
		cpp.NativeGc.enable(true);
		cpp.NativeGc.run(true);
		#end

        FlxG.sound.muteKeys = muteKeys;
		FlxG.sound.volumeDownKeys = volumeDownKeys;
		FlxG.sound.volumeUpKeys = volumeUpKeys;

        FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = 60;
		FlxG.keys.preventDefaultKeys = [TAB];

        FlxG.sound.soundTray.silent = true; // removes that annoying ass "BEEP" sound when you change the volume

        #if DISCORD_ALLOWED
        DiscordClient.initialize();

        
        Lib.application.window.onClose.add(function() {
            DiscordClient.shutdown();
        });
		#end

        FlxG.mouse.visible = true;
        FlxG.mouse.useSystemCursor = false;

        #if windows
        backend.windows.CppAPI.darkMode();
        #end

        // fixes shaders acting weird when resizing the screen
        @:privateAccess
        {
            final resetSpriteCache = function(sprite:openfl.display.Sprite) {
                @:privateAccess {
                    sprite.__cacheBitmap = null;
                    sprite.__cacheBitmapData = null;
                }
            }

            FlxG.signals.gameResized.add((w, h) -> {
                if (FlxG.cameras != null) for (cam in FlxG.cameras.list)
                    if (cam != null && cam.filters != null)
                    {
                        resetSpriteCache(cam.flashSprite);
                    }
    
                if (FlxG.game != null) 
                {
                    resetSpriteCache(FlxG.game);
                }
           });
        }

        #if linux
		var icon = Image.fromFile("icon.png");
		Lib.current.stage.window.setIcon(icon);
		#end
        
        FlxG.autoPause = ClientPrefs.autoPause;
        FlxG.mouse.load(Paths.image('UI/funkinAVI/mouses/Hand').bitmap);
		FlxG.mouse.visible = true;

        // initializating ends here and switches to the state the Main class intends to
        #if Freeplay
        FlxG.switchState(Type.createInstance(FreeplayCategories, [])); 
        #end

        var curState = Main.initialState;

        if (!GameData.hasSeenWarning)
            curState = FlashingState;

        trace('Initialization complete, switching to ${Type.getClassName(curState)}');
        FlxG.switchState(Type.createInstance(curState, []));   
    }
}
