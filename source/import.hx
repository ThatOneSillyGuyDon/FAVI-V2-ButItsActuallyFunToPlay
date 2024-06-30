/**
 * ## This file acts as a global import of all the classes you want to utilize on everything in the code!
 * 
 * here are examples of what you can put in here:
 * 
 * ```haxe
 * import YourClassHere;
 * import folder.YourClassHere;
 * import YourClassHere.AnotherClass;
 * using YourClassHere;
 * using folder.folder2.YourClassHere;
 * ```
 * 
 * There are many more ways of using this file, so go nuts!
 */

 // just in case
 import unused.*;

 // import objects, menus and backend support
import backend.*;
import backend.menu.*;
import backend.song.*;
import backend.data.*;
import backend.nSwitch.*;
import gameObjects.*;
import gameObjects.ui.*;
import gameObjects.utils.*;
import gameObjects.stageObjects.*;
import gameObjects.ui.dialogue.*;
import gameObjects.ui.menu.*;
import gameObjects.ui.animatedText.*;
import gameObjects.ui.notes.*;
import gameObjects.ui.customEditorUI.*;

// import screens you see in-game
import substates.*;
import states.*;
import states.editors.*;
import states.options.*;
import states.menus.*;

// import specific menus and objects to prevent compile errors
#if desktop
import backend.discord.Discord;
#end
import states.editors.ChartingState;
import gameObjects.Achievements;
import gameObjects.Character;
import gameObjects.ui.dialogue.DialogueBoxPsych;
import gameObjects.ui.menu.MenuCharacter;
import backend.song.Conductor;
import backend.data.StageData;
import backend.data.WeekData;
import backend.Controls;

// import modchart system
import modcharting.*;

// import shaders
import shaders.ColorSwap;
import shaders.OverlayShader;
import shaders.BlendModeEffect;
import shaders.WiggleEffect;
import shaders.WiggleEffect.WiggleEffectType;
import shaders.Shaders;

// stuff that won't let you compile unless they're being used
#if VIDEOS_ALLOWED
using gameObjects.video.VideoSprite;
#end
using backend.song.Conductor.BPMChangeEvent;
using backend.song.Section.SwagSection;
using backend.song.Song.SwagSong;
using gameObjects.transitions.CustomFadeTransition;
using gameObjects.ui.notes.Note.EventNote;

// shitty mod support stuff I plan on removing soon but for now is needed for the game to work
using backend.FunkinLua.ModchartSprite;
using backend.FunkinLua.ModchartText;
using backend.FunkinLua.DebugLuaText;

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

using flixel.group.FlxGroup.FlxTypedGroup;
using flixel.tweens.FlxTween.FlxTweenManager;
using flixel.text.FlxText.FlxTextAlign;
using flixel.text.FlxText.FlxTextBorderStyle;
using flixel.util.FlxSignal.FlxTypedSignal;

using StringTools;