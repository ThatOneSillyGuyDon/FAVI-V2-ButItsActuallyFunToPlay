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

 // import objects, menus and backend support
import backend.*;
import backend.menu.*;
import backend.song.*;
import backend.data.*;
import backend.embeddedFiles.*;
import backend.windows.*;
import gameObjects.*;
import gameObjects.ui.*;
import gameObjects.utils.*;
import gameObjects.stages.*;
import gameObjects.ui.animatedText.*;
import gameObjects.ui.notes.*;
import gameObjects.ui.customEditorUI.*;
import gameObjects.ui.customEditorUI.psychUI.*; //Psych-UI

// import screens you see in-game
import substates.*;
import states.*;
import states.editors.*;
import states.options.*;
import states.menus.*;
import states.menus.freeplay.*;

// Base Stage
import backend.BaseStage.StageAssetData;
import backend.BaseStage.AssetType;
import backend.BaseStage.AssetPriority;
import backend.BaseStage.*;


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

// import specific menus and gameObjects to prevent compile errors
#if desktop
import backend.discord.Discord;
#end
import states.editors.ChartingState;
import gameObjects.Character;
import backend.song.Conductor;
import backend.data.StageData;
import backend.data.WeekData;
import backend.Controls;

// import modchart system
import modcharting.*;

// import shaders
import shaders.ColorSwap;
import shaders.BlendModeEffect;
import shaders.WiggleEffect;
import shaders.WiggleEffect.WiggleEffectType;
import shaders.OutlineEffect;
import shaders.DropShadowShader;
import shaders.BlendEffect;

// stuff that won't let you compile unless they're being used
#if VIDEOS_ALLOWED
import gameObjects.video.VideoSprite;
#end
import backend.song.Conductor.BPMChangeEvent;
import backend.song.Section.SwagSection;
import backend.song.Song.SwagSong;
import gameObjects.transitions.CustomFadeTransition;
import gameObjects.ui.notes.Note.EventNote;

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

import backend.song.Section.SwagSection;
import backend.song.Conductor;
import backend.song.Song;

import states.PlayState;
import backend.CoolUtil;
import backend.data.ClientPrefs;
import backend.Paths;
import states.LoadingState;
import backend.Difficulty;
import backend.menu.MusicBeatSubstate;

import gameObjects.ui.notes.Note;
import gameObjects.ui.notes.StrumNote;

#if sys
import sys.FileSystem;
import sys.io.File;
#end