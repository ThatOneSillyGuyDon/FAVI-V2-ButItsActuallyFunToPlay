package gameObjects.utils;

import flixel.graphics.frames.FlxAtlasFrames;

class AttachedFlxText extends FlxTextAlphabet
{
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public var sprTracker:FlxSprite;
	public var copyVisible:Bool = true;
	public var copyAlpha:Bool = false;
	public function new(text:String = "", ?offsetX:Float = 0, ?offsetY:Float = 0) {
		super(0, 0, 0, text, 8);

		this.isMenuItem = false;
		this.offsetX = offsetX;
		this.offsetY = offsetY;
	}

	override function update(elapsed:Float) {
		if (sprTracker != null) {
			setPosition(sprTracker.x + offsetX, sprTracker.y + offsetY);
			if(copyVisible) {
				visible = sprTracker.visible;
			}
			if(copyAlpha) {
				alpha = sprTracker.alpha;
			}
		}

		super.update(elapsed);
	}
}