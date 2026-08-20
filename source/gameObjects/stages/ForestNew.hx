package gameObjects.stages;

#if !flash 
import openfl.filters.ShaderFilter;
#end

class ForestNew extends BaseStage
{
	var wobblyBG:FlxRuntimeShader = new FlxRuntimeShader(Shaders.acidTrip, null, 120);
	var treesFront:FlxSprite;
	var goofyStreet:FlxSprite;
	var treesBack:FlxSprite;
	var otherBack:FlxSprite;
	var goofyBG:FlxSprite;

	public var shaderAnim:Float = 0;
	public static var redVignette:FlxRuntimeShader = new FlxRuntimeShader(Shaders.redFromAngryBirds, null, 120);
	public static var dramaticCamMovement:FlxRuntimeShader = new FlxRuntimeShader(Shaders.cameraMovement, null, 150);
	public static var monitorFilter:FlxRuntimeShader = new FlxRuntimeShader(Shaders.monitorFilter, null, 140);

	override function create()
	{
		if (ClientPrefs.data.shaders)
		{
			// Literally what Goofy is seeing right about now lmfao
			wobblyBG.setFloat('uSpeed', 1.0);
			wobblyBG.setFloat('uFrequency', 1.0);
			wobblyBG.setFloat('uWaveAmplitude', 0.5);
		}

		game.cameraSpeed = 0.9;
		game.defaultCamZoom = 0.65;
		PlayState.isGreyscale = true;

		treesBack = new FlxSprite(-600, -450).loadGraphic(Paths.image(PlayState.pathway + 'actualNew/treesBG'));
		treesBack.scrollFactor.set(1, 0.8);
		add(treesBack);

		goofyStreet = new FlxSprite(-600, -450).loadGraphic(Paths.image(PlayState.pathway + 'actualNew/road'));
		goofyStreet.scrollFactor.set(1, 1);
		add(goofyStreet);

		if(!ClientPrefs.data.lowQuality)
		{
			treesFront = new FlxSprite(-600, -450).loadGraphic(Paths.image(PlayState.pathway + 'actualNew/treesFG'));
			treesFront.scrollFactor.set(1.2, 1.2);
		}

		for (item in [treesBack,goofyStreet,treesFront]){
			item.scale.set(1.25,1.25);
		}

		var bgShi:FlxSprite = new FlxSprite().makeGraphic(1280,720,FlxColor.BLACK);
		add(bgShi);
		bgShi.cameras = [camOther];
		FlxTween.tween(bgShi, {alpha:0},6, {startDelay:2.5, onComplete: function(_:FlxTween){
			remove(bgShi);
		}});

	}
	
	override function createPost()
	{
		if (ClientPrefs.data.shaders)
		{
			if (!ClientPrefs.data.lowQuality)
			{
				camGame.setFilters([
					new ShaderFilter(dramaticCamMovement),
					new ShaderFilter(monitorFilter),
				]);
			}
			else
			{
				camGame.setFilters([new ShaderFilter(monitorFilter)]);
			}
		}
		add(treesFront);

		game.dad.setPosition(-110, 70); // goofy ahh goofy offsets - malyplus
		game.boyfriend.setPosition(630, -155);
		game.gf.setPosition(320, 15);

		
	}

	override function update(elapsed:Float)
	{
		if (ClientPrefs.data.shaders)
		{
			shaderAnim = Conductor.songPosition / 1000;
			
			wobblyBG.setFloat('uTime', shaderAnim);
			redVignette.setFloat('time', shaderAnim);
			dramaticCamMovement.setFloat('time', shaderAnim);
		}
	}

	// For events
	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case 'Trigger Hunted Stuffs':
				switch (value1.toLowerCase())
				{
					case 'weeblewobble':
						//camHudMoves = true;
						if (ClientPrefs.data.flashing)
							camGame.flash(FlxColor.WHITE, 1.5);
						if (ClientPrefs.data.shaders)
						{
							if (!ClientPrefs.data.lowQuality)
							{
								camGame.setFilters([
									new ShaderFilter(redVignette),
									new ShaderFilter(dramaticCamMovement),
									new ShaderFilter(monitorFilter),
								]);
							}
							else
							{
								camGame.setFilters([new ShaderFilter(redVignette), new ShaderFilter(monitorFilter)]);
							}

							if(!ClientPrefs.data.lowQuality && treesFront != null)
							{
								//goofyBG.shader = wobblyBG;
								goofyStreet.shader = wobblyBG;
								treesBack.shader = wobblyBG;
								treesFront.shader = wobblyBG;
							}
						}
					case 'no more weeblewobble':
						game.camBars.flash(FlxColor.BLACK, 2);
						if (ClientPrefs.data.shaders)
						{
							if (!ClientPrefs.data.lowQuality)
							{
								camGame.setFilters([
									new ShaderFilter(dramaticCamMovement),
									new ShaderFilter(monitorFilter),
								]);
							}
							else
							{
								camGame.setFilters([new ShaderFilter(monitorFilter)]);
							}
						}

						if(!ClientPrefs.data.lowQuality && treesFront != null)
						{
							//goofyBG.shader = null;
							goofyStreet.shader = null;
							treesBack.shader = null;
							treesFront.shader = null;
						}
				}
		}
	}
}