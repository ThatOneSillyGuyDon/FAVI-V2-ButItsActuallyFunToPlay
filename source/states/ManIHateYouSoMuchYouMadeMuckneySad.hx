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

   // the text stuff
   var totallyEmotionalTextDisplay:FlxText;
   
   override function create() {
      super.create();

      // setup window's new functionality
      Application.current.window.borderless = true;
      Application.current.window.title = "Was it worth it?";

      // haha, you have to use Task Manager to close the game on this screen now :troll:
      Lib.application.window.onClose.add(function() {
			Lib.application.window.onClose.cancel();
		});

      DiscordClient.changePresence('You fucking monster...', 'Muckney is sad now...', 'sadmuckney', 'mouse');

      // bans you from playing Birthday
      GameData.birthdayLocky = "uninvited";
      GameData.saveShit();

      // setup screen
      var gradient:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height + 320, FlxColor.BLACK);
      gradient = FlxGradient.createGradientFlxSprite(2130, 512, [0x00FFFFFF, 0x558FA197, 0xAA2D3D33], 1, 90, true);
      gradient.screenCenter();
      gradient.y += 60;
      gradient.scale.y = 1.22;
      add(gradient);

      leMuckney = new FlxSprite().loadGraphic(Paths.image("Funkin_avi/youHeartlessShit/muckneySadBoi"));
      leMuckney.setGraphicSize(0, FlxG.height);
      leMuckney.screenCenter();
      add(leMuckney);

      totallyEmotionalTextDisplay = new FlxText(0, 0, 500, "You're no longer invited back to the party,\nyou monster...");
      totallyEmotionalTextDisplay.setFormat(Paths.font("DisneyFont.ttf"), 70, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
      totallyEmotionalTextDisplay.borderSize = 5;
      add(totallyEmotionalTextDisplay);
      
      var birthdayInstButSlower:FlxSound = new FlxSound().loadEmbedded(Paths.music("aviOST/aTrueMonster"));
      FlxG.sound.list.add(birthdayInstButSlower);
      birthdayInstButSlower.play();
   }

   override function update(e)
      {
         super.update(e);
      }
}