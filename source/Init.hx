import flixel.input.keyboard.FlxKey;
import flixel.system.FlxAssets;
import flixel.FlxState;

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

        if (FlxG.save.data.weekCompleted != null) StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;

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

        hxvlc.util.Handle.init(['--no-lua']);

        FlxG.sound.soundTray.silent = true; // removes that annoying ass "BEEP" sound when you change the volume

        #if DISCORD_ALLOWED
        DiscordClient.initialize();

        lime.app.Application.current.onExit.add(exitCode -> {
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
            FlxG.signals.gameResized.add((w, h) -> {
                if (FlxG.cameras != null) for (cam in FlxG.cameras.list)
                    if (cam != null && cam.filters != null)
                    {
                        cam.flashSprite.__cacheBitmap = null;
                        cam.flashSprite.__cacheBitmapData = null;
                    }
    
                if (FlxG.game != null) 
                {
                    FlxG.game.__cacheBitmap = null;
                    FlxG.game.__cacheBitmapData = null;
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

        trace('Initialization complete, switching to ${Type.getClassName(Main.game.initialState)}');
        FlxG.switchState(Type.createInstance(Main.game.initialState, []));   
    }
}