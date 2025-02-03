package gameObjects.transitions;

import flixel.addons.transition.FlxTransitionableState;

class CustomFadeTransition extends MusicBeatSubstate {
	public static var finishCallback:Void->Void;
	private var leTween:FlxTween = null;
	public static var nextCamera:FlxCamera;
	var isTransIn:Bool = false;
	var transBlack:FlxSprite;
	var transGradient:FlxSprite;

	public function new(duration:Float, isTransIn:Bool) {
		super();

		this.isTransIn = isTransIn;
		
		transBlack = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		transBlack.scrollFactor.set(0, 0);
		transBlack.screenCenter();
		transBlack.scale.set(FlxG.width * 5, FlxG.height * 5);
		if(!isTransIn)
			transBlack.alpha = 0.001;
		add(transBlack);

		//transGradient.x -= (width - FlxG.width) / 2;
		//transBlack.x = transGradient.x;

		if(isTransIn) {
			FlxTween.tween(transBlack, {alpha: 0}, duration, {
				onComplete: function(twn:FlxTween) {
					close();
				},
			ease: FlxEase.linear});
		} else {
			FlxTween.tween(transBlack, {alpha: 1}, duration, {
				onComplete: function(twn:FlxTween) {
					if(finishCallback != null) {
						finishCallback();
					}
				},
			ease: FlxEase.linear});
		}

		if(nextCamera != null) {
			transBlack.cameras = [nextCamera];
			//transGradient.cameras = [nextCamera];
		}
		nextCamera = null;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}

	override function destroy() {
		if(leTween != null) {
			finishCallback();
			leTween.cancel();
		}
		super.destroy();
	}
}