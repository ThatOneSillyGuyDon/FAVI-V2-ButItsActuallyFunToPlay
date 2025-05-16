package states;

class EVILantileakState extends FlxState 
{
    var passworld = 'test';
    var box:FlxUIInputText;
    var pass:FlxText;
    var signInBox:FlxButton;

    override function create() {
        pass = new FlxText(0, 125, 300, "Insert the password to continue", 20);
        pass.screenCenter(X);
        add(pass);

        box = new FlxUIInputText(0, 175, 300, null, 32, FlxColor.BLACK, FlxColor.GRAY);
        box.screenCenter();
        add(box);

        signInBox = new FlxButton(0, 475, "Continue", function()
        {
            if (box.text == 'V7RVPXqWXuPkkgCTVLlU')
            {
                trace('should work');
                FlxG.switchState(new TitleState());
            }
        });
        signInBox.scale.set(1.5, 1.5);
        signInBox.screenCenter(X);
        add(signInBox);

        super.create();
    }
}