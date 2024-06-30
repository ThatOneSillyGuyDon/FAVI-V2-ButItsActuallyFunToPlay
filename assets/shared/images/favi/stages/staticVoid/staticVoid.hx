var datTV:FlxSprite;
var redGradThing:FlxSprite = new FlxSprite(-1200, 0).makeGraphic(FlxG.width, 1, 0xFFAA00AA);

var canZoom:Bool = false;

function onCreate()
{
  	spawnGirlfriend(false);
	hideBoyfriend(true);
	
	PlayState.defaultCamZoom = 0.45;	
  
	var thePath:String = 'data/stages/staticVoid/images';

	var whoaBlackBG:FlxSprite = new FlxSprite(0, 0).makeGraphic(1, 1, 0x000000);
	whoaBlackBG.scale.set(FlxG.width * 4, FlxG.height * 4);
	whoaBlackBG.screenCenter();
	add(whoaBlackBG);

	datTV = new FlxSprite(-250, -160);
	datTV.frames = Paths.getSparrowAtlas('white', thePath);
	datTV.animation.addByPrefix('idle', 'white idle');
	datTV.animation.play('idle');
	datTV.scale.set(0.6, 0.6);
	datTV.alpha = 0.001;
	add(datTV);
	
	if(!lowQuality)
		{
			redGradThing = FlxGradient.createGradientFlxSprite(2130, 512, [0x00940606, 0x55BF0606, 0xAAFC0505], 1, 90, true);
			redGradThing.x = -740;
			redGradThing.y = 770;
			redGradThing.scale.y = 0;
			redGradThing.updateHitbox();
			//add(redGradThing);
		}
}

function onBeat(curBeat:Int, boyfriend:Character, gf:Character, dad:Character)
{
	if(curBeat == 24)
		{
			FlxTween.tween(PlayState.opponent, {alpha: 1}, 4, {ease: FlxEase.sineInOut, startDelay: 0.5});
		}

	if(curBeat == 32)
		{
			PlayState.defaultCamZoom = 0.85;
		}
	
	if (curBeat == 104)
	{
		datTV.alpha = 1;

		if(!Init.trueSettings.get('Reduced Movements'))
		canZoom = true;

		if(!Init.trueSettings.get('Disable Flashing Lights'))
		PlayState.camGame.flash(EngineTools.returnColor("white"), 1);
	}

	if(curBeat == 168)
		canZoom = false;

	if(curBeat == 232) {
		if(!Init.trueSettings.get('Reduced Movements'))
		canZoom = true;

		if(!Init.trueSettings.get('Disable Flashing Lights'))
		PlayState.camGame.flash(EngineTools.returnColor("white"), 1);
	}

	if(curBeat == 356)
		{
			PlayState.defaultCamZoom = 0.95;
		}

	if(curBeat == 360)
		{
			PlayState.defaultCamZoom = 0.85;

			if(!Init.trueSettings.get('Disable Flashing Lights'))
			PlayState.camGame.flash(EngineTools.returnColor("white"), 1);
		}

	if(curBeat == 424)
		{
			FlxTween.tween(PlayState.camHUD, {alpha: 0}, 2, {ease: FlxEase.cubeInOut});
			for(bullShit in PlayState.strumHUD)
				FlxTween.tween(bullShit, {alpha: 0}, 2.3, {ease: FlxEase.cubeInOut});
		}
	
	/*if (curBeat == 136 || curBeat == 140 || curBeat == 144 || curBeat == 148 || curBeat == 152 || curBeat == 156 || curBeat == 160 || curBeat == 164)
		if(!lowQuality && redGradThing != null)
			FlxTween.tween(redGradThing.scale, {y: 1.5}, 0.5, {ease: FlxEase.quadInOut});
	
	if (curBeat == 138 || curBeat == 142 || curBeat == 146 || curBeat == 150 || curBeat == 154 || curBeat == 158 || curBeat == 162 || curBeat == 166)
		if(!lowQuality && redGradThing != null)
			FlxTween.tween(redGradThing.scale, {y: 0}, 0.5, {ease: FlxEase.quadInOut});*/

	if(canZoom && curBeat % 1 == 0)
		{
			PlayState.camGame.zoom += 0.015;
			PlayState.camHUD.zoom += 0.04;

			for(_strumHUD in PlayState.strumHUD)
				_strumHUD.zoom += 0.04;
		}
}