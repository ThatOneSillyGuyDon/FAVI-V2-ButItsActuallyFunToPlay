package states.menus;

import haxe.Json;
import sys.io.File;
import flixel.input.keyboard.FlxKey;

typedef MenuJson = {
    var intro:Array<String>;
    var questionsAndAnswers:Array<Dynamic>;
}

class AskQuestionToThatGuy extends MusicBeatState
{
    var camFollow:FlxObject;
    var camFollowPos:FlxObject;

    var jaysun:Character;
    var jaysunAnims:Character; // can't change character within functions and yes the spritemaps were bugged + spritesheet too big for all the animations :[[[[

    var camHUD:FlxCamera;
    var targetZoom = .85;

    var text:FlxTypeText;
    var box:FlxUIInputText;

    var typing:Bool = false;

    var introTexts:Array<String> = [
        "Welcome to this place, JaySun T. Mouse is the name!\nAsk me anything you want!",
        "You know the deal, ask me anything!",
        "Hmmm.... Seems that you're here for something... Come on! Say anything!",
        "Welcome back! Do you need anything or..."
    ];

    var questions:Array<String> = [
        'who are you',
        'who',
        'what are you'
    ];

    var answers:Array<String> = [
        'test result with who are you',
        "sorry cant answer that"
    ];

    override function create() {
        CustomFadeTransition.nextCamera = camHUD;

        camHUD = new FlxCamera();
        camHUD.bgColor.alpha = 0;
        FlxG.cameras.add(camHUD, false);

        var bg = new FlxSprite().loadGraphic(Paths.image('Funkin_avi/jaysun/background'));
        bg.scrollFactor.set();
        bg.setGraphicSize(bg.width * .85);
        bg.updateHitbox();
        bg.screenCenter();
        add(bg);

        var shit = new FlxSprite().loadGraphic(Paths.image('Funkin_avi/jaysun/hat'));
        shit.setGraphicSize(shit.width * .5);
        shit.updateHitbox();
        shit.screenCenter().x += 160;
        shit.y += 100;
        shit.scrollFactor.set(.8, .8);
        add(shit);

        var sofa = new FlxSprite().loadGraphic(Paths.image('Funkin_avi/jaysun/sofa'));
        sofa.setGraphicSize(sofa.width * .7);
        sofa.updateHitbox();
        sofa.screenCenter();
        add(sofa);

        jaysun = new Character(0, 0, 'jaysun');
        jaysun.playAnim('idle', true);
        jaysun.screenCenter();
        jaysun.x += jaysun.positionArray[0];
        jaysun.y += jaysun.positionArray[1];
        jaysun.visible = false;
        add(jaysun);

        jaysunAnims = new Character(0, 0, 'jaysun_animations');
        jaysunAnims.playAnim('talk', true);
        jaysunAnims.screenCenter();
        jaysunAnims.x += jaysunAnims.positionArray[0];
        jaysunAnims.y += jaysunAnims.positionArray[1];
        add(jaysunAnims);

        jaysun.visible = false;
        jaysunAnims.visible = true;
        targetZoom = 1;

        text = new FlxTypeText(155, 520, 1100, '');
        text.setFormat(Paths.font('vcr.ttf'), 34, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
        text.borderSize = 2;
        text.resetText(introTexts[FlxG.random.int(0, introTexts.length-1)]);
        text.start(.04, true);
        text.sounds = [FlxG.sound.load(Paths.sound('funkinAVI/Jaysun Dialogue Sound'))];
        text.antialiasing = ClientPrefs.globalAntialiasing;
        text.camera = camHUD;
        text.completeCallback = () -> {
            jaysun.visible = true;
            jaysunAnims.visible = false;
    
            text.erase(0);
            targetZoom = .85;
        };
        add(text);

        box = new FlxUIInputText(0, 90, 300, null, 32, FlxColor.BLACK, FlxColor.GRAY);
        box.screenCenter(X);
        box.camera = camHUD;
        box.focusGained = () -> typing = true;
        box.focusLost = () -> typing = false;
        add(box);

        if (!ClientPrefs.lowQuality)
        {
            var scratchStuff:FlxSprite = new FlxSprite();
            scratchStuff.frames = Paths.getSparrowAtlas('Funkin_avi/filters/scratchShit');
            scratchStuff.animation.addByPrefix('idle', 'scratch thing 1', 24, true);
            scratchStuff.animation.play('idle');
            scratchStuff.screenCenter();
            scratchStuff.scale.x = 1.1;
            scratchStuff.scale.y = 1.1;
            scratchStuff.scrollFactor.set();
            scratchStuff.camera = camHUD;
            add(scratchStuff);

            var grain:FlxSprite = new FlxSprite();
            grain.frames = Paths.getSparrowAtlas('Funkin_avi/filters/Grainshit');
            grain.animation.addByPrefix('idle', 'grains 1', 24, true);
            grain.animation.play('idle');
            grain.screenCenter();
            grain.scale.x = 1.1;
            grain.scale.y = 1.1;
            grain.scrollFactor.set();
            grain.camera = camHUD;
            add(grain);

            var gradient = new FlxSprite().loadGraphic(Paths.image('Funkin_avi/filters/gradient'));
            gradient.scrollFactor.set(0, 0);
            gradient.setGraphicSize(Std.int(gradient.width * 0.775));
            gradient.updateHitbox();
            gradient.screenCenter();
            gradient.antialiasing = true;
            gradient.camera = camHUD;
            add(gradient);
        }

        super.create();

        FlxG.camera.fade(FlxColor.BLACK, 1, true);

        camFollow = new FlxObject(jaysun.getGraphicMidpoint().x + 10, jaysun.getGraphicMidpoint().y - 100, 1, 1);
		camFollowPos = new FlxObject(jaysun.getGraphicMidpoint().x + 10, jaysun.getGraphicMidpoint().y - 800, 1, 1);
		add(camFollow);
		add(camFollowPos);

        FlxG.camera.follow(camFollowPos, null, 1);
        FlxG.sound.playMusic(Paths.music('aviOST/muchABlige'));
    }

    override function update(elapsed:Float) {
        if (controls.BACK && !typing)
        {
            MusicBeatState.switchState(new MainMenu());
            FlxG.sound.playMusic(Paths.music('aviOST/rottenPetals'));
        }

        if (FlxG.keys.justPressed.F5)
            FlxG.resetState(); // offset related

        if (FlxG.keys.justPressed.ENTER)
        {
            askQuestion(box.text);
        }

        super.update(elapsed);

        var lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
        FlxG.camera.zoom = FlxMath.lerp(targetZoom, FlxG.camera.zoom, Math.exp(-elapsed * 3.125));
    }

    var existentQuestion:Bool = false;
    var finalText:String = null;
    var finalAnimation:String = null;
    function askQuestion(_:String)
    {
        for (q in questions)
            {
                existentQuestion = box.text == q;
                trace(_, {customParms: ['EXISTANT QUESTION: ' + existentQuestion]});
    
                if (existentQuestion)
                {
                    switch (q)
                    {
                        case 'who are you', 'who', 'what are you':
                            finalText = "JaySun T. Mouse is the name! Even though I'm not exactly a Mouse… or a T… or a JaySun. You know what, just think of me as… a breeze of thin air… whatever that is. But if you want more info on me, I'd watch Orseofkorse. Who's Orseofkorse? … I donno.";
                            finalAnimation = "talk";
                    }
    
                    jaysun.visible = false;
                    jaysunAnims.visible = true;
                    jaysunAnims.playAnim('talk', true);
                    targetZoom = 1;
            
                    text.erase(0);
                    text.resetText(finalText);
                    text.start(.04);
                    text.completeCallback = onCompleteCallback;
                }
            }
    }

    function onCompleteCallback()
    {
        jaysun.visible = true;
        jaysunAnims.visible = false;

        targetZoom = .85;
    }
}