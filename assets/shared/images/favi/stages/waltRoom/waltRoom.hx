var pissOfGlory:FNFSprite;
var greaterPiss:FNFSprite;

function onCreate()
{
	spawnGirlfriend(false);
	hideBoyfriend(true);
	
	PlayState.health = 1; // Hardcoding it breaks for some reason
	
	//PlayState.boyfriend.alpha = 0; //This crashes the game cause apparently, Character.hx doesn't have an "alpha" value.
	PlayState.defaultCamZoom = 0.75;

	if (PlayState.SONG.song == 'Mercy')
	{
		PlayState.camGame.alpha = 0;
		PlayState.camHUD.alpha = 0;
		//PlayState.dadStrums.visible = false;

		pissOfGlory = new FNFSprite(-470, -280);
		pissOfGlory.loadGraphic(Paths.image('newWaltBG', 'data/stages/waltRoom/images'));
		pissOfGlory.scale.set(1.7, 1.7);
	}else{
		pissOfGlory = new FNFSprite(-450, -300);
		pissOfGlory.loadGraphic(Paths.image('walt-bg', 'data/stages/waltRoom/images'));
		pissOfGlory.scale.set(1, 1);
	}
	pissOfGlory.updateHitbox();
	pissOfGlory.antialiasing = true;
	pissOfGlory.scrollFactor(1, 1);
	pissOfGlory.active = false;
	add(pissOfGlory);

	greaterPiss = new FNFSprite(-60, -70);
	greaterPiss.loadGraphic(Paths.image('inkWaltBG', 'data/stages/waltRoom/images'));
	greaterPiss.scale.set(1.7, 1.7);
	greaterPiss.alpha = 0;
	add(greaterPiss);

	if(!lowQuality)
		{
			var vignette:FNFSprite = new FNFSprite(-250, -140).loadGraphic(Paths.image('vignetteOverlay', 'data/stages/waltRoom/images'));
			vignette.cameras = [PlayState.camAlt];
			vignette.scale.set(0.75, 0.75);
			vignette.antialiasing = true;
			vignette.scrollFactor();
			vignette.active = false;
			add(vignette);
		}
}

function charStagePos(boyfriend:Character, gf:Character, dad:Character)
{
	switch (dad.curCharacter)
	{
		case 'walt-true':
			dad.setPosition(240, -200);
		case 'walt-new':
			dad.setPosition(220, -50);
		default:
			dad.setPosition(0, 0);
	}
    	boyfriend.setPosition(330, 300); //make sure to replace bf with a first-person pov variant
}