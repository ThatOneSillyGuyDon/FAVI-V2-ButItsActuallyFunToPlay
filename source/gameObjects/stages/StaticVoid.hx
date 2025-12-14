package gameObjects.stages;

#if !flash 
import openfl.filters.ShaderFilter;
#end

class StaticVoid extends BaseStage {
	var staticEffect:FlxRuntimeShader = new FlxRuntimeShader(Shaders.tvStatic, null, 120);
	var blurShader:FlxRuntimeShader = new FlxRuntimeShader(Shaders.tiltShift, null, 120);
	var blurShaderHUD:FlxRuntimeShader = new FlxRuntimeShader(Shaders.tiltShift, null, 120);
	var chromZoomShader:FlxRuntimeShader = new FlxRuntimeShader(Shaders.aberration, null, 150);
	var chromNormalShader:FlxRuntimeShader = new FlxRuntimeShader(Shaders.aberrationDefault, null, 150);

	public var shaderAnim:Float = 0;
	public var blurEffect:Float = 0;
	
    var datTV:FlxSprite;
	var redGradThing:FlxSprite = new FlxSprite(-1200, 0).makeGraphic(FlxG.width, 1, 0xFFAA00AA);

    override function create() {
        game.defaultCamZoom = 0.45;	
	
		var whoaBlackBG:FlxSprite = new FlxSprite(0, 0).makeGraphic(1, 1, 0x000000);
		whoaBlackBG.scale.set(FlxG.width * 4, FlxG.height * 4);
		whoaBlackBG.screenCenter();
		add(whoaBlackBG);
	
		datTV = new FlxSprite(-250, -160);
		datTV.frames = Paths.getSparrowAtlas(PlayState.pathway + 'white');
		datTV.animation.addByPrefix('idle', 'white idle');
		datTV.animation.play('idle');
		datTV.scale.set(0.6, 0.6);
		datTV.visible = false;
		add(datTV);
	
		if(!ClientPrefs.data.lowQuality)
		{
			redGradThing = FlxGradient.createGradientFlxSprite(2130, 512, [0x00940606, 0x55BF0606, 0xAAFC0505], 1, 90, true);
			redGradThing.x = -740;
			redGradThing.y = 770;
			redGradThing.scale.y = 0;
			redGradThing.updateHitbox();
			//add(redGradThing);
		}

		if (ClientPrefs.data.shaders)
		{
			if (!ClientPrefs.data.lowQuality)
			{
				game.camGame.setFilters([
					new ShaderFilter(staticEffect),
					new ShaderFilter(blurShader),
					new ShaderFilter(chromNormalShader),
					new ShaderFilter(chromZoomShader)
				]);
				game.camHUD.setFilters([
					new ShaderFilter(blurShaderHUD),
					new ShaderFilter(chromNormalShader)
				]);
			}
			else
			{
				game.camGame.setFilters([new ShaderFilter(chromNormalShader)]);
				game.camHUD.setFilters([new ShaderFilter(chromNormalShader)]);
			}
		}
    }

	override function createPost()
	{
		game.boyfriend.visible = false;
		game.gf.visible = false;
		game.dadGroup.alpha = 0.001;
	}

	override function update(elapsed:Float)
    {
		shaderAnim = Conductor.songPosition / 1000;

		if (ClientPrefs.data.shaders)
		{
			if (ClientPrefs.data.epilepsy)
			{
				blurShader.setFloat('bluramount', blurEffect);
				blurShaderHUD.setFloat('bluramount', blurEffect * 0.72);
			}
			chromZoomShader.setFloat('aberration', game.chromEffect);
			chromZoomShader.setFloat('effectTime', game.chromEffect);
			chromNormalShader.setFloat('rOffset', game.chromEffect / 35);
			chromNormalShader.setFloat('bOffset', -game.chromEffect / 35);
			staticEffect.setFloat('uTime', shaderAnim);
			staticEffect.setFloat('iTime', shaderAnim);
		}
    }

	var blurTwn:FlxTween;

    override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
    {
        switch (eventName)
        {
			case 'Dad Tween':
				FlxTween.tween(game.dadGroup, {alpha: flValue1}, flValue2, {ease: FlxEase.circInOut});

            case "Toggle TV":
                datTV.visible = !datTV.visible;

			case 'Tween Blur':
				var triggerInfo:Array<String> = value2.split(',');
				if (ClientPrefs.data.shaders)
				{
					switch (value1.toLowerCase())
					{
						case 'tween':
							if (blurTwn != null)
								blurTwn.cancel();

							blurEffect = Std.parseFloat(triggerInfo[0]);

							blurTwn = FlxTween.tween(game, {
								chromEffect: 0.0001
							}, Std.parseFloat(triggerInfo[1]), {
								ease: FlxEase.sineOut,
								onComplete: function(twn:FlxTween)
								{
									blurTwn = null;
								}
							});
						case 'zoom':
							if (blurTwn != null)
								blurTwn.cancel();

							blurTwn = FlxTween.tween(this, {
								blurEffect: Std.parseFloat(triggerInfo[0])
							}, Std.parseFloat(triggerInfo[1]), {
								ease: FlxEase.sineOut,
								onComplete: function(twn:FlxTween)
								{
									blurTwn = null;
								}
							});
						case 'set':
							blurEffect = Std.parseFloat(triggerInfo[0]);
					}
				}
			case 'Tween Chromatic Abberation':
				var triggerInfo:Array<String> = value2.split(',');
				if (ClientPrefs.data.shaders)
				{
					switch (value1.toLowerCase())
					{
						case 'tween':
							if (game.chromTween != null)
								game.chromTween.cancel();

							game.chromEffect = Std.parseFloat(triggerInfo[0]);

							game.chromTween = FlxTween.tween(game, {
								chromEffect: 0.0001
							}, Std.parseFloat(triggerInfo[1]), {
								ease: FlxEase.sineOut,
								onComplete: function(twn:FlxTween)
								{
									game.chromTween = null;
								}
							});
						case 'zoom':
							if (game.chromTween != null)
								game.chromTween.cancel();

							game.chromTween = FlxTween.tween(game, {
								chromEffect: Std.parseFloat(triggerInfo[0])
							}, Std.parseFloat(triggerInfo[1]), {
								ease: FlxEase.sineOut,
								onComplete: function(twn:FlxTween)
								{
									game.chromTween = null;
								}
							});
						case 'set':
							game.chromEffect = Std.parseFloat(triggerInfo[0]);
					}
				}
        }
    }
}