#if !macro
/**
 * ## This file acts as a global import of all the classes you want to utilize on everything in the code!
 * 
 * here are examples of what you can put in here:
 * 
 * ```haxe
 * import YourClassHere;
 * import folder.YourClassHere;
 * import YourClassHere.AnotherClass;
 * using YourClassHere; // (`using` is ONLY useful for class extensions!)
 * using folder.folder2.YourClassHere;
 * ```
 * 
 * There are many more ways of using this file, so go nuts!
 */

 // just in case
 import unused.*;

 // import objects, menus and backend support
import backend.*;
import backend.embeddedFiles.*;
import backend.windows.*;
import objects.*;
import objects.notes.*;
import objects.ui.*;

// import screens you see in-game
import substates.*;
import states.*;
import states.editors.*;
import states.options.*;
import states.menus.*;
import states.menus.freeplay.*;

//import game over screens
import substates.GameOverScreens.BaseGameOver; //default fnf screen
import substates.GameOverScreens.ManiaLoseScreen; //mania charts only
import substates.GameOverScreens.Episode1Death; //Episode 1
import substates.GameOverScreens.DelusionalDeath; //Delusional Exclusive
import substates.GameOverScreens.EpicFailLmao; //Don't Cross Ragebait
import substates.GameOverScreens.EverettBaseDeath; //Default Everett Death
import substates.GameOverScreens.WarGameOver; //War Dilemma Exclusive
import substates.GameOverScreens.WompWompSadMan; //Birthday Exclusive
import substates.GameOverScreens.MalsquareDeath; //Malfunction Exclusive
import substates.GameOverScreens.MalsquareTrollScreen; //Least Annoying Thing in the mod

//import pause screens
import substates.PauseScreens.PauseSubState; //default fnf screen
import substates.PauseScreens.FAVIPauseSubState; //favi screen
import substates.PauseScreens.PauseManiaSubstate; //mania screen

// import specific menus and objects to prevent compile errors
#if desktop
import backend.Discord;
#end
import states.editors.ChartingState;
#if ACHIEVEMENTS_ALLOWED
import objects.Achievements;
#end
import objects.Character;
import cutscenes.DialogueBoxPsych;
import objects.MenuCharacter;
import backend.Conductor;
import backend.StageData;
import backend.WeekData;
import backend.Controls;

// import modchart system
import modcharting.*;

// import shaders
import shaders.ColorSwap;
import shaders.BlendModeEffect;
import shaders.WiggleEffect;
import shaders.WiggleEffect.WiggleEffectType;
import shaders.OutlineEffect;

// stuff that won't let you compile unless they're being used
#if VIDEOS_ALLOWED
import objects.VideoSprite;
#end
import backend.Conductor.BPMChangeEvent;
import backend.Section.SwagSection;
import backend.Song.SwagSong;
import backend.CustomFadeTransition;
import objects.notes.Note.EventNote;

// shitty mod support stuff I plan on removing soon but for now is needed for the game to work
#if LUA_ALLOWED
import psychlua.FunkinLua.ModchartSprite;
import psychlua.FunkinLua.ModchartText;
import psychlua.FunkinLua.DebugLuaText;
#end

// import majority of classes the game uses from flixel almost everywhere
import flixel.*;
import flixel.ui.*;
import flixel.effects.particles.*;
import flixel.addons.display.*;
import flixel.addons.effects.*;
import flixel.addons.text.*;
import flixel.addons.ui.*;
import flixel.group.*;
import flixel.addons.effects.chainable.*;
import flixel.math.*;
import flixel.tweens.*;
import flixel.util.*;
import flixel.graphics.*;
import flixel.text.*;
import flixel.graphics.tile.*;
import flixel.graphics.frames.*;
import flixel.graphics.atlas.*;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween.FlxTweenManager;
import flixel.text.FlxText.FlxTextAlign;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.util.FlxSignal.FlxTypedSignal;

#if flxanimate
import flxanimate.*;
#end

//Flixel
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;

#if (flixel <= "5.2.2")
	import flixel.system.FlxSound;
#else
	import flixel.sound.FlxSound;
#end

using StringTools;
#end

#if LEATHER
import states.PlayState;
import game.Song;
import game.Section.SwagSection;
import game.Note;
import ui.FlxScrollableDropDownMenu;
import game.Conductor;
import utilities.CoolUtil;
import game.StrumNote;
import utilities.NoteVariables;
import states.LoadingState;
import states.MusicBeatState;
import substates.MusicBeatSubstate;
#elseif (PSYCH && PSYCHVERSION >= "0.7")
import flixel.addons.ui.FlxUIDropDownMenu;
import backend.Section.SwagSection;
import states.PlayState;
import backend.CoolUtil;
import backend.Conductor;
import backend.ClientPrefs;
import backend.Paths;
import states.LoadingState;
import backend.Difficulty;
#if SCEModchartingTools
import substates.MusicBeatSubstate;
#else
import backend.MusicBeatSubstate;
#end
import objects.notes.Note;
#if SCEModchartingTools
import objects.StrumArrow;
#else
import objects.notes.StrumNote;
#end
import backend.Song;
#else
import Section.SwagSection;
import Song;
import MusicBeatSubstate;
#end

#if (PSYCH && PSYCHVERSION >= "0.7")
#if LUA_ALLOWED
import psychlua.FunkinLua;
import psychlua.HScript as FunkinHScript;
#end
#end

#if sys
import sys.FileSystem;
import sys.io.File;
#end