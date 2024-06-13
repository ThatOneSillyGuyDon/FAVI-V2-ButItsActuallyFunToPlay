package states;

import gamejolt.GameJolt.GameJoltAPI;
import flixel.FlxSprite;
import flixel.text.FlxText;
import sys.io.File;
import openfl.filters.ShaderFilter;
import flixel.util.FlxColor;
import lime.app.Application;
import lime.ui.Window;
import flixel.FlxG;
#if (flixel <= "5.2.2")
	import flixel.system.FlxSound;
#else
	import flixel.sound.FlxSound;
#end

/**
 * why did you left his birthday
 */
class ManIHateYouSoMuchYouMadeMuckneySad extends MusicBeatState
{
   // I got plans, and I'm gonna make the art for this lmao -don
   var leMuckney:FlxSprite;
   var background:FlxSprite;
   var booHooHeSoSadThatItsRainingNowYouAreSuchAHorriblePerson:FlxSprite;
   var theFogIsComingTheFogIsComingTheFogIsComingTheFogIsComingTheFogIsComingTheFogIsComingTheFogIsComingTheFogIsComingTheFogIsComingTheFogIsComingTheFogIsComingTheFogIsComingTheFogIsComingTheFogIsComingTheFogIsComingTheFogIsComingTheFogIsComingTheFogIsComing:FlxSprite;

   // easy easter eggs
   var ohFuckTheCantaloupeIsBack:FlxSprite;
   var lowQualityCantaloupeMusic:FlxSound;

   var annoyingOrangeDimension:FlxSprite;
   var lowQualityOrangeMusic:FlxSound;

   var kysMeme:FlxSprite;
   var lightning:FlxSound;

   var among:FlxSprite;
   var us:FlxSound;

   var grimaceShake:FlxSprite;
   var jumpscare:FlxSprite;
   var jumpscareSfx:FlxSound;
   var darkHall:FlxSprite;

   var omgisthatagamebreakerreference:FlxSprite;
   var literallyGamebreaker:FlxSound;

   var malwareJumpscare:FlxSprite;
   var malwareScream:FlxSound;

   var vineBoomSfx:FlxSound;
   var charaSound:FlxSound;

   var firstDegreeMurderBySaster:FlxSprite;
   var thatShittySadEmojiImage:FlxSprite;
   var socialCredits:FlxSprite;
   var burningCash:FlxSprite;
   var fuckedUpCake:FlxSprite;

   // the text stuff
   var totallyEmotionalTextDisplay:FlxText;
   var thatOneTotallyEmotionalTextGeneratorThatACertainTextDisplayCanUseToMakeYouFeelSoEmotionalAndSoVeryVerySad:Array<String> =
   [
      "WHY DID YOU DO THAT?!??",
      "Are you happy you did that?",
      "Fuck you.",
      "You monster...",
      "You could've gave him his happiest day!",
      "FUCK YOU LITTLE BITCH!",
      "Back to his endless loop of horrible birthdays...",
      "Truly the worst decision you could've made there.",
      "among us.",
      "Do you like what you see now?",
      "You're probably worse than Satan frfr.",
      "It's like what they say: \"Karma's a bitch\".",
      "I'm gonna murder you for leaving his party.",
      "That was pathetic of you, honestly.",
      "Muckney just wanted a friend :(",
      "He's miserable now, and it's all thanks to you!",
      "Yeah, REAAAL good job ya did there.",
      "But, why?",
      "I'm gonna remove 6382951432 social credits from ya.",
      "You can't close the game without Task Manager, cry about it.",
      "You did this to yourself ya know...",
      "You left the party, was it worth it?",
      "That wasn't very cash money of you there.",
      "*cantaloupe jumpscare*",
      "POV: You're ass at both the game AND capability of compassion!",
      ">:(",
      "But nobody came.",
      "Not even Mickey would do this bro...",
      "You should be sent to an asylum just for this...",
      "Drink the Grimace Shake, do it, do it now, no balls.",
      "I'm gonna break your fucking game the next time you launch this application.",
      "This could've ended off well if you didn't click that button.",
      "No happy ending for you.",
      "You ruined his cake, you cruel selfish creature!",
      "This is a certified bruh moment.",
      "I bet you're fatherless right about now.",
      "Malware is 30 meters close to your proximity and is approaching rapidly, start running.",
      "*orange jumpscare*",
      "I bet you regret that choice now.",
      "You just love to watch people suffer don't ya you little freak of nature?",
      "You're homeless now!",
      "Why did you leave his special party?",
      "Fuck off, no balloons for you idiot.",
      "Kill yourself."
   ];

   // shaders
   var youDrunkBoi:FlxRuntimeShader;
   var theAcidTripVisualEffect:FlxRuntimeShader;
   
   override function create() {
      super.create();

      Application.current.window.borderless = true;

      if(!GameJoltAPI.checkTrophy(184288))
         GameJoltAPI.getTrophy(184288);

      
   }

   override function update(e)
      {
         super.update(e);
      }
}
