package gameObjects.ui;

import openfl.utils.Assets as OpenFlAssets;

/**
 * ## This class basically handles all the needed checks before loading a character icon on the health bar!
 * 
 * @param sprTracker Used primarily in menus to stay locked in place
 * @param isOldIcon Checks if you're using the beta BF icon
 * @param isPlayer Checks if the icon should be flipped so it faces towards the opponent's icon
 * @param isAnimated Checks if you have an xml file for the icon you're trying to load
 * @param isShakeable Checks if the icon is allowed to do a shake effect
 * @param char the name of your character icon the game will fetch
 */
class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;
	private var isOldIcon:Bool = false;
	private var isPlayer:Bool = false;
	private var isAnimated:Bool = false;
	private var isShakeable:Bool = false;
	private var char:String = '';

	public function new(char:String = 'bf', isPlayer:Bool = false, isAnimated:Bool = false, canShake:Bool = false)
	{
		super();
		isOldIcon = (char == 'bf-old');
		this.isPlayer = isPlayer;
		this.isAnimated = isAnimated;
		this.isShakeable = canShake;
		changeIcon(char, isAnimated, canShake);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (isShakeable)
			shake(2.7, 2, 0.1);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 12, sprTracker.y - 30);
	}

	public function swapOldIcon() {
		if(isOldIcon = !isOldIcon) changeIcon('bf-old', false, false);
		else changeIcon('bf', false, false);
	}

	private var iconOffsets:Array<Float> = [0, 0];

	/**
	 * ## This function handles how the icons load along with being used for the Character Change Event
	 * 
	 * @param char The name of your icon
	 * @param isAnimated Updates the current icon to find an xml rather than a static image
	 * @param isShakeable Updates the current icon to check if it can play a shake effect
	 */
	public function changeIcon(char:String, isAnimated:Bool, isShakeable:Bool) {
		if(this.char != char) {
			var name:String = 'icons/' + char;
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-' + char; //Older versions of psych engine's support
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-face'; //Prevents crash from missing icon
			var file:Dynamic = Paths.image(name);

			if (!isAnimated)
			{
				loadGraphic(file); //Load stupidly first for getting the file size
				loadGraphic(file, true, Math.floor(width / 2), Math.floor(height)); //Then load it fr
			}
			else
			{
				frames = Paths.getSparrowAtlas(name);
			}
			iconOffsets[0] = (width - 150) / 2;
			iconOffsets[1] = (width - 150) / 2;
			updateHitbox();

			if (!isAnimated)
			{
				animation.add(char, [0, 1], 0, false, isPlayer);
				animation.play(char);
			}
			else
			{
				animation.addByPrefix(char + "Neutral", "icon neutral", 24, true, isPlayer);
				animation.addByPrefix(char + "Losing", "icon losing", 24, true, isPlayer);
				animation.play(char + "Neutral");
			}
			this.char = char;
			this.isAnimated = isAnimated;
			this.isShakeable = isShakeable;

			antialiasing = ClientPrefs.globalAntialiasing;
			if(char.endsWith('-pixel')) {
				antialiasing = false;
			}
		}
	}

	/**
     * Shakes a `HealthIcon` using his Offsets
     * 
     * @param ShakeValue Value of the `FlxText` shake
     * @param AngleValue Value of the `FlxText` angle shake
     * @param Timer How many time does it affect
     * @param onComplete OPTIONAL: a function triggered after the shake is finished
     * @return The `FlxText` to shake
	 * 
	 * I want to make funny text do the rump shaker /j - don
     */
	 public inline function shake(ShakeValue:Float = 0.05, AngleValue:Int = 0, Timer:Float = 1, ?onComplete:Null<FlxSprite -> Void>):HealthIcon
    {
		var stop:Bool = false;

		if(!stop)
		{
			if(AngleValue > 360)
				AngleValue = 360;
	
			offset.x = FlxG.random.float(-ShakeValue, ShakeValue);
			offset.y = FlxG.random.float(-ShakeValue, ShakeValue);
			angle = FlxG.random.int(-AngleValue, AngleValue);	
		}
			
		new FlxTimer().start(Timer, timer->stop = true);

        return this;
    }

	override function updateHitbox()
	{
		super.updateHitbox();
		offset.x = iconOffsets[0];
		offset.y = iconOffsets[1];
	}

	public function getCharacter():String {
		return char;
	}
}
