package states.stages.legacyStages;

#if !flash 
import openfl.filters.ShaderFilter;
#end

class LegForest extends BaseStage
{

	public static var grayScale:FlxRuntimeShader = new FlxRuntimeShader(Shaders.grayScale, null, 120);
	public static var blurShader:FlxRuntimeShader = new FlxRuntimeShader(Shaders.tiltShift, null, 120);
	public static var blurShaderHUD:FlxRuntimeShader = new FlxRuntimeShader(Shaders.tiltShift, null, 120);
	public static var andromeda:FlxRuntimeShader = new FlxRuntimeShader(Shaders.andromedaVCR, null, 140);

	public var shaderAnim:Float = 0;

	override function create()
	{
		var forest:FlxSprite = new FlxSprite(-180, -350).loadGraphic(Paths.image('favi/stages/forestOld/forest'));
		add(forest);
	}
	
	override function createPost()
	{
		blurShader.setFloat('bluramount', 0.6);
		blurShaderHUD.setFloat('bluramount', 0.1);
		andromeda.setFloat('glitchModifier', 0.2);
		andromeda.setBool('perspectiveOn', true);
		andromeda.setBool('vignetteMoving', true);
		if (!ClientPrefs.data.lowQuality)
		{
			camGame.setFilters([
				new ShaderFilter(grayScale),
				new ShaderFilter(blurShader),
			]);
			camHUD.setFilters([
				new ShaderFilter(grayScale),
				new ShaderFilter(blurShaderHUD),
				new ShaderFilter(andromeda)
			]);
		}
		else
		{
			camGame.setFilters([new ShaderFilter(grayScale)]);
			camHUD.setFilters([new ShaderFilter(grayScale)]);
		}

		game.dad.setPosition(0, 0);
    	game.boyfriend.setPosition(900, -20);
		game.gf.visible = false;
	}

	override function update(elapsed:Float)
	{
		// Code here
	}

	
	override function countdownTick(count:BaseStage.Countdown, num:Int)
	{
		switch(count)
		{
			case THREE: //num 0
			case TWO: //num 1
			case ONE: //num 2
			case GO: //num 3
			case START: //num 4
		}
	}

	// Steps, Beats and Sections:
	//    curStep, curDecStep
	//    curBeat, curDecBeat
	//    curSection
	override function stepHit()
	{
		// Code here
	}
	override function beatHit()
	{
		// Code here
	}
	override function sectionHit()
	{
		// Code here
	}

	// Substates for pausing/resuming tweens and timers
	override function closeSubState()
	{
		if(paused)
		{
			//timer.active = true;
			//tween.active = true;
		}
	}

	override function openSubState(SubState:flixel.FlxSubState)
	{
		if(paused)
		{
			//timer.active = false;
			//tween.active = false;
		}
	}

	// For events
	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case "My Event":
		}
	}
	override function eventPushed(event:objects.Note.EventNote)
	{
		// used for preloading assets used on events that doesn't need different assets based on its values
		switch(event.event)
		{
			case "My Event":
				//precacheImage('myImage') //preloads images/myImage.png
				//precacheSound('mySound') //preloads sounds/mySound.ogg
				//precacheMusic('myMusic') //preloads music/myMusic.ogg
		}
	}
	override function eventPushedUnique(event:objects.Note.EventNote)
	{
		// used for preloading assets used on events where its values affect what assets should be preloaded
		switch(event.event)
		{
			case "My Event":
				switch(event.value1)
				{
					// If value 1 is "blah blah", it will preload these assets:
					case 'blah blah':
						//precacheImage('myImageOne') //preloads images/myImageOne.png
						//precacheSound('mySoundOne') //preloads sounds/mySoundOne.ogg
						//precacheMusic('myMusicOne') //preloads music/myMusicOne.ogg

					// If value 1 is "coolswag", it will preload these assets:
					case 'coolswag':
						//precacheImage('myImageTwo') //preloads images/myImageTwo.png
						//precacheSound('mySoundTwo') //preloads sounds/mySoundTwo.ogg
						//precacheMusic('myMusicTwo') //preloads music/myMusicTwo.ogg
					
					// If value 1 is not "blah blah" or "coolswag", it will preload these assets:
					default:
						//precacheImage('myImageThree') //preloads images/myImageThree.png
						//precacheSound('mySoundThree') //preloads sounds/mySoundThree.ogg
						//precacheMusic('myMusicThree') //preloads music/myMusicThree.ogg
				}
		}
	}
}