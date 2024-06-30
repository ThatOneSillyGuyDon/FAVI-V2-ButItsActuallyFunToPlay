package assets.data.stages.street;

function onCreate() {
    PlayState.defaultCamZoom = 0.87;
    spawnGirlfriend(false);

    var stageDir:String = 'data/stages/street/images';

    var stageFront:FNFSprite = new FNFSprite(0, 0).loadGraphic(Paths.image('cables', stageDir));
    stageFront.scale.set(2, 1);
    stageFront.updateHitbox();
    stageFront.cameras = [PlayState.camHUD];
    stageFront.antialiasing = true;
    stageFront.scrollFactor.set(0.9, 0.9);
    stageFront.active = false;
    add(stageFront);

    var colorsOrSmthElse:FNFSprite = new FNFSprite(-990, 1600).loadGraphic(Paths.image('randomColors', stageDir));
    colorsOrSmthElse.setGraphicSize(Std.int(colorsOrSmthElse.width * 1.1));
    colorsOrSmthElse.updateHitbox();
    colorsOrSmthElse.antialiasing = true;
    colorsOrSmthElse.screenCenter();
    colorsOrSmthElse.scale.set(3, 3);
    colorsOrSmthElse.scrollFactor.set(0.9, 0.9);
    colorsOrSmthElse.active = false;
    add(colorsOrSmthElse);

    var floor:FNFSprite = new FNFSprite(-500, 200).loadGraphic(Paths.image('street', stageDir));
    floor.antialiasing = true;
    floor.scale.set(2.2, 2);
    floor.screenCenter(X);
    floor.scrollFactor.set(1, 1);
    floor.active = false;
    add(floor);   
}