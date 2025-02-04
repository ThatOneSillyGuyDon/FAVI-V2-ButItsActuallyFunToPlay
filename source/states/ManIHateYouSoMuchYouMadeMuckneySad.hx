package states;

import flixel.FlxSprite;
import flixel.text.FlxText;
import sys.io.File;
import openfl.filters.ShaderFilter;
import flixel.util.FlxColor;
import lime.app.Application;
import openfl.Lib;
import lime.ui.Window;
import flixel.FlxG;
#if (flixel <= "5.2.2")
	import flixel.system.FlxSound;
#else
	import flixel.sound.FlxSound;
#end


/*why everyone forgot about this
...... should I do the funnies here? - malyplus/*

// no i didn't forgot im just WAITING FOR THE ASSETS
// update febraury 3 '25: THE ASSETS ARE HERE WOOOOO -jason

/**
 * why did you left his birthday
 */
class ManIHateYouSoMuchYouMadeMuckneySad extends MusicBeatState
{
   // I got plans, and I'm gonna make the art for this lmao -don // nvm i lied :skull: -don
   var leMuckney:FlxSprite;
   var background:FlxSprite;

   // the text stuff
   var totallyEmotionalTextDisplay:FlxText;
   
   override function create() {
      super.create();

      // setup window's new functionality
      Application.current.window.borderless = true;
      Application.current.window.title = "Was it worth it?";

      DiscordClient.changePresence('You fucking monster...', 'Muckney is sad now...', 'sadmuckney', 'mouse');
      if (!Main.debug)
      {
         // haha, you have to use Task Manager to close the game on this screen now :troll:
         Lib.application.window.onClose.add(function() {
            Lib.application.window.onClose.cancel();
         });

         // bans you from playing Birthday
         GameData.muckneyLock = "uninvited";
         GameData.saveShit();
      }

      // setup screen
      var gradient:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height + 320, FlxColor.BLACK);
      gradient = FlxGradient.createGradientFlxSprite(2130, 512, [0x00FFFFFF, 0x558F8FA1, 0xAA2D2D3D], 1, 90, true);
      gradient.screenCenter();
      gradient.y += 60;
      gradient.scale.y = 1.22;
      add(gradient);

      leMuckney = new FlxSprite().loadGraphic(Paths.image("Funkin_avi/youHeartlessShit/muckneySadBoi"));
      leMuckney.setGraphicSize(0, FlxG.height);
      leMuckney.screenCenter();
      add(leMuckney);

      totallyEmotionalTextDisplay = new FlxText(0, 0, 0, "You're no longer invited back to the party...\n\n\n\n\n\n\n\n_You MONSTER..._");
      totallyEmotionalTextDisplay.setFormat(Paths.font("Oceanic_Cocktail_Demo.ttf"), 70, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
      totallyEmotionalTextDisplay.borderSize = 5;
      totallyEmotionalTextDisplay.screenCenter(X);
      totallyEmotionalTextDisplay.applyMarkup(totallyEmotionalTextDisplay.text, [new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.RED, true), "_")]);
      add(totallyEmotionalTextDisplay);
      
      var birthdayInstButSlower:FlxSound = new FlxSound().loadEmbedded(Paths.inst("Birthday", CoolUtil.difficulties[PlayState.storyDifficulty]), true);
      birthdayInstButSlower.pitch = 0.45;
      FlxG.sound.list.add(birthdayInstButSlower);
      birthdayInstButSlower.play();
   }

   override function update(e)
   {
      super.update(e);
   }
}
