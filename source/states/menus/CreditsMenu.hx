package states.menus;

import haxe.Json;
import base.dependency.Discord;
import base.song.Conductor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.text.FlxText;
import flixel.tweens.*;
import flixel.util.FlxColor;
import openfl.filters.ShaderFilter;
import sys.io.File;
/** Credit shit or smth !!

How it Works:

* [Name of Contributor, Icon, Work They've Done, Description/Quote, X Value of Icon, Y Value of Icon, Size of Icon, Bool for in case someone has a stupidly long description]
*/
typedef CreditStuff = {
	devs:Array<Dynamic>
}

class CreditsMenu extends MusicBeatState
{
	public static var creditArray:Array<Dynamic>;

	var curSelected:Int = 0;

	var creditIconSprite:FlxSprite;
	var creditDescText:FlxText;
	var creditNameText:FlxText;
	var creditWorkText:FlxText;
	var backdrop:FlxBackdrop;
	var background:FlxSprite;
	var box:FlxSprite;
	var daStrip:FlxSprite;
	var creditIconText:FlxSprite;

	var cool_1980_shader:FlxRuntimeShader;

	var maxLength = 1;

	var path:String;

	var daJson:String = null;
	var creditThing:CreditStuff;

	override function create()
	{
		FlxG.stage.window.title = "Funkin.avi - Credits";

		path = 'menus/Funkin_avi/credits';

		#if DISCORD_RPC
		Discord.changePresence('BROWSING THE CREDITS', 'Credits Menu', 'icon', 'book');
		#end

		FlxG.sound.playMusic(Paths.music('funkinAVI/credits'));

		Conductor.changeBPM(164);

		creditThing = jsonStuff();
		creditArray = creditThing.devs;

		background = new FlxSprite().loadGraphic(Paths.image('$path/background'));
		background.screenCenter();
		add(background);

		// thank you shadow mario fnf
		backdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0xFFFFFF, 0x33FFFFFF));
		backdrop.velocity.set(40, 40);
		backdrop.alpha = 0;
		backdrop.setGraphicSize(Std.int(backdrop.width * 0.6));
		FlxTween.tween(backdrop, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
		add(backdrop);

		daStrip = new FlxSprite().loadGraphic(Paths.image('$path/filmstrip'));
		daStrip.screenCenter();
		daStrip.setGraphicSize(Std.int(daStrip.width * 0.8));
		add(daStrip);

		box = new FlxSprite().loadGraphic(Paths.image('$path/box'));
		box.screenCenter().x -= 80;
		box.setGraphicSize(Std.int(box.width * 0.6));
		add(box);

		creditDescText = new FlxText(FlxG.width * 0.52, FlxG.height * 0.6, 500, creditArray[curSelected][3]);
		creditDescText.setFormat(Paths.font('vcr'), 40, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		creditDescText.borderSize = 1.3;
		add(creditDescText);

		creditNameText = new FlxText(FlxG.width * 0.22, FlxG.height * 0.3, FlxG.width, creditArray[curSelected][0]);
		creditNameText.setFormat(Paths.font('vcr'), 70, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		creditNameText.borderSize = 1.3;
		add(creditNameText);

		creditWorkText = new FlxText(FlxG.width * 0.52, FlxG.height * 0.41, 500, creditArray[curSelected][2]);
		creditWorkText.setFormat(Paths.font('vcr'), 30, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		creditWorkText.borderSize = 1.3;
		add(creditWorkText);

		creditIconSprite = new FlxSprite(creditArray[curSelected][4],
			creditArray[curSelected][5]).loadGraphic(Paths.image('$path/icons/${creditArray[curSelected][1]}'));
		creditIconSprite.setGraphicSize(Std.int(creditIconSprite.width * creditArray[curSelected][6]));
		add(creditIconSprite);

		super.create();

		cool_1980_shader = new FlxRuntimeShader(Shaders.filter1990, null, 140);

		if (!Init.trueSettings.get('Disable Screen Shaders'))
			FlxG.camera.setFilters([
				new ShaderFilter(cool_1980_shader),
				new ShaderFilter(new FlxRuntimeShader(Shaders.monitorFilter, null, 140))
			]);

		if (!Init.trueSettings.get('Low Quality'))
		{
			var scratchStuff:FlxSprite = new FlxSprite();
			scratchStuff.frames = Paths.getSparrowAtlas('filters/scratchShit');
			scratchStuff.animation.addByPrefix('idle', 'scratch thing 1', 24, true);
			scratchStuff.animation.play('idle');
			scratchStuff.screenCenter();
			scratchStuff.scale.x = 1.1;
			scratchStuff.scale.y = 1.1;
			add(scratchStuff);

			var grain:FlxSprite = new FlxSprite();
			grain.frames = Paths.getSparrowAtlas('filters/Grainshit');
			grain.animation.addByPrefix('idle', 'grains 1', 24, true);
			grain.animation.play('idle');
			grain.screenCenter();
			grain.scale.x = 1.1;
			grain.scale.y = 1.1;
			add(grain);
		}

		changeSelection(0);
	}

	var shaderTime:Float = 0;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		shaderTime = Conductor.songPosition / 1000;

		if (!Init.trueSettings.get('Disable Screen Shaders'))
		{
			cool_1980_shader.setFloat('iTime', shaderTime);
		}

		EngineTools.cameraBumpingZooms(FlxG.camera, 1, null, elapsed);

		if (Controls.justPressed("ui_up"))
		{
			changeSelection(-1);
		}
		else if (Controls.justPressed("ui_down"))
		{
			changeSelection(1);
		}

		if (Controls.justPressed("back"))
		{
			Main.switchState(this, new MainMenu());
			Conductor.changeBPM(50); // changes back to titlescreen bpm
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 1); // resets music back to menu music
			FlxG.sound.music.fadeIn();
		}
	}

	override function destroy()
	{
		super.destroy();

		EngineTools.resetMenuMusic();
	}

	function jsonStuff()
	{
		daJson = File.getContent(Paths.getPath('data/credits.json', TEXT, null));

		if (daJson != null && daJson.length > 0) {
			return cast Json.parse(daJson);
		}

		return null;
	}

	private function changeSelection(newSelect:Int = 0)
	{
		curSelected += newSelect;
		if (curSelected < 0)
			curSelected = creditArray.length - 1;
		if (curSelected >= creditArray.length)
			curSelected = 0;

		creditNameText.text = creditArray[curSelected][0] != null ? creditArray[curSelected][0] : 'unknown';
		creditDescText.text = creditArray[curSelected][3] != null ? creditArray[curSelected][3] : 'unknown';
		creditWorkText.text = creditArray[curSelected][2] != null ? creditArray[curSelected][2] : 'has not worked';
		creditIconSprite.loadGraphic(Paths.image('$path/icons/${creditArray[curSelected][1]}'));
		creditIconSprite.setGraphicSize(Std.int(creditIconSprite.width * creditArray[curSelected][6]));
		creditIconSprite.setPosition(creditArray[curSelected][4], creditArray[curSelected][5]);

		FlxG.sound.play(Paths.sound('base/menus/scrollMenu'), 0.6);

		reloadText(creditArray[curSelected][7]);

		trace('huh: credits edition');
	}

	@:noCompletion
	private function reloadText(long)
	{
		if (long)
		{
			switch (creditArray[curSelected][0].toLowerCase())
			{
				case 'domingo' | 'retrojogador':
					creditNameText.y = FlxG.height * 0.1;
					creditWorkText.y = FlxG.height * 0.21;
					creditDescText.fieldWidth = 1000;
					creditDescText.x = FlxG.width * 0.32;
					creditDescText.y = FlxG.height * 0.195;
					creditDescText.scale.set(0.6, 0.6);

				case 'writer anon':
					creditNameText.y = FlxG.height * 0.1;
					creditWorkText.y = FlxG.height * 0.21;
					creditDescText.fieldWidth = 1000;
					creditDescText.x = FlxG.width * 0.32;
					creditDescText.y = FlxG.height * 0.2;
					creditDescText.scale.set(0.6, 0.6);

				default:
					creditNameText.y = FlxG.height * 0.1;
					creditWorkText.y = FlxG.height * 0.21;
					creditDescText.fieldWidth = 1000;
					creditDescText.x = FlxG.width * 0.32;
					creditDescText.y = FlxG.height * 0.16;
					creditDescText.scale.set(0.6, 0.6);
			}
		}
		else
		{ // reload reasons
			switch (creditArray[curSelected][0].toLowerCase())
			{
				case 'hanacat':
					creditDescText.fieldWidth = 500;
					creditDescText.x = FlxG.width * 0.52;
					creditDescText.y = FlxG.height * 0.46;
					creditDescText.scale.set(1, 1);
					creditNameText.y = FlxG.height * 0.3;
					creditWorkText.y = FlxG.height * 0.41;
					creditDescText.scale.set(0.8, 0.8);
				default:
					creditDescText.fieldWidth = 500;
					creditDescText.x = FlxG.width * 0.52;
					creditDescText.y = FlxG.height * 0.6;
					creditDescText.scale.set(1, 1);
					creditNameText.y = FlxG.height * 0.3;
					creditWorkText.y = FlxG.height * 0.41;
			}
		}
	}
}
