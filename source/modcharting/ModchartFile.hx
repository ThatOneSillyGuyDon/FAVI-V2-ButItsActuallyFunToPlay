package modcharting;

import flixel.math.FlxMath;
import haxe.Exception;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

#if HSCRIPT_ALLOWED
import psychlua.HScript;
#end

using StringTools;

typedef ModchartJson = 
{
    var modifiers:Array<Array<Dynamic>>;
    var events:Array<Array<Dynamic>>;
    var playfields:Int;
}

class ModchartFile
{
    //used for indexing
    public static final MOD_NAME = 0; //the modifier name
    public static final MOD_CLASS = 1; //the class/custom mod it uses
    public static final MOD_TYPE = 2; //the type, which changes if its for the player, opponent, a specific lane or all
    public static final MOD_PF = 3; //the playfield that mod uses
    public static final MOD_LANE = 4; //the lane the mod uses

    public static final EVENT_TYPE = 0; //event type (set or ease)
    public static final EVENT_DATA = 1; //event data
    public static final EVENT_REPEAT = 2; //event repeat data

    public static final EVENT_TIME = 0; //event time (in beats)
    public static final EVENT_SETDATA = 1; //event data (for sets)
    public static final EVENT_EASETIME = 1; //event ease time
    public static final EVENT_EASE = 2; //event ease
    public static final EVENT_EASEDATA = 3; //event data (for eases)

    public static final EVENT_REPEATBOOL = 0; //if event should repeat
    public static final EVENT_REPEATCOUNT = 1; //how many times it repeats
    public static final EVENT_REPEATBEATGAP = 2; //how many beats in between each repeat


    public var data:ModchartJson = null;
    private var renderer:PlayfieldRenderer;
    public var scriptListen:Bool = false;

    public var customModifiers:Map<String, Dynamic> = new Map<String, Dynamic>();

    public var useDownScrollChart:Bool = false; //so it loads false as default!
    public var useMiddleDownScrollChart:Bool = false;
    public var useMiddleUpScrollChart:Bool = false;
    public var useUpScrollChart:Bool = false;
    public static var autosaveMod:String = null;
    public var emptyMod:String = 
    '{
        "modifiers": [],
        "playfields": 1,
        "events": []
    }';

    public static var instance:ModchartFile;
    
    public function new(renderer:PlayfieldRenderer)
    {
        if (autosaveMod != null)
			data = parseModchartBullshit(autosaveMod);
		else
			data = loadFromJson(PlayState.SONG.song.toLowerCase(), Difficulty.getString().toLowerCase() == null ? Difficulty.defaultList[PlayState.storyDifficulty] : Difficulty.getString().toLowerCase());
	    this.renderer = renderer;
        renderer.modchart = this;
        instance = this;
        loadPlayfields();
        loadModifiers();
        loadEvents();
    }

    public var json:String = null;
    public function loadFromJson(folder:String, difficulty:String):ModchartJson //load da shit
    {
        var rawJson = null;
        var filePath = null;

        var folderShit:String = "";
        #if sys
        //downscroll
        var moddyFile:String = Paths.json(Paths.formatToSongPath(folder) + '/modchartData/modchart-downscroll');
        //upscroll
        var moddyFile2:String = Paths.json(Paths.formatToSongPath(folder) + '/modchartData/modchart-upscroll');
        //middle-downscroll
        var moddyFile3:String = Paths.json(Paths.formatToSongPath(folder) + '/modchartData/modchart-middleDown');
        //middle-upscroll
        var moddyFile4:String = Paths.json(Paths.formatToSongPath(folder) + '/modchartData/modchart-middleUp');
        //global modchart
        var moddyFile5:String = Paths.json(Paths.formatToSongPath(folder) + '/modchartData/modchart');

        //this took too long just to get middlescroll support holy fucking shit - Sonic_fan0208
        try 
        {
            //if modchart exists, downscroll is enabled, and middlescroll is disabled (it'll use the downscroll chart)
            if(FileSystem.exists(moddyFile) && ClientPrefs.data.downScroll && !ClientPrefs.data.middleScroll) 
            {
                useDownScrollChart = true;
                useMiddleDownScrollChart = false;
                useMiddleUpScrollChart = false;
                useUpScrollChart = false;
            }
            //if modchart exists, downscroll is disabled, and middlescroll is disabled (it'll use the upscroll chart)
            else if(FileSystem.exists(moddyFile2) && !ClientPrefs.data.downScroll && !ClientPrefs.data.middleScroll) 
            {
                useDownScrollChart = false;
                useMiddleDownScrollChart = false;
                useMiddleUpScrollChart = false;
                useUpScrollChart = true;
            }
            //if modchart exists, downscroll is disabled, and middlescroll is enabled (it'll use the upscroll-middlescroll chart)
            else if(FileSystem.exists(moddyFile4) && !ClientPrefs.data.downScroll && ClientPrefs.data.middleScroll) 
            {
                useDownScrollChart = false;
                useMiddleDownScrollChart = false;
                useMiddleUpScrollChart = true;
                useUpScrollChart = false;
            }
            //if modchart exists, downscroll is enabled, and middlescroll is enabled (it'll use the downscroll-middlescroll chart)
            else if(FileSystem.exists(moddyFile3) && ClientPrefs.data.downScroll && ClientPrefs.data.middleScroll) 
            {
                useDownScrollChart = false;
                useMiddleDownScrollChart = true;
                useMiddleUpScrollChart = false;
                useUpScrollChart = false;
            }
            //if a global modchart exists
            else if (FileSystem.exists(moddyFile5) && !FileSystem.exists(moddyFile) && !FileSystem.exists(moddyFile2) && !FileSystem.exists(moddyFile3) && !FileSystem.exists(moddyFile4))
            {
                useDownScrollChart = false;
                useMiddleDownScrollChart = false;
                useMiddleUpScrollChart = false;
                useUpScrollChart = false;
            }

            if(useDownScrollChart) 
            {
                rawJson = File.getContent(moddyFile).trim();
                folderShit = moddyFile.replace('modchart-downscroll.json', "customMods/");
            }
            else if(useUpScrollChart) 
            {
                rawJson = File.getContent(moddyFile2).trim();
                folderShit = moddyFile2.replace('modchart-upscroll.json', "customMods/");
            }
            else if(useMiddleDownScrollChart) 
            {
                rawJson = File.getContent(moddyFile3).trim();
                folderShit = moddyFile3.replace('modchart-middleDown.json', "customMods/");
            }
            else if(useMiddleUpScrollChart) 
            {
                rawJson = File.getContent(moddyFile4).trim();
                folderShit = moddyFile4.replace('modchart-middleUp.json', "customMods/");
            }
            else if(!useDownScrollChart && !useUpScrollChart && !useMiddleDownScrollChart && !useMiddleUpScrollChart) 
            {
                rawJson = File.getContent(moddyFile5).trim();
                folderShit = moddyFile5.replace('modchart.json', "customMods/");
            }
        }
        catch(e:Dynamic)
        {
            trace(e);
        }
        #end

        if (rawJson == null)
        {
            try
            {   
                //downscroll only
                if (useDownScrollChart)
                {
                    filePath = Paths.json(folder + '/modchartData/modchart-downscroll');
                    folderShit = filePath.replace('modchart-downscroll.json', "customMods/");
                }
                //upscroll only
                else if (useUpScrollChart)
                {
                    filePath = Paths.json(folder + '/modchartData/modchart-upscroll');
                    folderShit = filePath.replace('modchart-upscroll.json', "customMods/");
                }
                //downscroll/middlescroll
                else if (useMiddleDownScrollChart)
                {
                    filePath = Paths.json(folder + '/modchartData/modchart-middleDown');
                    folderShit = filePath.replace('modchart-middleDown.json', "customMods/");
                }
                //upscroll/middle
                else if (useMiddleUpScrollChart)
                {
                    filePath = Paths.json(folder + '/modchartData/modchart-middleUp');
                    folderShit = filePath.replace('modchart-middleUp.json', "customMods/");
                }
                //global
                else if(!useDownScrollChart && !useUpScrollChart && !useMiddleDownScrollChart && !useMiddleUpScrollChart) 
                {
                    filePath = Paths.json(folder + '/modchartData/modchart');
                    folderShit = filePath.replace('modchart.json', "customMods/");
                }
            }
            catch(e:Dynamic)
            {
                trace(e);
            }
            
            #if sys
            if(FileSystem.exists(filePath))
                rawJson = File.getContent(filePath).trim();
            else #end //should become else if i think???
                if (Assets.exists(filePath))
                    rawJson = Assets.getText(filePath).trim();  
                
        }
        if (rawJson != null)
        {
            json = rawJson;
            #if sys
            if (FileSystem.isDirectory(folderShit))
                {
                    trace("folder le exists");
                    for (file in FileSystem.readDirectory(folderShit))
                    {
                        trace(file);
                        if(file.endsWith('.hx')) //custom mods!!!!
                        {
                            var scriptStr = File.getContent(folderShit + file);
                            var scriptInit:Dynamic = null;
                            #if HSCRIPT_ALLOWED
                            scriptInit = new HScript(null, scriptStr);
                            #end
                            customModifiers.set(file.replace(".hx", ""), scriptInit);
                            trace('loaded custom mod: ' + file);
                        }
                    }
                }
            #end
        }
        else 
        {
            switch (PlayState.SONG.song)
            {
                case "Dont Cross":
                    //So...Many...Goddamn....MODCHARTS....WHYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY
                    if (ClientPrefs.data.mechanics && FlxG.random.bool(15))
                    {
                        var modchartRandomizer:Int = FlxG.random.int(1, 8);
                        trace('Fuck you, die.');
                        //I'm realizing that the modcharts get simpler as you get closer to the latest modcharts.
                        switch (modchartRandomizer)
                        {
                            case 1: json = Modchart.dontcrossModchart1;
                            case 2: json = Modchart.dontcrossModchart2;
                            case 3: json = Modchart.dontcrossModchart3;
                            case 4: json = Modchart.dontcrossModchart4;
                            case 5: json = Modchart.dontcrossModchart5;
                            case 6: json = Modchart.dontcrossModchart6;
                            case 7: json = Modchart.iNeedSleep;
                            case 8: json = Modchart.hopefullyTheLastDontCrossModchartCuzTheresSoMany;
                        }
                    }
                    else
                        json = emptyMod;

                 case "Malfunction":
                    if (!ClientPrefs.data.downScroll && !ClientPrefs.data.middleScroll)
                        json = Modchart.malfunctionModchartU;
                    else if (ClientPrefs.data.downScroll && !ClientPrefs.data.middleScroll)
                        json = Modchart.malfunctionModchartD;
                    else if (!ClientPrefs.data.downScroll && ClientPrefs.data.middleScroll)
                        json = Modchart.malfuncMidUp;
                    else if (ClientPrefs.data.downScroll && ClientPrefs.data.middleScroll)
                        json = Modchart.malfuncMidDown;

                case "Rotten Petals":
                    if (ClientPrefs.data.mechanics)
                        json = Modchart.petalsManiaMod;
                    else
                        json = emptyMod;

                case "Seeking Freedom":
                    if (ClientPrefs.data.mechanics)
                        json = Modchart.freedomMod;
                    else
                        json = emptyMod;

                case "Ahh the Scary (Somber Night)":
                    if (ClientPrefs.data.mechanics)
                        json = Modchart.nightManiaMod;
                    else
                        json = emptyMod;

                default:
                    if (autosaveMod != null)
                    {
                        json = autosaveMod;
                    }
                    else
                        json = emptyMod;
                    if (!PlayState.modchartingMode) autosaveMod = null;
            }
        }
        var modchartJson:Dynamic = parseModchartBullshit(json);
        return modchartJson;
    }

    public static function parseModchartBullshit(rawJson:String):ModchartJson
	{
		var swagShit:ModchartJson = cast Json.parse(rawJson);
		return swagShit;
	}

    public function loadEmpty()
    {
        data.modifiers = [];
        data.events = [];
        data.playfields = 1;
    }

    public function loadModifiers()
    {
        if (data == null || renderer == null)
            return;
        renderer.modifierTable.clear();
        for (i in data.modifiers)
        {
            ModchartFuncs.startMod(i[MOD_NAME], i[MOD_CLASS], i[MOD_TYPE], Std.parseInt(i[MOD_PF]), renderer.instance);
            if (i[MOD_LANE] != null)
                ModchartFuncs.setModTargetLane(i[MOD_NAME], i[MOD_LANE], renderer.instance);
        }
        renderer.modifierTable.reconstructTable();
    }
    public function loadPlayfields()
    {
        if (data == null || renderer == null)
            return;

        renderer.playfields = [];
        for (i in 0...data.playfields)
            renderer.addNewPlayfield(0,0,0,1);
    }
    public function loadEvents()
    {
        if (data == null || renderer == null)
            return;
        renderer.eventManager.clearEvents();
        for (i in data.events)
        {
            if (i[EVENT_REPEAT] == null) //add repeat data if it doesnt exist
                i[EVENT_REPEAT] = [false, 1, 0];

            if (i[EVENT_REPEAT][EVENT_REPEATBOOL])
            {
                for (j in 0...(Std.int(i[EVENT_REPEAT][EVENT_REPEATCOUNT])+1))
                {
                    addEvent(i, (j*i[EVENT_REPEAT][EVENT_REPEATBEATGAP]));
                }
            }
            else 
            {
                addEvent(i);
            }

        }
    }
    private function addEvent(i:Array<Dynamic>, ?beatOffset:Float = 0)
    {
        switch(i[EVENT_TYPE])
        {
            case "ease": 
                ModchartFuncs.ease(Std.parseFloat(i[EVENT_DATA][EVENT_TIME])+beatOffset, Std.parseFloat(i[EVENT_DATA][EVENT_EASETIME]), i[EVENT_DATA][EVENT_EASE], i[EVENT_DATA][EVENT_EASEDATA], renderer.instance);
            case "set": 
                ModchartFuncs.set(Std.parseFloat(i[EVENT_DATA][EVENT_TIME])+beatOffset, i[EVENT_DATA][EVENT_SETDATA], renderer.instance);
            case "hscript": 
                //maybe just run some code???
        }
    }

    public function createDataFromRenderer() //a way to convert script modcharts into json modcharts
    {
        if (renderer == null)
            return;

        data.playfields = renderer.playfields.length;
        scriptListen = true;
    }
}