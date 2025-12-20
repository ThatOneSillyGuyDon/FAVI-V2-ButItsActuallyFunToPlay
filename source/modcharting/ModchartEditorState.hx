package modcharting;


import lime.utils.Assets;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.util.FlxAxes;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import haxe.Json;
import openfl.net.FileReference;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import flixel.graphics.FlxGraphic;
import flixel.addons.display.FlxBackdrop;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import openfl.geom.Rectangle;
import openfl.display.BitmapData;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.FlxSprite;
import flixel.util.FlxSort;
#if (flixel < "5.3.0")
import flixel.system.FlxSound;
#else
import flixel.sound.FlxSound;
#end
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.util.FlxDestroyUtil;
import flixel.addons.transition.FlxTransitionableState;

import lime.app.Application;

import flixel.util.FlxStringUtil;

import flixel.util.FlxSave;

import backend.song.Section.SwagSection;
import gameObjects.ui.notes.Note;
import gameObjects.ui.notes.StrumNote;
import backend.song.Song;

import modcharting.*;
import modcharting.Modifier;
import modcharting.ModchartFile;
import modcharting.ModchartFile.ModchartJson;

import backend.data.StageData;
import haxe.Exception;

using StringTools;

class ModchartEditorEvent extends FlxSprite
{
    public var data:Array<Dynamic>;
    public function new (data:Array<Dynamic>)
    {
        this.data = data;
        super(-300, 0);
        
        loadGraphic(Paths.image('editors/eventArrowModchart'));
        
        setGraphicSize(ModchartEditorState.gridSize, ModchartEditorState.gridSize);
        updateHitbox();
        antialiasing = true;
    }

    public function getBeatTime():Float 
    { 
        return data[ModchartFile.EVENT_DATA][ModchartFile.EVENT_TIME]; 
    }
}

class ModchartEditorState extends MusicBeatState implements PsychUIEventHandler.PsychUIEvent
{
    var hasUnsavedChanges:Bool = false;
    override function closeSubState() 
    {
		persistentUpdate = true;
		super.closeSubState();
	}
    
    //pain
    //tried using a macro but idk how to use them lol
    public static var modifierList:Array<Class<Modifier>> = [
        //Basic Modifiers with no curpos math
        XModifier, YModifier, YDModifier, ZModifier, 
        ConfusionModifier, MiniModifier,
        ScaleModifier, ScaleXModifier, ScaleYModifier, 
        SkewModifier, SkewXModifier, SkewYModifier,
        //Modifiers with curpos math!!!
        //Drunk Modifiers
        DrunkXModifier, DrunkYModifier, DrunkZModifier, DrunkAngleModifier,
        TanDrunkXModifier, TanDrunkYModifier, TanDrunkZModifier, TanDrunkAngleModifier,
        CosecantXModifier, CosecantYModifier, CosecantZModifier,
        //Tipsy Modifiers
        TipsyXModifier, TipsyYModifier, TipsyZModifier,
        //Wave Modifiers
        WaveXModifier, WaveYModifier, WaveZModifier, WaveAngleModifier,
        TanWaveXModifier, TanWaveYModifier, TanWaveZModifier, TanWaveAngleModifier,
        //Scroll Modifiers
        ReverseModifier, CrossModifier, SplitModifier, AlternateModifier,
        SpeedModifier, BoostModifier, BrakeModifier, BoomerangModifier, WaveingModifier,
        TwirlModifier, RollModifier,
        //Stealth Modifiers
        StealthModifier, NoteStealthModifier, LaneStealthModifier,
        SuddenModifier, HiddenModifier, VanishModifier, BlinkModifier,
        //Path Modifiers
        IncomingAngleModifier, InvertSineModifier, DizzyModifier, TordnadoModifier,
        EaseCurveModifier, EaseCurveXModifier, EaseCurveYModifier, EaseCurveZModifier, EaseCurveAngleModifier,
        BounceXModifier, BounceYModifier, BounceZModifier, BumpyModifier, BeatXModifier, BeatYModifier, BeatZModifier, 
        ShrinkModifier,
        //Target Modifiers
        RotateModifier, StrumLineRotateModifier, JumpTargetModifier,
        LanesModifier,
        //Notes Modifiers
        TimeStopModifier, JumpNotesModifier,
        NotesModifier,
        //Misc Modifiers
        StrumsModifier, InvertModifier, FlipModifier, JumpModifier,
        StrumAngleModifier, EaseXModifier, EaseYModifier, EaseZModifier,
        ShakyNotesModifier,
        ArrowPath
    ];
    
    public static var easeList:Array<String> = [
        "backIn",
        "backInOut",
        "backOut",
        "bounceIn",
        "bounceInOut",
        "bounceOut",
        "circIn",
        "circInOut",
        "circOut",
        "cubeIn",
        "cubeInOut",
        "cubeOut",
        "elasticIn",
        "elasticInOut",
        "elasticOut",
        "expoIn",
        "expoInOut",
        "expoOut",
        "linear",
        "quadIn",
        "quadInOut",
        "quadOut",
        "quartIn",
        "quartInOut",
        "quartOut",
        "quintIn",
        "quintInOut",
        "quintOut",
        "sineIn",
        "sineInOut",
        "sineOut",
        "smoothStepIn",
        "smoothStepInOut",
        "smoothStepOut",
        "smootherStepIn",
        "smootherStepInOut",
        "smootherStepOut",
    ];
    
    //used for indexing
    public static var MOD_NAME = ModchartFile.MOD_NAME; //the modifier name
    public static var MOD_CLASS = ModchartFile.MOD_CLASS; //the class/custom mod it uses
    public static var MOD_TYPE = ModchartFile.MOD_TYPE; //the type, which changes if its for the player, opponent, a specific lane or all
    public static var MOD_PF = ModchartFile.MOD_PF; //the playfield that mod uses
    public static var MOD_LANE = ModchartFile.MOD_LANE; //the lane the mod uses

    public static var EVENT_TYPE = ModchartFile.EVENT_TYPE; //event type (set or ease)
    public static var EVENT_DATA = ModchartFile.EVENT_DATA; //event data
    public static var EVENT_REPEAT = ModchartFile.EVENT_REPEAT; //event repeat data

    public static var EVENT_TIME = ModchartFile.EVENT_TIME; //event time (in beats)
    public static var EVENT_SETDATA = ModchartFile.EVENT_SETDATA; //event data (for sets)
    public static var EVENT_EASETIME = ModchartFile.EVENT_EASETIME; //event ease time
    public static var EVENT_EASE = ModchartFile.EVENT_EASE; //event ease
    public static var EVENT_EASEDATA = ModchartFile.EVENT_EASEDATA; //event data (for eases)

    public static var EVENT_REPEATBOOL = ModchartFile.EVENT_REPEATBOOL; //if event should repeat
    public static var EVENT_REPEATCOUNT = ModchartFile.EVENT_REPEATCOUNT; //how many times it repeats
    public static var EVENT_REPEATBEATGAP = ModchartFile.EVENT_REPEATBEATGAP; //how many beats in between each repeat

    public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
    public var notes:FlxTypedGroup<Note>;
    private var strumLine:FlxSprite;
    public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var unspawnNotes:Array<Note> = [];
    public var loadedNotes:Array<Note> = []; //stored notes from the chart that unspawnNotes can copy from
    public var vocals:FlxSound;
    public var opponentVocals:FlxSound;
    var generatedMusic:Bool = false;

    var bg:FlxSprite;
    
    var modchartEditorSave:FlxSave;

    var fileDialog:FileDialogHandler = new FileDialogHandler();

    var _song:SwagSong;
    var _modchart:ModchartJson;

    var playfieldInstance:MusicBeatState;

    private var grid:FlxBackdrop;
    private var line:FlxSprite;
    var beatTexts:Array<FlxText> = [];
    public var eventSprites:FlxTypedGroup<ModchartEditorEvent>;
    public static var gridSize:Int = 64;
    public var highlight:FlxSprite;
    public var debugText:FlxText;
    var highlightedEvent:Array<Dynamic> = null;
    var stackedHighlightedEvents:Array<Array<Dynamic>> = [];

    var UI_box:PsychUIBox;

    var textBlockers:Array<PsychUIInputText> = [];
    var scrollBlockers:Array<PsychUIDropDownMenu> = [];

    var playbackSpeed:Float = 1;

    var activeModifiersText:FlxText;
    var selectedEventBox:FlxSprite;

    var inst:FlxSound;

    public var opponentMode:Bool = false;

    var backupGpu:Bool;

    var autoSaveIcon:FlxSprite;

    override public function new()
    {
        super();
    }
    override public function create()
    {	
        backupGpu = ClientPrefs.data.cacheOnGPU;
        ClientPrefs.data.cacheOnGPU = false;
        
        Paths.clearStoredMemory();
        Paths.clearUnusedMemory();

        camGame = new FlxCamera();
        camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

        FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);

        FlxG.cameras.setDefaultDrawTarget(camGame, true);

        persistentUpdate = true;
		persistentDraw = true;

        modchartEditorSave = new FlxSave();
		modchartEditorSave.bind('modchart_editor_data', CoolUtil.getSavePath());

        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('Funkin_avi/editor/chart/chartEditorBG'));
		bg.scrollFactor.set();
		bg.color = 0xFF222222;
		add(bg);

        if (PlayState.SONG != null)
			_song = PlayState.SONG;
		else
		{
			Difficulty.resetList();
			_song = Song.loadFromJson('isolated', 'isolated');
			PlayState.SONG = _song;
		}

        if (PlayState.isPixelStage) //Skew Kills Pixel Notes (How are you going to stretch already pixelated bit by bit notes?)
        {
            modifierList.remove(SkewModifier);
            modifierList.remove(SkewXModifier);
            modifierList.remove(SkewYModifier);
        }

        if(modchartEditorSave.data.autoSave != null) autoSaveCap = modchartEditorSave.data.autoSave;
		if(modchartEditorSave.data.backupLimit != null) backupLimit = modchartEditorSave.data.backupLimit;
		
		Conductor.mapBPMChanges(PlayState.SONG);
        
        Conductor.bpm = PlayState.SONG.bpm;

        switch (_song.song)
        {
            case "Joygrim" | "Dentophobia" | "Neglection" | "Scrapped": DiscordClient.changePresence("Modchart Editor", "Modcharting a song", "icon");
            default: DiscordClient.changePresence("Modchart Editor", StringTools.replace(_song.song, '-', ' '), "icon");
        }

        AppIcon.changeIcon("debugicon");

        Application.current.window.title = "Funkin.avi - Modchart Editor - Editing for: " + _song.song;

        if(FlxG.sound.music != null)
            FlxG.sound.music.stop();

        FlxG.mouse.load(Paths.image('favi/ui/Cursor').bitmap);
        FlxG.mouse.visible = true;

        strumLine = new FlxSprite(ClientPrefs.data.middleScroll ? PlayState.STRUM_X_MIDDLESCROLL : PlayState.STRUM_X, 50).makeGraphic(FlxG.width, 10);
        if(ModchartUtil.getDownscroll(this)) strumLine.y = FlxG.height - 150;
		
		strumLine.scrollFactor.set();

        strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);

		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();
        
        generateSong(PlayState.SONG);
        
		playfieldRenderer = new PlayfieldRenderer(strumLineNotes, notes, this);
		playfieldRenderer.cameras = [camHUD];
        playfieldRenderer.inEditor = true;
		add(playfieldRenderer);

        playfieldInstance = PlayState.instance;
        if (playfieldRenderer.modchart.data != null)
            _modchart = playfieldRenderer.modchart.data;
        else if (playfieldInstance.playfieldRenderer.modchart.data != null)
            _modchart = playfieldInstance.playfieldRenderer.modchart.data;
        else {
            _modchart = {
                modifiers: [],
                playfields: 1,
                events: []
            };
        }

        grid = new FlxBackdrop(FlxGraphic.fromBitmapData(createGrid(gridSize, gridSize, FlxG.width, gridSize)), FlxAxes.X, 0, 0);
        add(grid);
        
        for (i in 0...12)
        {
            var beatText = new FlxText(-50, gridSize, 0, i+"", 32);
            beatText.setFormat(Paths.font("resultsFont.ttf"), 32, FlxColor.WHITE);
            add(beatText);
            beatTexts.push(beatText);
        }

        eventSprites = new FlxTypedGroup<ModchartEditorEvent>();
        add(eventSprites);

        highlight = new FlxSprite().makeGraphic(gridSize,gridSize);
        highlight.alpha = 0.5;
        add(highlight);

        selectedEventBox = new FlxSprite().makeGraphic(32,32);
        selectedEventBox.y = gridSize*0.5;
        selectedEventBox.visible = false;
        add(selectedEventBox);

        updateEventSprites();

        line = new FlxSprite().makeGraphic(10, gridSize);
        line.color = FlxColor.BLACK;
        add(line);

        generateStaticArrows(0);
        generateStaticArrows(1);
        NoteMovement.getDefaultStrumPosEditor(this);

        UI_box = new PsychUIBox(100, gridSize*2 + 50, FlxG.width-200, 450, ['Editor', 'Events', 'Modifiers', 'Playfields']);
        UI_box.canMove = false;
		UI_box.scrollFactor.set();
        add(UI_box);

        debugText = new FlxText(0, gridSize*2, 0, "", 16);
        debugText.setFormat(Paths.font("resultsFont.ttf"), 16, FlxColor.WHITE);
        debugText.alignment = FlxTextAlign.LEFT;
        add(debugText);

        autoSaveIcon = new FlxSprite(50).loadGraphic(Paths.image('editors/autosave'));
		autoSaveIcon.screenCenter(Y);
		autoSaveIcon.scale.set(0.6, 0.6);
		autoSaveIcon.antialiasing = ClientPrefs.data.antialiasing;
		autoSaveIcon.scrollFactor.set();
		autoSaveIcon.alpha = 0;
		add(autoSaveIcon);

        outputTxt = new FlxText(25, FlxG.height - 50, FlxG.width - 50, '', 20);
		outputTxt.borderSize = 2;
		outputTxt.borderStyle = OUTLINE_FAST;
		outputTxt.scrollFactor.set();
		outputTxt.alpha = 0;
		add(outputTxt);

        UI_box.selectedName = 'Editor';

        super.create(); //do here because tooltips be dumb
        //_ui.load(null);
        setupEditorUI();
        setupModifierUI();
        setupEventUI();
        setupPlayfieldUI();
    }

    var outputTxt:FlxText;
    var outputAlpha:Float = 0;
    function showOutput(message:String, isError:Bool = false, ?playSound:Bool = true)
	{
		trace(message);
		outputTxt.text = message;
		outputTxt.y = FlxG.height - outputTxt.height - 30;
		outputAlpha = 4;
		if(isError)
		{
			if (playSound) FlxG.sound.play(Paths.sound('cancelMenu'), 0.6);
			outputTxt.color = FlxColor.RED;
		}
		else
		{
			if (playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
			outputTxt.color = FlxColor.WHITE;
		}
	}

    override public function destroy() {
        ClientPrefs.data.cacheOnGPU = backupGpu;
        super.destroy();
    }

    var dirtyUpdateNotes:Bool = false;
    var dirtyUpdateEvents:Bool = false;
    var dirtyUpdateModifiers:Bool = false;
    var totalElapsed:Float = 0;

    final BACKUP_EXT = '.fnfm';
    var autoSaveTime:Float = 0;
	var autoSaveCap:Int = 2; //in minutes
	var backupLimit:Int = 10;
    override public function update(elapsed:Float)
    {
        if(!fileDialog.completed)
		{
			return;
		}

        outputAlpha = Math.max(0, outputAlpha - elapsed);
        
        totalElapsed += elapsed;
        highlight.alpha = 0.8+FlxMath.fastSin(totalElapsed*5)*0.15;
        super.update(elapsed);
        if(inst.time < 0) {
			inst.pause();
			inst.time = 0;
		}
		else if(inst.time > inst.length) {
			inst.pause();
			inst.time = 0;
		}
        Conductor.songPosition = inst.time;

        var songPosPixelPos = (((Conductor.songPosition/Conductor.stepCrochet)%4)*gridSize);
        grid.x = -curDecStep*gridSize;
        line.x = gridSize*4;

        for (i in 0...beatTexts.length)
        {
            beatTexts[i].x = -songPosPixelPos + (gridSize*4*(i+1)) - 16;
            beatTexts[i].text = ""+ (Math.floor(Conductor.songPosition/Conductor.crochet)+i);
        }
        var eventIsSelected:Bool = false;
        for (i in 0...eventSprites.members.length)
        {
            var pos = grid.x + (eventSprites.members[i].getBeatTime()*gridSize*4)+(gridSize*4);
            //var dec = eventSprites.members[i].beatTime-Math.floor(eventSprites.members[i].beatTime);
            eventSprites.members[i].x = pos; //+ (dec*4*gridSize);
            if (highlightedEvent != null)
                if (eventSprites.members[i].data == highlightedEvent)
                {
                    eventIsSelected = true;
                    selectedEventBox.x = pos;
                }
                    
        }
        selectedEventBox.visible = eventIsSelected;

        if(autoSaveCap > 0)
		{
			autoSaveTime += elapsed / 60.0;
			//trace(autoSaveTime);
			//#if debug if(FlxG.keys.justPressed.J) autoSaveTime += 20/60.0; #end
			if(autoSaveTime >= autoSaveCap #if debug || FlxG.keys.justPressed.NUMPADMULTIPLY #end)
			{
				FlxTween.cancelTweensOf(autoSaveIcon);
				autoSaveTime = 0;
				autoSaveIcon.alpha = 0;
				var chartName:String = '${PlayState.SONG.song}';

                chartName += DateTools.format(Date.now(), '_%Y-%m-%d_%H-%M-%S');

				var songCopy:ModchartJson; 
                if (playfieldInstance != null)
                    songCopy = Reflect.copy(playfieldInstance.playfieldRenderer.modchart.data);
                else
                    songCopy = Reflect.copy(playfieldRenderer.modchart.data);
				var dataToSave:String = haxe.Json.stringify(songCopy);
				if(!FileSystem.isDirectory('backups/modcharts/${_song.song}')) FileSystem.createDirectory('backups/modcharts/${_song.song}');
				File.saveContent('backups/modcharts/${_song.song}/$chartName.$BACKUP_EXT', dataToSave);

				if(backupLimit > 0)
				{
					var files:Array<String> = FileSystem.readDirectory('backups/modcharts/${_song.song}/').filter((file:String) -> file.endsWith('.$BACKUP_EXT'));
					if(files.length > backupLimit)
					{
						var incorrect:Array<String> = [];
						var map:Map<String, Float> = [];
						for(file in files)
						{
							var split:Array<String> = file.split('_');
							if(split.length > 2) //is properly formatted
							{
								try
								{
									var timeStr:String = split[split.length-1].replace('-', ':');
									timeStr = timeStr.substr(0, timeStr.indexOf('.'));

									var fileJoin:String = split[split.length-2] + ' ' + timeStr;
									var date:Date = Date.fromString(fileJoin);
									//trace(fileJoin, date.getTime());
									map.set(file, date.getTime());
								}
								catch(e:Exception)
								{
									incorrect.push(file);
								}
							}
							else incorrect.push(file);
						}

						if(incorrect.length > 0) files = files.filter((file:String) -> !incorrect.contains(file));
						files.sort(function(a:String, b:String) return map.get(a) > map.get(b) ? 1 : -1);

						while(files.length > backupLimit)
						{
							var file = files.shift();
							//trace('removed $file');
							try
							{
								FileSystem.deleteFile('backups/modcharts/${_song.song}/$file');
							}
							catch(e:Exception) {}
						}
					}
				}

				FlxTween.tween(autoSaveIcon, {alpha: 1}, 0.5, {onComplete: function(_)
					FlxTween.tween(autoSaveIcon, {alpha: 0}, 0.5, {startDelay: 2})
				});
			}
		}

        ClientPrefs.toggleVolumeKeys(PsychUIInputText.focusOn == null);

        if(PsychUIInputText.focusOn == null) //If not typing anything
        {
            if (FlxG.keys.justPressed.SPACE)
            {
                if (inst.playing)
                {
                    inst.pause();
                    if(vocals != null) vocals.pause();
                    if(opponentVocals != null) opponentVocals.pause();

                    playfieldRenderer.editorPaused = true;
                }
                else
                {
                    if(vocals != null) {
                        vocals.play();
                        vocals.pause();
                        vocals.time = inst.time;
                        vocals.play();
                    }
                    if (opponentVocals != null)
                    {
                        opponentVocals.play();
                        opponentVocals.pause();
                        opponentVocals.time = inst.time;
                        opponentVocals.play();
                    }
                    inst.play();
                    playfieldRenderer.editorPaused = false;
                    dirtyUpdateNotes = true;
                    dirtyUpdateEvents = true;
                }
            }
            var shiftThing:Int = 1;
            if (FlxG.keys.pressed.SHIFT)
                shiftThing = 4;
            if (FlxG.mouse.wheel != 0)
            {
                inst.pause();
                if(vocals != null) vocals.pause();
                if(opponentVocals != null) opponentVocals.pause();
                inst.time += (FlxG.mouse.wheel * Conductor.stepCrochet*0.8*shiftThing);
                if(vocals != null) {
                    vocals.pause();
                    vocals.time = inst.time;
                }
                if (opponentVocals != null)
                {
                    opponentVocals.pause();
                    opponentVocals.time = inst.time;
                }
                playfieldRenderer.editorPaused = true;
                dirtyUpdateNotes = true;
                dirtyUpdateEvents = true;
            }

            // OTHER CONTROLS
		    if(FlxG.keys.justPressed.F2)
            {
			    playfieldRenderer.visible = !playfieldRenderer.visible;
            }
    
            if (FlxG.keys.justPressed.D || FlxG.keys.justPressed.RIGHT)
            {
                inst.pause();
                if(vocals != null) vocals.pause();
                if(opponentVocals != null) opponentVocals.pause();
                inst.time += (Conductor.crochet*4*shiftThing);
                dirtyUpdateNotes = true;
                dirtyUpdateEvents = true;
            }
            if (FlxG.keys.justPressed.A || FlxG.keys.justPressed.LEFT) 
            {
                inst.pause();
                if(vocals != null) vocals.pause();
                if(opponentVocals != null) opponentVocals.pause();
                inst.time -= (Conductor.crochet*4*shiftThing);
                dirtyUpdateNotes = true;
                dirtyUpdateEvents = true;
            }

            var curSpeed = playbackSpeed;
    
            if (curSpeed != playbackSpeed)
                dirtyUpdateEvents = true;
        }
            
        if (playbackSpeed <= 0.5)
            playbackSpeed = 0.5;
        if (playbackSpeed >= 3)
            playbackSpeed = 3;

        songSlider.value = inst.time;

        playfieldRenderer.speed = playbackSpeed; //adjust the speed of tweens
        #if FLX_PITCH
        inst.pitch = playbackSpeed;
        vocals.pitch = playbackSpeed;
        if (opponentVocals != null) opponentVocals.pitch = playbackSpeed;
        #end
        

        if (unspawnNotes[0] != null)
        {
            var time:Float = 2000;
            if(PlayState.SONG.speed < 1) time /= PlayState.SONG.speed;

            while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
            {
                var dunceNote:Note = unspawnNotes[0];
                notes.insert(0, dunceNote);
                dunceNote.spawned=true;
                var index:Int = unspawnNotes.indexOf(dunceNote);
                unspawnNotes.splice(index, 1);
            }
        }

        var noteKillOffset = 350 / PlayState.SONG.speed;

        notes.forEachAlive(function(daNote:Note) {
            var strumGroup:FlxTypedGroup<StrumNote> = playerStrums;
			if(!daNote.mustPress) strumGroup = opponentStrums;

            if (Conductor.songPosition >= daNote.strumTime)
            {
                daNote.wasGoodHit = true;
                
                var spr:StrumNote = null;
                if(!daNote.mustPress) {
                    spr = opponentStrums.members[daNote.noteData];
                } else {
                    spr = playerStrums.members[daNote.noteData];
                }
                spr.playAnim("confirm", true);
                spr.resetAnim = Conductor.stepCrochet * 1.25 / 1000 / playbackSpeed;
                
                if (!daNote.isSustainNote)
                {
                    //daNote.kill();
                    notes.remove(daNote, true);
                    //daNote.destroy();
                }
            }

            if (Conductor.songPosition > noteKillOffset + daNote.strumTime)
            {
                daNote.active = false;
                daNote.visible = false;

                //daNote.kill();
                notes.remove(daNote, true);
                //daNote.destroy();
            }
        });

        if (FlxG.mouse.y < grid.y+grid.height && FlxG.mouse.y > grid.y) //not using overlap because the grid would go out of world bounds
        {
            if (FlxG.keys.pressed.SHIFT)
                highlight.x = FlxG.mouse.x;
            else
                highlight.x = (Math.floor((FlxG.mouse.x-(grid.x%gridSize))/gridSize)*gridSize)+(grid.x%gridSize);
            if (FlxG.mouse.overlaps(eventSprites))
            {
                if (FlxG.mouse.justPressed)
                {
                    stackedHighlightedEvents = []; //reset stacked events
                }
                eventSprites.forEachAlive(function(event:ModchartEditorEvent)
                {
                    if (FlxG.mouse.overlaps(event))
                    {
                        if (FlxG.mouse.justPressed)
                        {
                            highlightedEvent = event.data;
                            stackedHighlightedEvents.push(event.data);
                            onSelectEvent();
                            //trace(stackedHighlightedEvents);
                        }   
                        if (FlxG.keys.justPressed.BACKSPACE)
                            deleteEvent();
                    }
                });
                if (FlxG.mouse.justPressed)
                {
                    updateStackedEventDataStepper();
                }
            }
            else 
            {
                if (FlxG.mouse.justPressed)
                {
                    var timeFromMouse = ((highlight.x-grid.x)/gridSize/4)-1;
                    //trace(timeFromMouse);
                    var event = addNewEvent(timeFromMouse);
                    highlightedEvent = event;
                    onSelectEvent();
                    updateEventSprites();
                    dirtyUpdateEvents = true;
                }
            }
        }

        if (dirtyUpdateNotes)
        {
            clearNotesAfter(Conductor.songPosition+2000); //so scrolling back doesnt lag shit
            unspawnNotes = loadedNotes.copy();
            clearNotesBefore(Conductor.songPosition);
            dirtyUpdateNotes = false;
        }
        if (dirtyUpdateModifiers)
        {
            playfieldRenderer.modifierTable.clear();
            playfieldRenderer.modchart.loadModifiers();
            dirtyUpdateEvents = true;
            dirtyUpdateModifiers = false;
        }
        if (dirtyUpdateEvents)
        {
            playfieldRenderer.tweenManager.completeAll();
            playfieldRenderer.eventManager.clearEvents();
            playfieldRenderer.modifierTable.resetMods();
            playfieldRenderer.modchart.loadEvents();
            dirtyUpdateEvents = false;
            playfieldRenderer.update(0);
            updateEventSprites();
        }

        if (_modchart.playfields != playfieldCountStepper.value)
        {
            _modchart.playfields = Std.int(playfieldCountStepper.value);
            playfieldRenderer.modchart.loadPlayfields();
        }

        if(PsychUIInputText.focusOn == null) //If not typing anything
        {
            if (FlxG.keys.justPressed.ENTER)
            {
                ClientPrefs.toggleVolumeKeys(true);
                FlxG.mouse.visible = false;
                inst.stop();
                if(vocals != null) vocals.stop();
                if(opponentVocals != null) opponentVocals.stop();
                StageData.loadDirectory(PlayState.SONG);

                modchartEditorSave.flush();

                LoadingState.loadAndSwitchState(new PlayState());
            }

            if(FlxG.keys.justPressed.ESCAPE)
            {
                var exitFunc = function()
                {
                    ClientPrefs.toggleVolumeKeys(true);
                    
                    inst.stop();
                    if(vocals != null) vocals.stop();
                    if(opponentVocals != null) opponentVocals.stop();

                    modchartEditorSave.flush();

                    MusicBeatState.switchState(new states.editors.MasterEditorMenu());
                    FlxG.sound.playMusic(Paths.music('aviOST/rottenPetals'));
                    FlxG.mouse.visible = false;
                    ModchartFile.autosaveMod = null; //makes it so it won't interfere with anything else upon leaving the editor
                };
                persistentUpdate = false;
                openSubState(new gameObjects.ui.customEditorUI.Prompt('This action will clear all unsaved progress or data here.\n\nProceed?', 0, function(){exitFunc();}, null,false, camHUD));

            }
        }

        var curBpmChange = Conductor.getBPMFromSeconds(Conductor.songPosition);
        if (curBpmChange.songTime <= 0)
        {
            curBpmChange.bpm = PlayState.SONG.bpm; //start bpm
        }
        if (curBpmChange.bpm != Conductor.bpm)
        {
            //trace('changed bpm to ' + curBpmChange.bpm);
            Conductor.bpm = curBpmChange.bpm;
        }

        debugText.text = Std.string(FlxMath.roundDecimal(Conductor.songPosition / 1000, 2)) + " / " + Std.string(FlxMath.roundDecimal(inst.length / 1000, 2)) +
		"\nBeat: " + Std.string(curDecBeat).substring(0,4) +
		"\nStep: " + curStep + "\n";

        var leText = "Active Modifiers: \n";
        for (modName => mod in playfieldRenderer.modifierTable.modifiers)
        {
            if (mod.currentValue != mod.baseValue)
            {
                leText += modName + ": " + FlxMath.roundDecimal(mod.currentValue, 2);
                for (subModName => subMod in mod.subValues)
                {
                    leText += "    " + subModName + ": " + FlxMath.roundDecimal(subMod.value, 2);
                }
                leText += "\n";
            }
        }

        outputTxt.alpha = outputAlpha;
		outputTxt.visible = (outputAlpha > 0);

        activeModifiersText.text = leText;
    }

    function addNewEvent(time:Float)
    {
        var event:Array<Dynamic> = ['ease', [time, 1, 'cubeInOut', ','], [false, 1, 1]];
        if (highlightedEvent != null) //copy over current event data (without acting as a reference)
        {
            event[EVENT_TYPE] = highlightedEvent[EVENT_TYPE];
            if (event[EVENT_TYPE] == 'ease')
            {
                event[EVENT_DATA][EVENT_EASETIME] = highlightedEvent[EVENT_DATA][EVENT_EASETIME];
                event[EVENT_DATA][EVENT_EASE] = highlightedEvent[EVENT_DATA][EVENT_EASE];
                event[EVENT_DATA][EVENT_EASEDATA] = highlightedEvent[EVENT_DATA][EVENT_EASEDATA];
            }
            else 
            {
                event[EVENT_DATA][EVENT_SETDATA] = highlightedEvent[EVENT_TYPE][EVENT_SETDATA];
            }
            event[EVENT_REPEAT][EVENT_REPEATBOOL] = highlightedEvent[EVENT_REPEAT][EVENT_REPEATBOOL];
            event[EVENT_REPEAT][EVENT_REPEATCOUNT] = highlightedEvent[EVENT_REPEAT][EVENT_REPEATCOUNT];
            event[EVENT_REPEAT][EVENT_REPEATBEATGAP] = highlightedEvent[EVENT_REPEAT][EVENT_REPEATBEATGAP];
        
        }

        _modchart.events.push(event);
        hasUnsavedChanges = true;
        return event;
    }

    function updateEventSprites()
    {
        // var i = eventSprites.length - 1;
        // while (i >= 0) {
        //     var daEvent:ModchartEditorEvent = eventSprites.members[i];
        //     var beat:Float = _modchart.events[i][1][0];
        //     if(curBeat < beat-4 && curBeat > beat+16)
        //     {
        //         daEvent.active = false;
        //         daEvent.visible = false;
        //         daEvent.alpha = 0;
        //         eventSprites.remove(daEvent, true);
        //         trace(daEvent.getBeatTime());
        //         trace("removed event sprite "+ daEvent.getBeatTime());
        //     }
        //     --i;
        // }
        eventSprites.clear();
        for (i in 0..._modchart.events.length)
        {
            var beat:Float = _modchart.events[i][1][0];
            if (curBeat > beat-5  && curBeat < beat+5)
            {
                var daEvent:ModchartEditorEvent = new ModchartEditorEvent(_modchart.events[i]);
                eventSprites.add(daEvent);
                //trace("added event sprite "+beat);
            }
        }
    }

    function deleteEvent()
    {
        if (highlightedEvent == null)
            return;
        for (i in 0..._modchart.events.length)
        {
            if (highlightedEvent == _modchart.events[i])
            {
                _modchart.events.remove(_modchart.events[i]);
                dirtyUpdateEvents = true;
                break;
            }
        }

        updateEventSprites();
    }

    override public function beatHit()
    {
        updateEventSprites();
        //trace("beat hit");
        super.beatHit();
    }

    override public function draw()
    {

        super.draw();
    }

    public function clearNotesBefore(time:Float)
    {
        var i:Int = unspawnNotes.length - 1;
        while (i >= 0) {
            var daNote:Note = unspawnNotes[i];
            if(daNote.strumTime+350 < time)
            {
                daNote.active = false;
                daNote.visible = false;
                //daNote.ignoreNote = true;

                //daNote.kill();
                unspawnNotes.remove(daNote);
                //daNote.destroy();
            }
            --i;
        }

        i = notes.length - 1;
        while (i >= 0) {
            var daNote:Note = notes.members[i];
            if(daNote.strumTime+350 < time)
            {
                daNote.active = false;
                daNote.visible = false;
                //daNote.ignoreNote = true;

                //daNote.kill();
                notes.remove(daNote, true);
                //daNote.destroy();
            }
            --i;
        }
    }
    public function clearNotesAfter(time:Float)
    {
        var i = notes.length - 1;
        while (i >= 0) {
            var daNote:Note = notes.members[i];
            if(daNote.strumTime > time)
            {
                daNote.active = false;
                daNote.visible = false;
                //daNote.ignoreNote = true;

                //daNote.kill();
                notes.remove(daNote, true);
                //daNote.destroy();
            }
            --i;
        }
    }

    private var noteTypes:Array<String> = [];
    private var totalColumns: Int = 4;
    
    public function generateSong(songData:SwagSong):Void
    {
        var songData = PlayState.SONG;
        Conductor.bpm = songData.bpm;

        var boyfriendVocals:String = getVocalFromCharacter(PlayState.SONG.player1);
		var dadVocals:String = getVocalFromCharacter(PlayState.SONG.player2);

        vocals = new FlxSound();
        opponentVocals = new FlxSound();
        try {
            if (PlayState.SONG.needsVoices)
            {
                vocals.loadEmbedded(Paths.voices(PlayState.SONG.song));

                var normalVocals = Paths.voices(songData.song);
				var playerVocals = Paths.voices(songData.song, (boyfriendVocals == null || boyfriendVocals.length < 1) ? 'Player' : boyfriendVocals);
				vocals.loadEmbedded(playerVocals != null ? playerVocals : normalVocals);

                var oppVocals = Paths.voices(songData.song, (dadVocals == null || dadVocals.length < 1) ? 'Opponent' : dadVocals);
                if(oppVocals != null) opponentVocals.loadEmbedded(oppVocals);
            }
        }

        FlxG.sound.list.add(vocals);
        FlxG.sound.list.add(opponentVocals);

        inst = new FlxSound();
        try {
            inst.loadEmbedded(Paths.inst(PlayState.SONG.song));
		}
        FlxG.sound.list.add(inst);

        inst.onComplete = function()
        {
            inst.pause();
            Conductor.songPosition = 0;
            if(vocals != null) {
                vocals.pause();
                vocals.time = 0;
            }
            if(opponentVocals != null)
            {
                opponentVocals.pause();
                opponentVocals.time = 0;
            }
        };

        notes = new FlxTypedGroup<Note>();
        add(notes);

        var noteData:Array<SwagSection>;

        // NEW SHIT
        noteData = songData.notes;

        var playerCounter:Int = 0;

        var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

        //var songName:String = Paths.formatToSongPath(PlayState.SONG.song);

        for (section in noteData)
        {
            for (songNotes in section.sectionNotes)
            {
                var daStrumTime:Float = songNotes[0];
                
                var daNoteData:Int = Std.int(songNotes[1] % 4);
                var gottaHitNote:Bool = section.mustHitSection;
                if (songNotes[1] > 3 && !opponentMode)
                    gottaHitNote = !section.mustHitSection;
                else if (songNotes[1] <= 3 && opponentMode)
                    gottaHitNote = !section.mustHitSection;

                var oldNote:Note;
                if (unspawnNotes.length > 0)
                    oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
                else
                    oldNote = null;


                var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false);
                swagNote.sustainLength = songNotes[2];
                swagNote.mustPress = gottaHitNote;
                swagNote.gfNote = (section.gfSection && (songNotes[1]<4));
                swagNote.noteType = songNotes[3];
                if(!Std.isOfType(songNotes[3], String)) swagNote.noteType = states.editors.ChartingState.noteTypeList[songNotes[3]]; //Backward compatibility + compatibility with Week 7 charts
                
                swagNote.scrollFactor.set();
                unspawnNotes.push(swagNote);

                final susLength:Float = swagNote.sustainLength / Conductor.stepCrochet;
				final floorSus:Int = Math.floor(susLength);

				if(floorSus > 0) {
					for (susNote in 0...floorSus + 1)
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

                        var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote), daNoteData, oldNote, true);
                        sustainNote.mustPress = gottaHitNote;
                        
                        sustainNote.gfNote = (section.gfSection && (songNotes[1]<4));
                        sustainNote.noteType = swagNote.noteType;
                        swagNote.tail.push(sustainNote);
                        sustainNote.parent = swagNote;
                        
                        sustainNote.scrollFactor.set();
                        unspawnNotes.push(sustainNote);

                        if (sustainNote.mustPress) sustainNote.x += FlxG.width / 2; // general offset
                        else if(ClientPrefs.data.middleScroll)
                        {
                            sustainNote.x += 310;
                            if(daNoteData > 1) //Up and Right
                                sustainNote.x += FlxG.width / 2 + 25;
                        }
                    }
                }

                if (swagNote.mustPress)
                {
                    swagNote.x += FlxG.width / 2; // general offset
                }
                else if(ClientPrefs.data.middleScroll)
                {
                    swagNote.x += 310;
                    if(daNoteData > 1) //Up and Right
                        swagNote.x += FlxG.width / 2 + 25;
                }
            }

            daBeats += 1;
        }

        unspawnNotes.sort(sortByTime);
        loadedNotes = unspawnNotes.copy();
        generatedMusic = true;
    }
    function sortByTime(Obj1:Dynamic, Obj2:Dynamic):Int
    {
        return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
    }


    private function generateStaticArrows(player:Int):Void
    {
        var usedKeyCount = 4;

        var strumLineX:Float = ClientPrefs.data.middleScroll ? PlayState.STRUM_X_MIDDLESCROLL : PlayState.STRUM_X;

		var TRUE_STRUM_X:Float = strumLineX;

        if (PlayState.SONG.arrowSkin.contains('pixel'))
		{
            TRUE_STRUM_X += (ClientPrefs.data.middleScroll ? 3 : 2);
		}

        for (i in 0...usedKeyCount)
        {
            // FlxG.log.add(i);
            var targetAlpha:Float = 1;
            if (player < 1)
            {
                if(ClientPrefs.data.middleScroll) targetAlpha = 0.35;
            }

            var babyArrow:StrumNote = new StrumNote(TRUE_STRUM_X, strumLine.y, i, player, true);
            babyArrow.downScroll = ClientPrefs.data.downScroll;
            babyArrow.alpha = targetAlpha;
            
            var middleScroll:Bool = false;

            middleScroll = ClientPrefs.data.middleScroll;

            if (player == 1)
            {
                playerStrums.add(babyArrow);
            }
            else
            {
                if(middleScroll)
                {
                    babyArrow.x += 310;
                    if(i > 1) { //Up and Right
                        babyArrow.x += FlxG.width / 2 + 25;
                    }
                }
                opponentStrums.add(babyArrow);
            }

            strumLineNotes.add(babyArrow);
            babyArrow.postAddedToGroup();
        }
    }

    
    function getVocalFromCharacter(char:String)
	{
		try
		{
			var path:String = Paths.getPath('characters/$char.json' , TEXT, null, true);
            var character:Dynamic = Json.parse(Assets.getText(path));

			return character.vocals_file;
		}
		return null;
	}

    public static function createGrid(CellWidth:Int, CellHeight:Int, Width:Int, Height:Int):BitmapData
    {
        // How many cells can we fit into the width/height? (round it UP if not even, then trim back)
        var Color1 = FlxColor.fromRGB(16, 16, 16);
        var Color2 = FlxColor.fromRGB(32, 32, 32);
        //var Color3 = FlxColor.LIME;
        var rowColor:Int = Color1;
        var lastColor:Int = Color1;
        var grid:BitmapData = new BitmapData(Width, Height, true);

        // If there aren't an even number of cells in a row then we need to swap the lastColor value
        var y:Int = 0;
        var timesFilled:Int = 0;
        while (y <= Height)
        {

            var x:Int = 0;
            while (x <= Width)
            {
                if (timesFilled % 2 == 0)
                    lastColor = Color1;
                //else if (timesFilled % 4 == 2)
                    //lastColor = Color2;
                else 
                    lastColor = Color2;

                grid.fillRect(new Rectangle(x, y, CellWidth, CellHeight), lastColor);
                timesFilled++;

                x += CellWidth;
            }

            y += CellHeight;
        }

        return grid;
    }
    var currentModifier:Array<Dynamic> = null;
    var modNameInputText:PsychUIInputText;
    var modClassInputText:PsychUIInputText;
    var explainText:FlxText;
    var modTypeInputText:PsychUIInputText;
    var playfieldStepper:PsychUINumericStepper;
    var targetLaneStepper:PsychUINumericStepper;
    var modifierDropDown:PsychUIDropDownMenu;
    var mods:Array<String> = [];
    var subMods:Array<String> = [""];
    
    function updateModList()
    {
        mods = [];
        for (i in 0..._modchart.modifiers.length)
            mods.push(_modchart.modifiers[i][MOD_NAME]);
        if (mods.length == 0)
            mods.push('');

        modifierDropDown.list = mods;
        eventModifierDropDown.list = mods;

    }
    function updateSubModList(modName:String)
    {
        subMods = [""];
        if (playfieldRenderer.modifierTable.modifiers.exists(modName))
        {
            for (subModName => subMod in playfieldRenderer.modifierTable.modifiers.get(modName).subValues)
            {
                subMods.push(subModName);
            }
        }
        subModDropDown.list = subMods;
    }
    function setupModifierUI()
    {
        var tab_group = UI_box.getTab('Modifiers').menu;

        for (i in 0..._modchart.modifiers.length)
            mods.push(_modchart.modifiers[i][MOD_NAME]);

        if (mods.length == 0)
            mods.push('');

        modifierDropDown = new PsychUIDropDownMenu(25, 50, mods, function(id:Int, mod:String)
        {
            var modName = mods[id];
            for (i in 0..._modchart.modifiers.length)
                if (_modchart.modifiers[i][MOD_NAME] == modName)
                    currentModifier = _modchart.modifiers[i];

            if (currentModifier != null)
            {
                modNameInputText.text = currentModifier[MOD_NAME];
                modClassInputText.text = currentModifier[MOD_CLASS];
                modTypeInputText.text = currentModifier[MOD_TYPE];
                playfieldStepper.value = currentModifier[MOD_PF];
                if (currentModifier[MOD_LANE] != null)
                    targetLaneStepper.value = currentModifier[MOD_LANE];
            }   
        });

        var refreshModifiers:PsychUIButton = new PsychUIButton(25+modifierDropDown.width+10, modifierDropDown.y, 'Refresh Modifiers', function()
		{
			updateModList();
		});
        refreshModifiers.resize(80, 30);

        var saveModifier:PsychUIButton = new PsychUIButton(refreshModifiers.x, refreshModifiers.y+refreshModifiers.height+20, 'Save Modifier', function ()
        {
            var alreadyExists = false;
            for (i in 0..._modchart.modifiers.length)
                if (_modchart.modifiers[i][MOD_NAME] == modNameInputText.text)
                {
                    _modchart.modifiers[i] = [modNameInputText.text, modClassInputText.text,
                        modTypeInputText.text, playfieldStepper.value, targetLaneStepper.value];
                    alreadyExists = true;
                }

            if (!alreadyExists)
            {
                _modchart.modifiers.push([modNameInputText.text, modClassInputText.text, 
                    modTypeInputText.text, playfieldStepper.value, targetLaneStepper.value]);
            }
            dirtyUpdateModifiers = true;
            updateModList();
            hasUnsavedChanges = true;
        });

        var removeModifier:PsychUIButton = new PsychUIButton(saveModifier.x, saveModifier.y+saveModifier.height+20, 'Remove Modifier', function ()
        {
            for (i in 0..._modchart.modifiers.length)
                if (_modchart.modifiers[i][MOD_NAME] == modNameInputText.text)
                {
                    _modchart.modifiers.remove(_modchart.modifiers[i]);
                }
            dirtyUpdateModifiers = true;
            updateModList();
            hasUnsavedChanges = true;
        });
        removeModifier.resize(80, 30);

        modNameInputText = new PsychUIInputText(modifierDropDown.x + 300, modifierDropDown.y, 160, '', 8);
        modClassInputText = new PsychUIInputText(modifierDropDown.x + 500, modifierDropDown.y, 160, '', 8);
        explainText = new FlxText(modifierDropDown.x + 200, modifierDropDown.y + 200, 160, '', 8);
        modTypeInputText = new PsychUIInputText(modifierDropDown.x + 700, modifierDropDown.y, 160, '', 8);
        playfieldStepper = new PsychUINumericStepper(modifierDropDown.x + 900, modifierDropDown.y, 1, -1, -1, 100, 0);
        targetLaneStepper = new PsychUINumericStepper(modifierDropDown.x + 900, modifierDropDown.y+300, 1, -1, -1, 100, 0);

        textBlockers.push(modNameInputText);
        textBlockers.push(modClassInputText);
        textBlockers.push(modTypeInputText);
        scrollBlockers.push(modifierDropDown);


        var modClassList:Array<String> = [];
        for (i in 0...modifierList.length)
        {
            modClassList.push(Std.string(modifierList[i]).replace("modcharting.", ""));
        }
        
        var modClassDropDown = new PsychUIDropDownMenu(modClassInputText.x, modClassInputText.y+30, modClassList, function(id:Int, mod:String)
        {
            modClassInputText.text = modClassList[id];
            if (modClassInputText.text != '')
                explainText.text = ('Current Modifier: ${modClassInputText.text}, Explaination: ' + modifierExplain(modClassInputText.text));
        }, 140);
        centerXToObject(modClassInputText, modClassDropDown);
        var modTypeList = ["All", "Player", "Opponent", "Lane"];
        var modTypeDropDown = new PsychUIDropDownMenu(modTypeInputText.x, modClassInputText.y+30, modTypeList, function(id:Int, mod:String)
        {
            modTypeInputText.text = modTypeList[id];
        });
        centerXToObject(modTypeInputText, modTypeDropDown);
        centerXToObject(modTypeInputText, explainText);

        scrollBlockers.push(modTypeDropDown);
        scrollBlockers.push(modClassDropDown);

        activeModifiersText = new FlxText(50, 180);
        tab_group.add(activeModifiersText);
        
        for (txt in [activeModifiersText, explainText])
        {
            txt.setFormat(Paths.font("resultsFont.ttf"), 14, FlxColor.WHITE);
        }

        tab_group.add(modNameInputText);
        tab_group.add(modClassInputText);
        tab_group.add(explainText);
        tab_group.add(modTypeInputText);
        tab_group.add(playfieldStepper);
        tab_group.add(targetLaneStepper);

        tab_group.add(refreshModifiers);
        tab_group.add(saveModifier);
        tab_group.add(removeModifier);

        tab_group.add(makeLabel(modNameInputText, 0, -15, "Modifier Name"));
        tab_group.add(makeLabel(modClassInputText, 0, -15, "Modifier Class"));
        tab_group.add(makeLabel(explainText, 0, -15, "Modifier Explaination:"));
        tab_group.add(makeLabel(modTypeInputText, 0, -15, "Modifier Type"));
        tab_group.add(makeLabel(playfieldStepper, 0, -15, "Playfield (-1 = all)"));
        tab_group.add(makeLabel(targetLaneStepper, 0, -15, "Target Lane (only for Lane mods!)"));
        tab_group.add(makeLabel(playfieldStepper, 0, 15, "Playfield number starts at 0!"));

        tab_group.add(modifierDropDown);
        tab_group.add(modClassDropDown);
        tab_group.add(modTypeDropDown);
    }

    //Thanks to glowsoony for the idea lol
    function modifierExplain(modifiersName:String):String
    {
        var explainString:String = '';

        switch (modifiersName)
        {
            case 'DrunkXModifier':
		        explainString = "Modifier used to do a wave at X poss of the notes and targets";
            case 'DrunkYModifier':
		        explainString = "Modifier used to do a wave at Y poss of the notes and targets";
            case 'DrunkZModifier':
		        explainString = "Modifier used to do a wave at Z (Far, Close) poss of the notes and targets";
            case 'TipsyXModifier':
		        explainString = "Modifier similar to DrunkX but don't affect notes poss";
            case 'TipsyYModifier':
		        explainString = "Modifier similar to DrunkY but don't affect notes poss";
            case 'TipsyZModifier':
		        explainString = "Modifier similar to DrunkZ but don't affect notes poss";
            case 'ReverseModifier':
		        explainString = "Flip the scroll type (Upscroll/Downscroll)";
            case 'SplitModifier':
		        explainString = "Flip the scroll type (HalfUpscroll/HalfDownscroll)";
            case 'CrossModifier':
		        explainString = "Flip the scroll type (Upscroll/Downscroll/Downscroll/Upscroll)";
            case 'AlternateModifier':
		        explainString = "Flip the scroll type (Upscroll/Downscroll/Upscroll/Downscroll)";
            case 'IncomingAngleModifier':
		        explainString = "Modifier that changes how notes come to the target (if X and Y aplied it will use Z)";
            case 'RotateModifier': 
		        explainString = "Modifier used to rotate the lanes poss between a value aplied with rotatePoint (can be used with Y and X)";
            case 'StrumLineRotateModifier':
		        explainString = "Modifier similar to RotateModifier but this one doesn't need a extra value (can be used with Y, X and Z)";
            case 'BumpyModifier':
		        explainString = "Modifier used to make notes jump a bit in their own Perspective poss";
            case 'XModifier':
		        explainString = "Moves notes and targets X";
            case 'YModifier':
		        explainString = "Moves notes and targets Y";
            case 'YDModifier':
		        explainString = "Moves notes and targets Y (Automatically reverses in downscroll)";
            case 'ZModifier':
		        explainString = "Moves notes and targets Z (Far, Close)";
            case 'ConfusionModifier':
		        explainString = "Changes notes and targets angle";
            case 'DizzyModifier':
		        explainString = "Changes notes angle making a visual on them";
            case 'ScaleModifier':
		        explainString = "Modifier used to make notes and targets bigger or smaller";
            case 'ScaleXModifier':
		        explainString = "Modifier used to make notes and targets bigger or smaller (Only in X)";
            case 'ScaleYModifier':
		        explainString = "Modifier used to make notes and targets bigger or smaller (Only in Y)";
            case 'SpeedModifier':
		        explainString = "Modifier used to make notes be faster or slower";
            case 'StealthModifier':
		        explainString = "Modifier used to change notes and targets alpha";
            case 'NoteStealthModifier':
		        explainString = "Modifier used to change notes alpha";
            case 'LaneStealthModifier':
		        explainString = "Modifier used to change targets alpha";
            case 'InvertModifier':
		        explainString = "Modifier used to invert notes and targets X poss (down/left/right/up)";
            case 'FlipModifier':
		        explainString = "Modifier used to flip notes and targets X poss (right/up/down/left)";
            case 'MiniModifier':
		        explainString = "Modifier similar to ScaleModifier but this one does Z perspective";
            case 'ShrinkModifier':
		        explainString = "Modifier used to add a boost of the notes (the more value the less scale it will be at the start)";
            case 'BeatXModifier':
		        explainString = "Modifier used to move notes and targets X with a small jump effect";
            case 'BeatYModifier':
		        explainString = "Modifier used to move notes and targets Y with a small jump effect";
            case 'BeatZModifier':
		        explainString = "Modifier used to move notes and targets Z with a small jump effect";
            case 'BounceXModifier':
		        explainString = "Modifier similar to beatX but it only affect notes X with a jump effect";
            case 'BounceYModifier':
		        explainString = "Modifier similar to beatY but it only affect notes Y with a jump effect";
            case 'BounceZModifier':
		        explainString = "Modifier similar to beatZ but it only affect notes Z with a jump effect";
            case 'EaseCurveModifier':
		        explainString = "This enables the EaseModifiers";
            case 'EaseCurveXModifier':
		        explainString = "Modifier similar to IncomingAngleMod (X), it will make notes come faster at X poss";
            case 'EaseCurveYModifier':
		        explainString = "Modifier similar to IncomingAngleMod (Y), it will make notes come faster at Y poss";
            case 'EaseCurveZModifier':
		        explainString = "Modifier similar to IncomingAngleMod (X+Y), it will make notes come faster at Z perspective";
            case 'EaseCurveAngleModifier':
		        explainString = "Modifier similar to All easeCurve, it will make notes angle change, usually next to target";
            case 'InvertSineModifier':
		        explainString = "Modifier used to do a curve in the notes it will be different for notes (Down and Right / Left and Up)";
            case 'BoostModifier':
		        explainString = "Modifier used to make notes come faster to target";
            case 'BrakeModifier':
		        explainString = "Modifier used to make notes come slower to target";
            case 'BoomerangModifier':
		        explainString = "Modifier used to make notes come in reverse to target";
            case 'WaveingModifier':
		        explainString = "Modifier used to make notes come faster and slower to target";
            case 'JumpModifier':
		        explainString = "Modifier used to make notes and target jump";
            case 'WaveXModifier':
		        explainString = "Modifier similar to drunkX but this one will simulate a true wave in X (don't affect the notes)";
            case 'WaveYModifier':
		        explainString = "Modifier similar to drunkY but this one will simulate a true wave in Y (don't affect the notes)";
            case 'WaveZModifier':
		        explainString = "Modifier similar to drunkZ but this one will simulate a true wave in Z (don't affect the notes)";
            case 'TimeStopModifier':
		        explainString = "Modifier used to stop the notes at the top/bottom part of your screen to make it hard to read";
            case 'StrumAngleModifier':
		        explainString = "Modifier combined between strumRotate, Confusion, IncomingAngleY, making a rotation easily";
            case 'JumpTargetModifier':
		        explainString = "Modifier similar to jump but only target aplied";
            case 'JumpNotesModifier':
		        explainString = "Modifier similar to jump but only notes aplied";
            case 'EaseXModifier':
		        explainString = "Modifier used to make notes go left to right on the screen";
            case 'EaseYModifier':
		        explainString = "Modifier used to make notes go up to down on the screen";
            case 'EaseZModifier':
		        explainString = "Modifier used to make notes go far to near right on the screen";
            case 'HiddenModifier':
		        explainString = "Modifier used to make an alpha boost on notes";
            case 'SuddenModifier':
		        explainString = "Modifier used to make an alpha brake on notes";
            case 'VanishModifier':
		        explainString = "Modifier fushion between sudden and hidden";
            case 'SkewModifier':
		        explainString = "Modifier used to make note effects (skew)";
            case 'SkewXModifier':
		        explainString = "Modifier based from SkewModifier but only in X";
            case 'SkewYModifier':
		        explainString = "Modifier based from SkewModifier but only in Y";
            case 'NotesModifier':
		        explainString = "Modifier based from other modifiers but only affects notes and no targets";
            case 'LanesModifier':
		        explainString = "Modifier based from other modifiers but only affects targets and no notes";
            case 'StrumsModifier':
		        explainString = "Modifier based from other modifiers but affects targets and notes";
            case 'TanDrunkXModifier':
		        explainString = "Modifier similar to drunk but uses tan instead of sin in X";
            case 'TanDrunkYModifier':
		        explainString = "Modifier similar to drunk but uses tan instead of sin in Y";
            case 'TanDrunkZModifier':
		        explainString = "Modifier similar to drunk but uses tan instead of sin in Z";
            case 'TanWaveXModifier':
		        explainString = "Modifier similar to wave but uses tan instead of sin in X";
            case 'TanWaveYModifier':
		        explainString = "Modifier similar to wave but uses tan instead of sin in Y";
            case 'TanWaveZModifier':
		        explainString = "Modifier similar to wave but uses tan instead of sin in Z";
            case 'TwirlModifier':
		        explainString = "Modifier that makes the notes incoming rotating in a circle in X";
            case 'RollModifier':
		        explainString = "Modifier that makes the notes incoming rotating in a circle in Y";
            case 'BlinkModifier':
		        explainString = "Modifier that makes the notes alpha go to 0 and go back to 1 constantly";
            case 'CosecantXModifier':
		        explainString = "Modifier similar to TanDrunk but uses cosecant instead of tan in X";
            case 'CosecantYModifier':
		        explainString = "Modifier similar to TanDrunk but uses cosecant instead of tan in Y";
            case 'CosecantZModifier':
		        explainString = "Modifier similar to TanDrunk but uses cosecant instead of tan in Z";
            case 'TanDrunkAngleModifier':
		        explainString = "Modifier similar to TanDrunk but in angle";
            case 'DrunkAngleModifier':
		        explainString = "Modifier similar to Drunk but in angle";
            case 'WaveAngleModifier':
		        explainString = "Modifier similar to Wave but in angle";
            case 'TanWaveAngleModifier':
		        explainString = "Modifier similar to TanWave but in angle";
            case 'ShakyNotesModifier':
		        explainString = "Modifier used to make notes shake in their on possition";
            case 'TordnadoModifier':
		        explainString = "Modifier similar to invertSine, but notes will do their own path instead";
            case 'ArrowPath':
		        explainString = "This modifier its able to make custom paths for the mods so this should be a very helpful tool";
        }

       return explainString;
    }


    function findCorrectModData(data:Array<Dynamic>) //the data is stored at different indexes based on the type (maybe should have kept them the same)
    {
        switch(data[EVENT_TYPE])
        {
            case "ease": 
                return data[EVENT_DATA][EVENT_EASEDATA]; 
            case "set": 
                return data[EVENT_DATA][EVENT_SETDATA];
        }
        return null;
    }
    function setCorrectModData(data:Array<Dynamic>, dataStr:String)
    {
        switch(data[EVENT_TYPE])
        {
            case "ease": 
                data[EVENT_DATA][EVENT_EASEDATA] = dataStr;
            case "set": 
                data[EVENT_DATA][EVENT_SETDATA] = dataStr;
        }
        return data;
    }
    //TODO: fix this shit
    function convertModData(data:Array<Dynamic>, newType:String)
    {
        switch(data[EVENT_TYPE]) //convert stuff over i guess
        {
            case "ease": 
                if (newType == 'set')
                {
                    trace('converting ease to set');
                    var temp:Array<Dynamic> = [newType, [
                        data[EVENT_DATA][EVENT_TIME],
                        data[EVENT_DATA][EVENT_EASEDATA],
                    ], data[EVENT_REPEAT]];
                    data = temp.copy();
                }
            case "set": 
                if (newType == 'ease')
                {
                    trace('converting set to ease');
                    var temp:Array<Dynamic> = [newType, [
                        data[EVENT_DATA][EVENT_TIME],
                        1,
                        "linear",
                        data[EVENT_DATA][EVENT_SETDATA],
                    ], data[EVENT_REPEAT]];
                    trace(temp);
                    data = temp.copy();
                }
        } 
        //trace(data);
        return data;
    }

    function updateEventModData(shitToUpdate:String, isMod:Bool)
    {
        var data = getCurrentEventInData();
        if (data != null)
        {
            var dataStr:String = findCorrectModData(data);
            var dataSplit = dataStr.split(',');
            //the way the data works is it goes "value,mod,value,mod,....." and goes on forever, so it has to deconstruct and reconstruct to edit it and shit

            dataSplit[(getEventModIndex()*2)+(isMod ? 1 : 0)] = shitToUpdate;
            dataStr = stringifyEventModData(dataSplit);
            data = setCorrectModData(data, dataStr);
        }
    }
    function getEventModData(isMod:Bool) : String
    {
        var data = getCurrentEventInData();
        if (data != null)
        {
            var dataStr:String = findCorrectModData(data);
            var dataSplit = dataStr.split(',');
            return dataSplit[(getEventModIndex()*2)+(isMod ? 1 : 0)];
        }
        return "";
    }
    function stringifyEventModData(dataSplit:Array<String>) : String
    {
        var dataStr = "";
        for (i in 0...dataSplit.length)
        {
            dataStr += dataSplit[i];
            if (i < dataSplit.length-1)
                dataStr += ',';
        }
        return dataStr;
    }
    function addNewModData()
    {
        var data = getCurrentEventInData();
        if (data != null)
        {
            var dataStr:String = findCorrectModData(data);
            dataStr += ",,"; //just how it works lol
            data = setCorrectModData(data, dataStr);
        }
        return data;
    }
    function removeModData()
    {
        var data = getCurrentEventInData();
        if (data != null)
        {
            if (selectedEventDataStepper.max > 0) //dont remove if theres only 1
            {
                var dataStr:String = findCorrectModData(data);
                var dataSplit = dataStr.split(',');
                dataSplit.resize(dataSplit.length-2); //remove last 2 things
                dataStr = stringifyEventModData(dataSplit);
                data = setCorrectModData(data, dataStr);
            }
        }
        return data;
    }
    var eventTimeStepper:PsychUINumericStepper;
    var eventModInputText:PsychUIInputText;
    var eventValueInputText:PsychUIInputText;
    var eventDataInputText:PsychUIInputText;
    var eventModifierDropDown:PsychUIDropDownMenu;
    var eventTypeDropDown:PsychUIDropDownMenu;
    var eventEaseInputText:PsychUIInputText;
    var eventTimeInputText:PsychUIInputText;
    var selectedEventDataStepper:PsychUINumericStepper;
    var repeatCheckbox:PsychUICheckBox;
    var repeatBeatGapStepper:PsychUINumericStepper;
    var repeatCountStepper:PsychUINumericStepper;
    var easeDropDown:PsychUIDropDownMenu;
    var subModDropDown:PsychUIDropDownMenu;
    var builtInModDropDown:PsychUIDropDownMenu;
    var stackedEventStepper:PsychUINumericStepper;
    function setupEventUI()
    {
        var tab_group = UI_box.getTab('Events').menu;

        eventTimeStepper = new PsychUINumericStepper(850, 50, 0.25, 0, 0, 9999, 3);


        repeatCheckbox = new PsychUICheckBox(950, 50, "Repeat Event?");
        repeatCheckbox.checked = false;
        repeatCheckbox.onClick = function()
        {
            var data = getCurrentEventInData();
            if (data != null)
            {
                data[EVENT_REPEAT][EVENT_REPEATBOOL] = repeatCheckbox.checked;
                highlightedEvent = data;
                dirtyUpdateEvents = true;
                hasUnsavedChanges = true;
            }
        }
        repeatBeatGapStepper = new PsychUINumericStepper(950, 100, 0.25, 0, 0, 9999, 3);
        repeatBeatGapStepper.name = 'repeatBeatGap';
        repeatCountStepper = new PsychUINumericStepper(950, 150, 1, 1, 1, 9999, 3);
        repeatCountStepper.name = 'repeatCount';
        centerXToObject(repeatCheckbox, repeatBeatGapStepper);
        centerXToObject(repeatCheckbox, repeatCountStepper);

        eventModInputText = new PsychUIInputText(25, 50, 160, '', 8);
        eventModInputText.onChange = function(str:String, str2:String)
        {
            updateEventModData(eventModInputText.text, true);
            var data = getCurrentEventInData();
            if (data != null)
            {
                highlightedEvent = data; 
                eventDataInputText.text = highlightedEvent[EVENT_DATA][EVENT_EASEDATA];
                dirtyUpdateEvents = true;
                hasUnsavedChanges = true;
            }
        };
        eventValueInputText = new PsychUIInputText(25 + 200, 50, 160, '', 8);
        eventValueInputText.onChange = function(str:String, str2:String)
        {
            updateEventModData(eventValueInputText.text, false);
            var data = getCurrentEventInData();
            if (data != null)
            {
                highlightedEvent = data; 
                eventDataInputText.text = highlightedEvent[EVENT_DATA][EVENT_EASEDATA];
                dirtyUpdateEvents = true;
                hasUnsavedChanges = true;
            }
        };

        selectedEventDataStepper = new PsychUINumericStepper(25 + 400, 50, 1, 0, 0, 0, 0);
        selectedEventDataStepper.name = "selectedEventMod";        

        stackedEventStepper = new PsychUINumericStepper(25 + 400, 200, 1, 0, 0, 0, 0);
        stackedEventStepper.name = "stackedEvent";    

        var addStacked:PsychUIButton = new PsychUIButton(stackedEventStepper.x, stackedEventStepper.y+30, 'Add', function ()
        {
            var data = getCurrentEventInData();
            if (data != null)
            {
                var event = addNewEvent(data[EVENT_DATA][EVENT_TIME]);
                highlightedEvent = event;
                onSelectEvent();
                updateEventSprites();
                dirtyUpdateEvents = true;
            } 
        });
        centerXToObject(stackedEventStepper, addStacked);

        eventTypeDropDown = new PsychUIDropDownMenu(25 + 500, 50, eventTypes, function(id:Int, mod:String)
        {
            var et = eventTypes[id];
            trace(et);
            var data = getCurrentEventInData();
            if (data != null)
            {
                //if (data[EVENT_TYPE] != et)
                data = convertModData(data, et);
                highlightedEvent = data;
                trace(highlightedEvent);
            }
            eventEaseInputText.alpha = 1;
            eventTimeInputText.alpha = 1;
            if (et != 'ease')
            {
                eventEaseInputText.alpha = 0.5;
                eventTimeInputText.alpha = 0.5;
            }
            dirtyUpdateEvents = true;
            hasUnsavedChanges = true;
        });
        eventEaseInputText = new PsychUIInputText(25 + 650, 50+100, 160, '', 8);
        eventTimeInputText = new PsychUIInputText(25 + 650, 50, 160, '', 8);
        eventEaseInputText.onChange = function(str:String, str2:String)
        {
            var data = getCurrentEventInData();
            if (data != null)
            {
                if (data[EVENT_TYPE] == 'ease')
                    data[EVENT_DATA][EVENT_EASE] = eventEaseInputText.text;
            }
            dirtyUpdateEvents = true;
            hasUnsavedChanges = true;
        }
        eventTimeInputText.onChange = function(str:String, str2:String)
        {
            var data = getCurrentEventInData();
            if (data != null)
            {
                if (data[EVENT_TYPE] == 'ease')
                    data[EVENT_DATA][EVENT_EASETIME] = eventTimeInputText.text;
            }
            dirtyUpdateEvents = true;
            hasUnsavedChanges = true;
        }

        easeDropDown = new PsychUIDropDownMenu(25, eventEaseInputText.y+30, easeList, function(id:Int, ease:String)
        {
            var easeStr = easeList[id];
            eventEaseInputText.text = easeStr;
            eventEaseInputText.onChange("", ""); //make sure it updates
            hasUnsavedChanges = true;
        });
        centerXToObject(eventEaseInputText, easeDropDown);


        eventModifierDropDown = new PsychUIDropDownMenu(25, 50+20, mods, function(id:Int, mod:String)
        {
            var modName = mods[id];
            eventModInputText.text = modName;
            updateSubModList(modName);
            eventModInputText.onChange("", ""); //make sure it updates
            hasUnsavedChanges = true;
        });
        centerXToObject(eventModInputText, eventModifierDropDown);
        
        subModDropDown = new PsychUIDropDownMenu(25, 50+80, subMods, function(id:Int, mod:String)
        {
            var modName = subMods[id];
            var splitShit = eventModInputText.text.split(":"); //use to get the normal mod

            if (modName == "")
            {
                eventModInputText.text = splitShit[0]; //remove the sub mod
            }
            else 
            {
                eventModInputText.text = splitShit[0] + ":" + modName;
            }
            
            eventModInputText.onChange("", ""); //make sure it updates
            hasUnsavedChanges = true;
        });
        centerXToObject(eventModInputText, subModDropDown);

        eventDataInputText = new PsychUIInputText(25, 300, 300, '', 8);
        //eventDataInputText.resize(300, 300);
        eventDataInputText.onChange = function(str:String, str2:String)
        {
            var data = getCurrentEventInData();
            if (data != null)
            {
                data[EVENT_DATA][EVENT_EASEDATA] = eventDataInputText.text;
                highlightedEvent = data; 
                dirtyUpdateEvents = true;
                hasUnsavedChanges = true;
            }
        };

        var add:PsychUIButton = new PsychUIButton(0, selectedEventDataStepper.y+30, 'Add', function ()
        {
            var data = addNewModData();
            if (data != null)
            {
                highlightedEvent = data; 
                updateSelectedEventDataStepper();
                eventDataInputText.text = highlightedEvent[EVENT_DATA][EVENT_EASEDATA];
                eventModInputText.text = getEventModData(true);
                eventValueInputText.text = getEventModData(false);
                dirtyUpdateEvents = true;
                hasUnsavedChanges = true;
            }
        });
        var remove:PsychUIButton = new PsychUIButton(0, selectedEventDataStepper.y+55, 'Remove', function ()
        {
            var data = removeModData();
            if (data != null)
            {
                highlightedEvent = data; 
                updateSelectedEventDataStepper();
                eventDataInputText.text = highlightedEvent[EVENT_DATA][EVENT_EASEDATA];
                eventModInputText.text = getEventModData(true);
                eventValueInputText.text = getEventModData(false);
                dirtyUpdateEvents = true;
                hasUnsavedChanges = true;
            }
        });
        centerXToObject(selectedEventDataStepper, add);
        centerXToObject(selectedEventDataStepper, remove);
        tab_group.add(add);
        tab_group.add(remove);

       
        textBlockers.push(eventModInputText);
        textBlockers.push(eventDataInputText);
        textBlockers.push(eventValueInputText);
        textBlockers.push(eventEaseInputText);
        textBlockers.push(eventTimeInputText);
        scrollBlockers.push(eventModifierDropDown);
        scrollBlockers.push(eventTypeDropDown);
        scrollBlockers.push(subModDropDown);
        scrollBlockers.push(easeDropDown);

        tab_group.add(addStacked);
        tab_group.add(eventDataInputText);
        tab_group.add(stackedEventStepper);

        tab_group.add(makeLabel(stackedEventStepper, 0, -15, "Stacked Events Index"));

        tab_group.add(eventValueInputText);
        tab_group.add(eventModInputText);

        tab_group.add(repeatBeatGapStepper);
        tab_group.add(repeatCheckbox);
        tab_group.add(repeatCountStepper);

        tab_group.add(makeLabel(repeatBeatGapStepper, 0, -30, "How many beats in between\neach repeat?"));
        tab_group.add(makeLabel(repeatCountStepper, 0, -15, "How many times to repeat?"));

        tab_group.add(eventEaseInputText);
        tab_group.add(eventTimeInputText);

        tab_group.add(makeLabel(eventEaseInputText, 0, -15, "Event Ease"));
        tab_group.add(makeLabel(eventTimeInputText, 0, -15, "Event Ease Time (in Beats)"));
        tab_group.add(makeLabel(eventTypeDropDown, 0, -15, "Event Type"));

        tab_group.add(eventTimeStepper);
        tab_group.add(selectedEventDataStepper);

        tab_group.add(makeLabel(selectedEventDataStepper, 0, -15, "Selected Data Index"));
        tab_group.add(makeLabel(eventDataInputText, 0, -15, "Raw Event Data"));
        tab_group.add(makeLabel(eventValueInputText, 0, -15, "Event Value"));
        tab_group.add(makeLabel(eventModInputText, 0, -15, "Event Mod"));
        tab_group.add(makeLabel(subModDropDown, 0, -15, "Sub Mods"));

        tab_group.add(subModDropDown);
        tab_group.add(eventModifierDropDown);
        tab_group.add(eventTypeDropDown);
        tab_group.add(easeDropDown);
    }
    function getCurrentEventInData() //find stored data to match with highlighted event
    {
        if (highlightedEvent == null)
            return null;
        for (i in 0..._modchart.events.length)
        {
            if (_modchart.events[i] == highlightedEvent)
            {
                return _modchart.events[i];
            }
        }

        return null;
    }
    function getMaxEventModDataLength() //used for the stepper so it doesnt go over max and break something
    {
        var data = getCurrentEventInData();
        if (data != null)
        {
            var dataStr:String = findCorrectModData(data);
            var dataSplit = dataStr.split(',');
            return Math.floor((dataSplit.length/2)-1);
        }
        return 0;
    }
    function updateSelectedEventDataStepper() //update the stepper
    {
        selectedEventDataStepper.max = getMaxEventModDataLength();
        if (selectedEventDataStepper.value > selectedEventDataStepper.max)
            selectedEventDataStepper.value = 0;
    }
    function updateStackedEventDataStepper() //update the stepper
    {
        stackedEventStepper.max = stackedHighlightedEvents.length-1;
        stackedEventStepper.value = stackedEventStepper.max; //when you select an event, if theres stacked events it should be the one at the end of the list so just set it to the end
    }
    function getEventModIndex() { return Math.floor(selectedEventDataStepper.value); }
    var eventTypes:Array<String> = ["ease", "set"];
    function onSelectEvent(fromStackedEventStepper = false)
    {
        //update texts and stuff
        updateSelectedEventDataStepper();
        eventTimeStepper.value = Std.parseFloat(highlightedEvent[EVENT_DATA][EVENT_TIME]);
        eventDataInputText.text = highlightedEvent[EVENT_DATA][EVENT_EASEDATA];

        eventEaseInputText.alpha = 0.5;
        eventTimeInputText.alpha = 0.5;
        if (highlightedEvent[EVENT_TYPE] == 'ease')
        {
            eventEaseInputText.alpha = 1;
            eventTimeInputText.alpha = 1;
            eventEaseInputText.text = highlightedEvent[EVENT_DATA][EVENT_EASE];
            eventTimeInputText.text = highlightedEvent[EVENT_DATA][EVENT_EASETIME];
        }
        eventTypeDropDown.selectedLabel = highlightedEvent[EVENT_TYPE];
        eventModInputText.text = getEventModData(true);
        eventValueInputText.text = getEventModData(false);
        repeatBeatGapStepper.value = highlightedEvent[EVENT_REPEAT][EVENT_REPEATBEATGAP];
        repeatCountStepper.value = highlightedEvent[EVENT_REPEAT][EVENT_REPEATCOUNT];
        repeatCheckbox.checked = highlightedEvent[EVENT_REPEAT][EVENT_REPEATBOOL];
        if (!fromStackedEventStepper)
            stackedEventStepper.value = 0;
        dirtyUpdateEvents = true;
    }

    var playfieldCountStepper:PsychUINumericStepper;
    function setupPlayfieldUI()
    {
        var tab_group = UI_box.getTab('Playfields').menu;

        playfieldCountStepper = new PsychUINumericStepper(25, 50, 1, 1, 1, 100, 0);
        playfieldCountStepper.value = playfieldRenderer.modchart.data.playfields;
        playfieldCountStepper.value = _modchart.playfields;
        
        tab_group.add(playfieldCountStepper);
        tab_group.add(makeLabel(playfieldCountStepper, 0, -15, "Playfield Count"));
        tab_group.add(makeLabel(playfieldCountStepper, 55, 25, "Don't add too many or the game will lag!!!"));
    }

    var sliderRate:PsychUISlider;
    var songSlider:PsychUISlider;

    var instVolumeStepper:PsychUINumericStepper;
    var playerVolumeStepper:PsychUINumericStepper;
    var opponentVolumeStepper:PsychUINumericStepper;

    function setupEditorUI()
    {
        var tab_group = UI_box.getTab('Editor').menu;

        sliderRate = new PsychUISlider(20, 120, function(v:Float) {
            playbackSpeed = v;
            dirtyUpdateEvents = true;
        }, 1, 0.1, 3, 250);
		sliderRate.label = 'Playback Rate';

        songSlider = new PsychUISlider(20, 200, function(fuck:Float)
		{
			inst.time = fuck;
            vocals.time = inst.time;
            if (opponentVocals != null) opponentVocals.time = inst.time;
			Conductor.songPosition = inst.time;
            dirtyUpdateEvents = true;
            dirtyUpdateNotes = true;
		}, 0, 0, inst.length, 250);
        songSlider.label = 'Song Time';

        instVolumeStepper = new PsychUINumericStepper(10, 20, 0.1, 1, 0, 1, 1, true);
		instVolumeStepper.onValueChange = function()
		{
			inst.volume = instVolumeStepper.value;
		};

		playerVolumeStepper = new PsychUINumericStepper(instVolumeStepper.x + 120, instVolumeStepper.y, 0.1, 1, 0, 1, 1, true);
		playerVolumeStepper.onValueChange = function()
		{
			if (vocals != null) vocals.volume = playerVolumeStepper.value;
		};

		opponentVolumeStepper = new PsychUINumericStepper(playerVolumeStepper.x + 120, playerVolumeStepper.y, 0.1, 1, 0, 1, 1, true);
		opponentVolumeStepper.onValueChange = function()
		{
			if (opponentVocals != null) opponentVocals.volume = opponentVolumeStepper.value;
		};

        var resetSpeed:PsychUIButton = new PsychUIButton(sliderRate.x+300, sliderRate.y, 'Reset', function ()
        {
            sliderRate.value = playbackSpeed = 1.0;
        });

        var saveJson:PsychUIButton = new PsychUIButton(20, 300, 'Save Modchart', function() {
			saveModchartJson(this);
		});
        saveJson.normalStyle.bgColor = 0xFF152C12;
		saveJson.normalStyle.textColor = FlxColor.WHITE;
		tab_group.add(saveJson);

        var openAutosave:PsychUIButton = new PsychUIButton(saveJson.x + 100, 300, 'Open Autosave', function ()
        {
            if(!fileDialog.completed) return;

			if(!FileSystem.exists('backups/modcharts/${_song.song}'))
			{
				showOutput('The "backups/modcharts/${_song.song}" folder does not exist.', true);
				return;
			}
			
			var fileList:Array<String> = FileSystem.readDirectory('backups/modcharts/${_song.song}').filter((file:String) -> file.endsWith('.$BACKUP_EXT'));
			if(fileList.length < 1)
			{
				showOutput('No autosave files found.', true);
				return;
			}

			fileList.sort((a:String, b:String) -> (a.toUpperCase() < b.toUpperCase()) ? 1 : -1); //Sort alphabetically descending
			var maxItems:Int = Std.int(Math.min(5, fileList.length));
			var radioGrp:PsychUIRadioGroup = new PsychUIRadioGroup(0, 0, fileList, 25, maxItems, false, 240);
			radioGrp.checked = 0;

			var hei:Float = radioGrp.height + 160;
			openSubState(new gameObjects.ui.customEditorUI.Prompt.BasePrompt(420, hei, 'Choose an Autosave',
				function(state:gameObjects.ui.customEditorUI.Prompt.BasePrompt) {

					var btn:PsychUIButton = new PsychUIButton(state.bg.x + state.bg.width - 40, state.bg.y, 'X', state.close, 40);
					btn.cameras = state.cameras;
					state.add(btn);

					radioGrp.screenCenter(X);
					radioGrp.y = state.bg.y + 80;
					radioGrp.cameras = state.cameras;
					state.add(radioGrp);

					var btn:PsychUIButton = new PsychUIButton(0, radioGrp.y + radioGrp.height + 20, 'Load', function()
					{
						var autosaveName:String = fileList[radioGrp.checked];
						var path:String = 'backups/modcharts/${_song.song}/$autosaveName';
						state.close();

						if(FileSystem.exists(path))
						{
							try
							{
								var loadedChart:ModchartJson = ModchartFile.parseModchartBullshit(File.getContent(path));
								if(loadedChart == null)
								{
									showOutput('Error: File loaded is not a valid Modchart autosave.', true);
									return;
								}
	
								var func:Void->Void = function()
								{
									if (playfieldInstance != null)
                                        playfieldInstance.playfieldRenderer.modchart.data = loadedChart;
                                    else
                                        playfieldRenderer.modchart.data = loadedChart;

                                    MusicBeatState.resetState();
                                    ModchartFile.autosaveMod = File.getContent(path);
								}
								
								openSubState(new gameObjects.ui.customEditorUI.Prompt('Warning: Any unsaved progress\nwill be lost.', 0, function() {
                                    func();
                                }, null,false, camHUD));
							}
							catch(e:Exception)
							{
								showOutput('Error on loading autosave: ${e.message}', true);
							}
						}
						else showOutput('Error! Autosave file selected could not be found, huh??', true);
					});
					btn.cameras = state.cameras;
					btn.screenCenter(X);
					state.add(btn);
				}
			));
        });
        openAutosave.normalStyle.bgColor = 0xFF12172C;
		openAutosave.normalStyle.textColor = FlxColor.WHITE;
        tab_group.add(openAutosave);

        var autosaveSettings:PsychUIButton = new PsychUIButton(openAutosave.x, 350, 'Autosave Settings', function ()
        {
            openSubState(new gameObjects.ui.customEditorUI.Prompt.BasePrompt(400, 160, 'Autosave Settings',
				function(state:gameObjects.ui.customEditorUI.Prompt.BasePrompt)
				{
					var btn:PsychUIButton = new PsychUIButton(state.bg.x + state.bg.width - 40, state.bg.y, 'X', state.close, 40);
					btn.cameras = state.cameras;
					state.add(btn);

					var checkbox:PsychUICheckBox = null;
					var timeStepper:PsychUINumericStepper = null;

					timeStepper = new PsychUINumericStepper(state.bg.x + 50, state.bg.y + 90, 1, autoSaveCap, 1, 30, 0);
					timeStepper.onValueChange = function() {
						autoSaveTime = 0;
						checkbox.checked = true;
						autoSaveCap = modchartEditorSave.data.autoSave = Std.int(timeStepper.value);
					};
					timeStepper.cameras = state.cameras;

					checkbox = new PsychUICheckBox(timeStepper.x + 80, timeStepper.y, 'Enabled', 60, function() {
						autoSaveTime = 0;
						autoSaveCap = modchartEditorSave.data.autoSave = checkbox.checked ? Std.int(timeStepper.value) : 0;
					});
					checkbox.checked = (autoSaveCap > 0);
					checkbox.cameras = state.cameras;
					
					var maxFileStepper:PsychUINumericStepper = new PsychUINumericStepper(checkbox.x + 140, checkbox.y, 1, backupLimit, 0, 50, 0);
					maxFileStepper.onValueChange = function() {
						autoSaveTime = 0;
						checkbox.checked = true;
						modchartEditorSave.data.backupLimit = backupLimit = Std.int(maxFileStepper.value);
					};
					maxFileStepper.cameras = state.cameras;

					var txt1:FlxText = new FlxText(timeStepper.x, timeStepper.y - 15, 100, 'Time (in minutes):');
					txt1.cameras = state.cameras;
					var txt2:FlxText = new FlxText(maxFileStepper.x, maxFileStepper.y - 15, 100, 'File Limit:');
					txt2.cameras = state.cameras;

					state.add(txt1);
					state.add(txt2);
					state.add(checkbox);
					state.add(timeStepper);
					state.add(maxFileStepper);
				}
			));
        });
        autosaveSettings.resize(80, 30);
        tab_group.add(autosaveSettings);

        tab_group.add(sliderRate);
        tab_group.add(resetSpeed);
        tab_group.add(songSlider);

        tab_group.add(new FlxText(instVolumeStepper.x, instVolumeStepper.y - 15, 100, 'Inst. Volume:'));
		tab_group.add(new FlxText(playerVolumeStepper.x, playerVolumeStepper.y - 15, 100, 'Main Vocals:'));
		tab_group.add(new FlxText(opponentVolumeStepper.x, opponentVolumeStepper.y - 15, 100, 'Opp. Vocals:'));
		tab_group.add(instVolumeStepper);
        tab_group.add(playerVolumeStepper);
        tab_group.add(opponentVolumeStepper);
    }

    function centerXToObject(obj1:FlxSprite, obj2:FlxSprite) //snap second obj to first
    {
        obj2.x = obj1.x + (obj1.width/2) - (obj2.width/2);
    }
    function makeLabel(obj:FlxSprite, offsetX:Float, offsetY:Float, textStr:String)
    {
        var text = new FlxText(0, obj.y+offsetY, 0, textStr);
        text.setFormat(Paths.font("resultsFont.ttf"), 12, FlxColor.WHITE);
        centerXToObject(obj, text);
        text.x += offsetX;
        return text;
    }

    var _file:FileReference;
    public function saveModchartJson(?instance:MusicBeatState = null) : Void
    {
        if (instance == null)
            instance = PlayState.instance;

		var json = {
            _modchart;
        };
		var data:String = Json.stringify(json, "\t");
        //data = data.replace("\n", "");
        //data = data.replace(" ", "");
        #if sys
        //sys.io.File.saveContent("modchart.json", data.trim()); 
		if ((data != null) && (data.length > 0))
        {
            _file = new FileReference();
            _file.addEventListener(#if desktop openfl.events.Event.SELECT #else openfl.events.Event.COMPLETE #end, onSaveComplete);
            _file.addEventListener(openfl.events.Event.CANCEL, onSaveCancel);
            _file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
            _file.save(data.trim(), "modchart.json");
        }
        #end

        hasUnsavedChanges = false;
        
    }
    function onSaveComplete(_):Void
    {
        _file.removeEventListener(#if desktop openfl.events.Event.SELECT #else openfl.events.Event.COMPLETE #end, onSaveComplete);
        _file.removeEventListener(openfl.events.Event.CANCEL, onSaveCancel);
        _file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
        _file = null;
    }

	/**
     * Called when the save file dialog is cancelled.
     */
    function onSaveCancel(_):Void
    {
        _file.removeEventListener(#if desktop openfl.events.Event.SELECT #else openfl.events.Event.COMPLETE #end, onSaveComplete);
        _file.removeEventListener(openfl.events.Event.CANCEL, onSaveCancel);
        _file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
        _file = null;
    }

    /**
     * Called if there is an error while saving the gameplay recording.
     */
    function onSaveError(_):Void
    {
        _file.removeEventListener(#if desktop openfl.events.Event.SELECT #else openfl.events.Event.COMPLETE #end, onSaveComplete);
        _file.removeEventListener(openfl.events.Event.CANCEL, onSaveCancel);
        _file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
        _file = null;
    }   

    public function UIEvent(id:String, sender:Dynamic) {
		if(id == PsychUINumericStepper.CHANGE_EVENT)
		{
			if (sender == selectedEventDataStepper)
			{
                if (highlightedEvent != null)
                {
                    eventDataInputText.text = highlightedEvent[EVENT_DATA][EVENT_EASEDATA];
                    eventModInputText.text = getEventModData(true);
                    eventValueInputText.text = getEventModData(false);
                }
			}
            else if (sender == repeatBeatGapStepper)
			{
                var data = getCurrentEventInData();
                if (data != null)
                {
                    data[EVENT_REPEAT][EVENT_REPEATBEATGAP] = repeatBeatGapStepper.value;
                    highlightedEvent = data;
                    hasUnsavedChanges = true;
                    dirtyUpdateEvents = true;
                }
			}
            else if (sender == repeatCountStepper)
			{
                var data = getCurrentEventInData();
                if (data != null)
                {
                    data[EVENT_REPEAT][EVENT_REPEATCOUNT] = repeatCountStepper.value;
                    highlightedEvent = data;
                    hasUnsavedChanges = true;
                    dirtyUpdateEvents = true;
                }
			}
            else if (sender == stackedEventStepper)
			{
                if (highlightedEvent != null)
                {
                    //trace(stackedHighlightedEvents);
                    highlightedEvent = stackedHighlightedEvents[Std.int(stackedEventStepper.value)];
                    onSelectEvent(true);
                }
			}
		}
	}
}