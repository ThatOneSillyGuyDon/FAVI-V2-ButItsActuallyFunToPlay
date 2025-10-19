package states;

import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;

class BotplayScreen extends MusicBeatState {
    var randomMsg:Array<String> = [
        "Having trouble?",
        "It's okay to lose sometimes.",
        "You'll be fine, don't worry.",
        "Not everyone's as good at the game.",
        "Keep going.",
        "Stuck again?",
        "Accept the offer?",
        "And so, we meet again."
    ];
    var flashy:Array<FlxSprite> = [];
    var finishedIntro:Bool = false;
    var pathway:String = 'Funkin_avi/botplayScreen/';
    var stupidGraphic:FlxSprite;
    var light:FlxSprite; //shut up shut up shut up shut up shut up shut up shut up shut up (compiler wouldn't stfu about the variables being missing)
    var fog:FlxSprite;
    var flair:FlxSprite;

    override public function create() {
        super.create();

        FlxG.sound.playMusic(Paths.music("aviOST/gameOver/amIReal", "shared"));
		FlxG.sound.music.pitch = 0.45;

        var bg = new FlxSprite().makeGraphic(1, 1, FlxColor.fromRGB(62, 62, 62));
        var sign = new FlxSprite().loadGraphic(Paths.image(pathway + "sign"));
        var prompt = new FlxSprite().loadGraphic(Paths.image(pathway + "introPrompt"));
        var options = new FlxSprite().loadGraphic(Paths.image(pathway + "options"));
        flashy[0] = new FlxSprite().loadGraphic(Paths.image(pathway + "flash1"));
        flashy[1] = new FlxSprite().loadGraphic(Paths.image(pathway + "flash2"));
        var darkness = new FlxSprite().loadGraphic(Paths.image(pathway + "darkness"));
        if (!ClientPrefs.data.lowQuality)
        {
            light = new FlxSprite().loadGraphic(Paths.image(pathway + "light"));
            flair = new FlxSprite().loadGraphic(Paths.image(pathway + "flair"));
            fog = new FlxBackdrop(Paths.image(pathway + "fog"), X, 0, 0);
        }
        stupidGraphic = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);

        Application.current.window.title = 'Funkin.avi - ${randomMsg[FlxG.random.int(0, randomMsg.length-1)]}';
        FlxG.camera.zoom -= 0.2;
        bg.setGraphicSize(FlxG.width*2, FlxG.height*2);
        stupidGraphic.setGraphicSize(FlxG.width*2, FlxG.height*2);
        if (!ClientPrefs.data.lowQuality)
        {
            fog.velocity.set(-100, 0);
            fog.alpha = 0.79;
        }

        for (i in [prompt, options, flashy[0], flashy[1], stupidGraphic])
            i.alpha = 0.001;
        if (!ClientPrefs.data.lowQuality)
        {
            for (j in [light, flair])
                j.blend = ADD;
            for (m in [darkness, light, fog, flair])
                m.scale.set(1.16, 1.16);
            for (f in [bg, sign, prompt, options, flashy[0], flashy[1], darkness, light, fog, flair, stupidGraphic])
            {
                f.screenCenter();
                add(f);
            }
            for (e in [light, flair])
                FlxTween.tween(e, {alpha: 0.1}, 5, {ease: FlxEase.expoInOut, type: 4});
        }
        else {
            darkness.scale.set(1.16, 1.16);
            for (f in [bg, sign, prompt, options, flashy[0], flashy[1], darkness, stupidGraphic])
            {
                f.screenCenter();
                add(f);
            }
        }

        sign.y -= 800;

        FlxTween.tween(darkness, {alpha: 0.87}, 3, {ease: FlxEase.expoInOut, type: 4});
        FlxTween.tween(FlxG.camera, {zoom: 1}, 3, {ease: FlxEase.expoOut});
        FlxTween.tween(sign, {y: -108}, 2, {ease: FlxEase.bounceInOut, startDelay: 0.65, onComplete: function(twn:FlxTween)
        {
            FlxTween.tween(prompt, {alpha: 1}, 1.2, {ease: FlxEase.expoOut, startDelay: 0.2, onComplete: function(twn:FlxTween)
            {
                FlxTween.tween(options, {alpha: 1}, 1.2, {ease: FlxEase.expoOut, startDelay: 1.2, onComplete: function(twn:FlxTween)
                {
                    finishedIntro = true;
                }});
            }});
        }});
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (finishedIntro)
        {
            // gonna be honest, this could've been done SO MUCH MORE SIMPLER if Flixel wasn't retarded as fuck
            if (FlxG.keys.justPressed.Y)
                FlxTween.tween(stupidGraphic, {alpha: 1}, 3, {onComplete: function(twn:FlxTween)
                {
                    GameData.overrideBotplay();
                }});
            if(FlxG.keys.justPressed.N)
                FlxTween.tween(stupidGraphic, {alpha: 1}, 3, {onComplete: function(twn:FlxTween)
                {
                    MusicBeatState.switchState(new PlayState());
                }});
            if (FlxG.keys.justPressed.Y || FlxG.keys.justPressed.N)
            {
                FlxG.sound.play(Paths.sound('funkinAVI/menu/confirmEpisode'));
                FlxG.camera.zoom += 0.12;
                FlxTween.tween(FlxG.camera, {zoom: 1}, 1.2, {ease: FlxEase.expoOut});
                if (FlxG.keys.justPressed.Y)
                {
                    flashy[0].alpha = 1;
                    FlxTween.tween(flashy[0], {alpha: 0}, 2.5, {ease: FlxEase.expoOut});
                }
                else 
                {
                    flashy[1].alpha = 1;
                    FlxTween.tween(flashy[1], {alpha: 0}, 2.5, {ease: FlxEase.expoOut});
                }
                finishedIntro = false;
            }
        }
    }
}