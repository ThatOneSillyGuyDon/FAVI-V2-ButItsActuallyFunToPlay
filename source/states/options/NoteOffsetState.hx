package states.options;

import backend.data.StageData;
import gameObjects.Character;
import gameObjects.ui.Bar;
import flixel.addons.display.shapes.FlxShapeCircle;

#if !flash 
import openfl.filters.ShaderFilter;
#end

import states.options.backend.LilStage as BackgroundStage;

class NoteOffsetState extends MusicBeatState
{
	var littleBitch:Character;
	var mickey:Character;

	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;

	var barPercent:Float = 0;
	var delayMin:Int = -500;
	var delayMax:Int = 500;
	var offsetBar:Bar;
	var offsetTxt:FlxText;
	var beatText:Alphabet;
	var beatTween:FlxTween;

	var changeModeText:FlxText;

	public var scratch:FlxSprite; // Peter Griffin: This reminds me of the time I met the Scratch cat
	public var scratchButLessVisible:FlxSprite;

	//Shader stuff
	public static var chromZoomShader:FlxRuntimeShader = new FlxRuntimeShader(Shaders.aberration, null, 150);
	public static var chromNormalShader:FlxRuntimeShader = new FlxRuntimeShader(Shaders.aberrationDefault, null, 150);
	public static var dramaticCamMovement:FlxRuntimeShader = new FlxRuntimeShader(Shaders.cameraMovement, null, 150);
	public static var monitorFilter:FlxRuntimeShader = new FlxRuntimeShader(Shaders.monitorFilter, null, 140);
	public static var grayScale:FlxRuntimeShader = new FlxRuntimeShader(Shaders.grayScale, null, 120);

	public var shaderAnim:Float = 0;

	override public function create()
	{
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Note Offset Menu", "Changing settings...", "icon", "gear");
		#end

		// Cameras
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camOther, false);

		FlxG.cameras.setDefaultDrawTarget(camGame, true);
		
		FlxG.camera.scroll.set(-250, 130);
		FlxG.camera.zoom = 0.75;

		persistentUpdate = true;
		FlxG.sound.pause();

		new BackgroundStage();

		// Characters
		mickey = new Character(0, 0, 'mickey-FINAL-HOLYSHI');
		littleBitch = new Character(0, 0, 'bf-fake-new', true);
		mickey.setPosition(-870, -190);
		littleBitch.setPosition(275, 50);
		add(mickey);
		add(littleBitch);

		// Note delay stuff
		beatText = new Alphabet(0, 0, 'Beat Hit!', true);
		beatText.setScale(0.6, 0.6);
		beatText.x += 260;
		beatText.alpha = 0;
		beatText.acceleration.y = 250;
		add(beatText);
		
		offsetTxt = new FlxText(0, 600, FlxG.width, "", 32);
		offsetTxt.setFormat(Paths.font("VanillaExtractRegular.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		offsetTxt.scrollFactor.set();
		offsetTxt.borderSize = 2;
		offsetTxt.cameras = [camHUD];

		barPercent = ClientPrefs.data.noteOffset;
		updateNoteDelay();
		
		offsetBar = new Bar(0, offsetTxt.y + (offsetTxt.height / 3), 'healthBar', function() return barPercent, delayMin, delayMax);
		offsetBar.scrollFactor.set();
		offsetBar.screenCenter(X);
		offsetBar.cameras = [camHUD];
		offsetBar.setColors(FlxColor.WHITE, FlxColor.BLACK);

		add(offsetBar);
		add(offsetTxt);

		///////////////////////

		var blackBox:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 40, FlxColor.BLACK);
		blackBox.scrollFactor.set();
		blackBox.alpha = 0.6;
		blackBox.cameras = [camHUD];
		add(blackBox);

		changeModeText = new FlxText(0, 4, FlxG.width, "Note Offset Menu", 32);
		changeModeText.setFormat(Paths.font("VanillaExtractRegular.ttf"), 32, FlxColor.WHITE, CENTER);
		changeModeText.scrollFactor.set();
		changeModeText.cameras = [camHUD];
		add(changeModeText);
		
		Conductor.bpm = 128.0;
		FlxG.sound.playMusic(Paths.music('offsetSong'), 1, true);

		if (ClientPrefs.data.shaders)
		{
			if (!ClientPrefs.data.lowQuality)
			{
				camGame.setFilters([
					new ShaderFilter(dramaticCamMovement),
					new ShaderFilter(monitorFilter),
					new ShaderFilter(chromZoomShader),
					new ShaderFilter(chromNormalShader)
				]);
				camHUD.setFilters([new ShaderFilter(chromNormalShader)]);
			}
			else
			{
				camGame.setFilters([
					new ShaderFilter(monitorFilter),
					new ShaderFilter(chromNormalShader)
				]);
				camHUD.setFilters([new ShaderFilter(chromNormalShader)]);
			}
		}

		super.create();

		stagesFunc(function(stage:BaseStage) stage.createPost());

		scratch = new FlxSprite();
		scratch.frames = Paths.getSparrowAtlas('favi/filters/scratchShit');
		scratch.animation.addByPrefix('e', 'scratch thing', 24, true);
		scratch.animation.play('e');
		scratch.cameras = [camOther];
		add(scratch);
	}

	var holdTime:Float = 0;
	var holdingObjectType:Null<Bool> = null;

	var startMousePos:FlxPoint = new FlxPoint();

	override public function update(elapsed:Float)
	{
		var addNum:Int = 1;
		if(FlxG.keys.pressed.SHIFT || FlxG.gamepads.anyPressed(LEFT_SHOULDER))
		{
			addNum = 3;
		}

		if(controls.UI_LEFT_P)
		{
			barPercent = Math.max(delayMin, Math.min(ClientPrefs.data.noteOffset - 1, delayMax));
			updateNoteDelay();
		}
		else if(controls.UI_RIGHT_P)
		{
			barPercent = Math.max(delayMin, Math.min(ClientPrefs.data.noteOffset + 1, delayMax));
			updateNoteDelay();
		}

		var mult:Int = 1;
		if(controls.UI_LEFT || controls.UI_RIGHT)
		{
			holdTime += elapsed;
			if(controls.UI_LEFT) mult = -1;
		}

		if(controls.UI_LEFT_R || controls.UI_RIGHT_R) holdTime = 0;

		if(holdTime > 0.5)
		{
			barPercent += 100 * addNum * elapsed * mult;
			barPercent = Math.max(delayMin, Math.min(barPercent, delayMax));
			updateNoteDelay();
		}

		if(controls.RESET)
		{
			holdTime = 0;
			barPercent = 0;
			updateNoteDelay();
		}

		if(controls.BACK)
		{
			if(beatTween != null) beatTween.cancel();

			persistentUpdate = false;
			Conductor.bpm = 50;
			MusicBeatState.switchState(new OptionsState());
			FlxG.sound.playMusic(Paths.music('aviOST/rottenPetals'));
			FlxG.mouse.visible = false;
		}

		Conductor.songPosition = FlxG.sound.music.time;
		super.update(elapsed);

		FlxG.camera.zoom = FlxMath.lerp(0.75, FlxG.camera.zoom, Math.exp(-elapsed * 3.125));

		shaderAnim = Conductor.songPosition / 1000;
		
		if (ClientPrefs.data.shaders)
		{
			chromZoomShader.setFloat('aberration', 0.0001);
			chromZoomShader.setFloat('effectTime', 0.0001);
			chromNormalShader.setFloat('rOffset', 0.0001 / 45);
			chromNormalShader.setFloat('bOffset', -0.0001 / 45);
			dramaticCamMovement.setFloat('time', shaderAnim);
		}
	}

	var lastBeatHit:Int = -1;
	override public function beatHit()
	{
		super.beatHit();

		if(lastBeatHit == curBeat)
		{
			return;
		}

		if(curBeat % 2 == 0)
		{
			littleBitch.dance();
			mickey.dance();
		}
		
		if(curBeat % 4 == 2)
		{
			FlxG.camera.zoom += 0.15;

			beatText.alpha = 1;
			beatText.y = 320;
			beatText.velocity.y = -150;
			if(beatTween != null) beatTween.cancel();
			beatTween = FlxTween.tween(beatText, {alpha: 0}, 1, {ease: FlxEase.sineIn, onComplete: function(twn:FlxTween)
				{
					beatTween = null;
				}
			});
		}

		lastBeatHit = curBeat;
	}

	function updateNoteDelay()
	{
		ClientPrefs.data.noteOffset = Math.round(barPercent);
		offsetTxt.text = 'Current offset: ' + Math.floor(barPercent) + ' ms';
	}
}
