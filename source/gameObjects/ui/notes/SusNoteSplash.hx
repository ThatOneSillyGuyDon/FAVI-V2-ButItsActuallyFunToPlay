package gameObjects.ui.notes;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;

class SusNoteSplash extends FlxSprite
{
	var texture:String = 'susNotesSplashes';
	public var state:Int = 0;
	public var directionn:Int = 0;

	public function new(x:Float = 0, y:Float = 0, ?note:Int = 0) {
		super(x, y);

		var skin:String = 'susNotesSplashes';
		loadAnims(skin);

		setupNoteSplash(x, y, note);
		antialiasing = ClientPrefs.globalAntialiasing;
	}

	public function setupNoteSplash(x:Float, y:Float, direction:Int = 0, ?note:Note = null) {
		setPosition(x, y);
		alpha = 1;
		loadAnims(texture);

		directionn = direction;

		offset.set(0.2 * width - 10, 0.2 * height - 25);

		if(animation.curAnim != null)animation.curAnim.frameRate = 24 + FlxG.random.int(-2, 2);
	}

	function loadAnims(skin:String) {
		frames = Paths.getSparrowAtlas(skin);
		for (i in 0...Note.colArray.length) {
			animation.addByPrefix('holdCoverStart 0', 'sustain cover purple0', 24, false, false, false);
			animation.addByPrefix('holdCoverStart 1', 'sustain cover blue0', 24, false, false, false);
			animation.addByPrefix('holdCoverStart 2', 'sustain cover green0', 24, false, false, false);
			animation.addByPrefix('holdCoverStart 3', 'sustain cover red0', 24, false, false, false);
			animation.addByPrefix('holdCover 0', 'sustain cover loop purple0', 24, true, false, false);
			animation.addByPrefix('holdCover 1', 'sustain cover loop blue0', 24, true, false, false);
			animation.addByPrefix('holdCover 2', 'sustain cover loop green0', 24, true, false, false);
			animation.addByPrefix('holdCover 3', 'sustain cover loop red0', 24, true, false, false);
			animation.addByPrefix('holdCoverEnd 0', 'sustain cover end purple0', 24, false, false, false);
			animation.addByPrefix('holdCoverEnd 1', 'sustain cover end blue0', 24, false, false, false);
			animation.addByPrefix('holdCoverEnd 2', 'sustain cover end green0', 24, false, false, false);
			animation.addByPrefix('holdCoverEnd 3', 'sustain cover end red0', 24, false, false, false);
		}
	}

	override function update(elapsed:Float) {

		super.update(elapsed);

		animation.finishCallback = this.onAnimationFinished;
	}

	public function playStart():Void
	{
	    animation.play('holdCoverStart ${directionn}');
		//trace(animation.name);
	}
	  
	public function playContinue():Void
	{
		animation.play('holdCover ${directionn}');
		//trace(animation.name);
	}
	  
	public function playEnd():Void
	{
		offset.set(0.2 * width + 35, 0.2 * height + 40);
		animation.play('holdCoverEnd ${directionn}');
		//trace(animation.name);
	}

	public function onAnimationFinished(animationName:String):Void
	{
		if (animationName.startsWith('holdCoverStart'))
		{
			playContinue();
		}
		if (animationName.startsWith('holdCoverEnd'))
		{
			//visible = false;
			kill();
		}
	}
}