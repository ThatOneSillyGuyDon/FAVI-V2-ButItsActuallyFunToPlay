package gameObjects.ui;

import flixel.util.FlxSignal;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.FlxBasic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.text.FlxText;

typedef Utils = 
{
    @:deprecated('text is no longer used! Use sendNotification instead')
    @:noCompletion
    /**
    * The main text for your notification
    */
    @:optional var text:String;
    
    @:deprecated('text is no longer used! Use sendNotification instead')
    @:noCompletion
    /**
    * The secondary text for your notification
    */
	@:optional var subText:String;

	/**
	* The font used for your notification box (affects both main and secondary text!)
	*/
    @:optional var font:String;

    /**
    * The text color used for your notification box (affects both main and secondary text!)
    */
    @:optional var textColor:FlxColor;

    /**
    * The width of your notification box.
    */
    @:optional var boxWidth:Int;

    /**
    * The height of your notification box.
    */
    @:optional var boxHeight:Int;

    /**
    * The color of your notification box.
    */
    @:optional var boxColor:FlxColor;

	/**
	* The camera that will be present in your notification box (Uses the last camera of the `FlxG.cameras.list` list by default).
	*/
	@:optional var camera:flixel.FlxCamera;
} 

/**
 * The `MessageBox` class is a typed object that send a notification for anything you want to specify!
 */
class MessageBox extends FlxTypedGroup<FlxBasic>
{
    public var box:FlxSprite;
    public var boxText:FlxText;
    public var boxSubText:FlxText;

    // var onDeny = new FlxSignal();

    var boxTween:FlxTween;
	var boxTween2:FlxTween;
	var boxTween3:FlxTween;

    /**
     * Creates a new `MessageBox`.
     * @param x the X axis of your `MessageBox`.
     * @param y the Y axis of your `MessageBox`.
     * @param utils additional tools for your box.
     */
    public function new(x:Float = 0, y:Float = 0, utils:Utils) {
        // null checks
        if (utils.font == null) utils.font = 'vcr';
        if (utils.textColor == null) utils.textColor = FlxColor.WHITE;
        if (utils.boxWidth == null) utils.boxWidth = 360;
        if (utils.boxHeight == null) utils.boxHeight = 90;
        if (utils.boxColor == null) utils.boxColor = FlxColor.BLACK;
        if (utils.camera == null) utils.camera = FlxG.cameras.list[FlxG.cameras.list.length - 1];

        super();

        boxText = new FlxText(x, y, 0, 'this is a text!', 24);
		boxText.setFormat(Paths.font(utils.font), 32, 0xFFFFFFFF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFF000000);
		boxText.scrollFactor.set();
		boxText.camera = utils.camera;

		boxSubText = new FlxText(x, boxText.y + 30, 0, 'this is a subtext!', 24);
		boxSubText.setFormat(Paths.font(utils.font), 24, 0xFFFFFFFF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFF000000);
		boxSubText.scrollFactor.set();
		boxSubText.camera = utils.camera;

		box = new FlxSprite(x, boxText.y).makeGraphic(utils.boxWidth, utils.boxHeight, utils.boxColor);
		box.scrollFactor.set();
		box.camera = utils.camera;

        box.alpha = boxText.alpha = boxSubText.alpha = 0;

        add(box);
		add(boxText);
		add(boxSubText);
    }

    /**
     * Send a `MessageBox` message to the game.
     * @param text the principal piece of text of your notification.
     * @param subText the secondary piece of text of your notification.
     */
    public function sendMessage(text:String = 'text', subText:String = '')
    {
        if (boxTween != null)
            boxTween.cancel();
        if (boxTween2 != null)
            boxTween2.cancel();
        if (boxTween3 != null)
            boxTween3.cancel();

        boxText.text = text;
        boxSubText.text = subText;

        boxTween = FlxTween.tween(boxText, {
            alpha: 1,
            x: 0
        }, 0.8, {
            ease: FlxEase.sineOut,
            onComplete: function(twn:FlxTween)
            {
                boxTween = FlxTween.tween(boxText, {
                    alpha: 0,
                    x: -400
                }, 1.5, {
                    startDelay: 3,
                    ease: FlxEase.sineInOut,
                    onComplete: function(twn:FlxTween)
                    {
                        boxTween = null;
                    }
                });
            }
        });
        boxTween2 = FlxTween.tween(boxSubText, {
            alpha: 1,
            x: 0
        }, 0.8, {
            ease: FlxEase.sineOut,
            onComplete: function(twn:FlxTween)
            {
                boxTween2 = FlxTween.tween(boxSubText, {
                    alpha: 0,
                    x: -400
                }, 1.5, {
                    startDelay: 3,
                    ease: FlxEase.sineInOut,
                    onComplete: function(twn:FlxTween)
                    {
                        boxTween2 = null;
                    }
                });
            }
        });
        boxTween3 = FlxTween.tween(box, {
            alpha: 1,
            x: 0
        }, 0.8, {
            ease: FlxEase.sineOut,
            onComplete: function(twn:FlxTween)
            {
                boxTween3 = FlxTween.tween(box, {
                    alpha: 0,
                    x: -400
                }, 1.5, {
                    startDelay: 3,
                    ease: FlxEase.sineInOut,
                    onComplete: function(twn:FlxTween)
                    {
                        boxTween3 = null;
                    }
                });
            }
        });
    }
}