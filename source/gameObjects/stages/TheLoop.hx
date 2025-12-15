package gameObjects.stages;

#if !flash 
import openfl.filters.ShaderFilter;
#end
import openfl.Lib;

class TheLoop extends BaseStage
{
	public static var grayScale:FlxRuntimeShader = new FlxRuntimeShader(Shaders.grayScale, null, 120);
	public static var legacyChrom:FlxRuntimeShader = new FlxRuntimeShader(LegacyShaders.chromaticAberration, null, 120);
	public static var legacyDistort:FlxRuntimeShader = new FlxRuntimeShader(LegacyShaders.vcrDistortion, null, 120);
	public static var legacyDefaultDistort:FlxRuntimeShader = new FlxRuntimeShader(LegacyShaders.vcrDistortion, null, 120);
	public static var legacyTiltshift:FlxRuntimeShader = new FlxRuntimeShader(LegacyShaders.tiltshift, null, 120);
	public static var legacyTiltshiftHUD:FlxRuntimeShader = new FlxRuntimeShader(LegacyShaders.tiltshift, null, 120);
	public static var legacyGreyscale:FlxRuntimeShader = new FlxRuntimeShader(LegacyShaders.greyscale, null, 120);

	public var shaderAnim:Float = 0;

	public var waltScreenThing:FlxSprite; // idk, this is needed too for some reason

	override function create()
	{
		game.defaultCamZoom = 0.85;
		PlayState.isGreyscale = true;
				
		var street:FlxSprite = new FlxSprite(-500, -700).loadGraphic(Paths.image(PlayState.pathway + 'Mickeybg'));
		add(street);
	
		if(!ClientPrefs.data.lowQuality)
		{
			var grainstuff:FlxSprite = new FlxSprite(0, 0);
			grainstuff.frames = Paths.getSparrowAtlas('favi/filters/Grainshit');
			grainstuff.animation.addByPrefix('yucky', 'grains 1', 24, true);
			grainstuff.animation.play('yucky');
			grainstuff.cameras = [camHUD];
			grainstuff.scale.set(3, 3);
			grainstuff.screenCenter();
			add(grainstuff);
		}
	}
	
	override function createPost()
	{
		game.gf.visible = false;

		if (ClientPrefs.data.shaders)
		{
			switch (PlayState.SONG.song)
			{
				case 'Isolated Old' | 'Isolated Legacy' | 'Isolated Beta' | 'Lunacy Legacy' | 'Delusional Legacy':
					for (sigmas in ['r', 'g', 'b']) legacyChrom.setFloat('${sigmas}Offset', 0.005);

					legacyDistort.setFloat('glitchModifier', 1);
					legacyDistort.setFloat('iTime', 0);
					legacyDistort.setBool('perspectiveOn', true);
					legacyDistort.setBool('vignetteMoving', true);
					legacyDistort.setBool('scanlinesOn', true);
					legacyDistort.setBool('vignetteOn', true);
					legacyDistort.setBool('distortionOn', false);
					legacyDistort.setFloatArray('iResolution', [Lib.current.stage.stageWidth, Lib.current.stage.stageHeight]);

					legacyDefaultDistort.setFloat('glitchModifier', 0);
					legacyDefaultDistort.setFloat('iTime', 0);
					legacyDefaultDistort.setBool('perspectiveOn', true);
					legacyDefaultDistort.setBool('vignetteMoving', true);
					legacyDefaultDistort.setBool('scanlinesOn', true);
					legacyDefaultDistort.setBool('vignetteOn', true);
					legacyDefaultDistort.setBool('distortionOn', true);
					legacyDefaultDistort.setFloatArray('iResolution', [Lib.current.stage.stageWidth, Lib.current.stage.stageHeight]);

					legacyTiltshift.setFloat('bluramount', .5);
					legacyTiltshiftHUD.setFloat('bluramount', .6);

					legacyTiltshift.setFloat('center', 0);
					legacyTiltshiftHUD.setFloat('center', 0);

					if (!ClientPrefs.data.lowQuality)
					{
						camGame.setFilters([
							new ShaderFilter(legacyChrom),
							new ShaderFilter(legacyDistort),
							new ShaderFilter(legacyGreyscale),
						]);
						
						camHUD.setFilters([
							new ShaderFilter(legacyChrom),
							new ShaderFilter(legacyDefaultDistort),
							new ShaderFilter(legacyTiltshiftHUD),
							new ShaderFilter(legacyGreyscale),
						]);
					}
					else
					{
						camGame.setFilters([new ShaderFilter(grayScale)]);
						camHUD.setFilters([new ShaderFilter(grayScale)]);
					}
			}
		}

		waltScreenThing = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		waltScreenThing.scrollFactor.set();
		waltScreenThing.cameras = [camOther];
		waltScreenThing.alpha = 0.001;

		if (PlayState.SONG.song == "Delusional Legacy")
				add(waltScreenThing);
	}

	override function update(elapsed:Float)
	{
		game.dad.setPosition(0, 0);
		if (game.boyfriend.curCharacter == 'bf')
		{
			game.boyfriend.setPosition(1000, 130);
		}else{
			game.boyfriend.setPosition(500, -320);
		}
		
		shaderAnim = Conductor.songPosition / 1000;

		if (ClientPrefs.data.shaders)
		{
			switch(PlayState.SONG.song)
			{
				case 'Isolated Beta' | 'Isolated Legacy' | 'Isolated Old' | 'Lunacy Legacy' | 'Delusional Legacy':
					legacyDistort.setFloat('iTime', shaderAnim);
					legacyDistort.setFloatArray('iResolution', [Lib.current.stage.stageWidth, Lib.current.stage.stageHeight]);

					legacyDefaultDistort.setFloat('iTime', shaderAnim);
					legacyDefaultDistort.setFloatArray('iResolution', [Lib.current.stage.stageWidth, Lib.current.stage.stageHeight]);
			}
		}
	}
	
	// For events
	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case 'Change Screen Dimming':
				var triggerInfo:Array<String> = value1.split(',');
				FlxTween.tween(waltScreenThing, {alpha: Std.parseFloat(triggerInfo[0])}, Std.parseFloat(triggerInfo[1]), {ease: returnTweenEase(value2)});
		}
	}

	public static function returnTweenEase(ease:String = '')
	{
		switch (ease.toLowerCase())
		{
			case 'linear':
				return FlxEase.linear;
			case 'backin':
				return FlxEase.backIn;
			case 'backinout':
				return FlxEase.backInOut;
			case 'backout':
				return FlxEase.backOut;
			case 'bouncein':
				return FlxEase.bounceIn;
			case 'bounceinout':
				return FlxEase.bounceInOut;
			case 'bounceout':
				return FlxEase.bounceOut;
			case 'circin':
				return FlxEase.circIn;
			case 'circinout':
				return FlxEase.circInOut;
			case 'circout':
				return FlxEase.circOut;
			case 'cubein':
				return FlxEase.cubeIn;
			case 'cubeinout':
				return FlxEase.cubeInOut;
			case 'cubeout':
				return FlxEase.cubeOut;
			case 'elasticin':
				return FlxEase.elasticIn;
			case 'elasticinout':
				return FlxEase.elasticInOut;
			case 'elasticout':
				return FlxEase.elasticOut;
			case 'expoin':
				return FlxEase.expoIn;
			case 'expoinout':
				return FlxEase.expoInOut;
			case 'expoout':
				return FlxEase.expoOut;
			case 'quadin':
				return FlxEase.quadIn;
			case 'quadinout':
				return FlxEase.quadInOut;
			case 'quadout':
				return FlxEase.quadOut;
			case 'quartin':
				return FlxEase.quartIn;
			case 'quartinout':
				return FlxEase.quartInOut;
			case 'quartout':
				return FlxEase.quartOut;
			case 'quintin':
				return FlxEase.quintIn;
			case 'quintinout':
				return FlxEase.quintInOut;
			case 'quintout':
				return FlxEase.quintOut;
			case 'sinein':
				return FlxEase.sineIn;
			case 'sineinout':
				return FlxEase.sineInOut;
			case 'sineout':
				return FlxEase.sineOut;
			case 'smoothstepin':
				return FlxEase.smoothStepIn;
			case 'smoothstepinout':
				return FlxEase.smoothStepInOut;
			case 'smoothstepout':
				return FlxEase.smoothStepInOut;
			case 'smootherstepin':
				return FlxEase.smootherStepIn;
			case 'smootherstepinout':
				return FlxEase.smootherStepInOut;
			case 'smootherstepout':
				return FlxEase.smootherStepOut;
		}
		return FlxEase.linear;
	}
}