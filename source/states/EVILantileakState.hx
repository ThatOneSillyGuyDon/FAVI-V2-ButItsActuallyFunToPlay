package states;

class EVILantileakState extends FlxState 
{
    var passworld = 'test';
    var box:FlxUIInputText;
    var pass:FlxText;
    var signInBox:FlxButton;

    override function create() {
        pass = new FlxText(0, 125, 300, "Insert the password to continue", 20);
        pass.setFormat(Paths.font("resultsFont.ttf"), 30, FlxColor.WHITE, CENTER);
        pass.screenCenter(X);
        add(pass);

        box = new FlxUIInputText(0, 175, 300, null, 32, FlxColor.BLACK, FlxColor.GRAY);
        box.screenCenter();
        box.backgroundColor = 0xFF333333;
        box.setFormat(Paths.font("resultsFont.ttf"), 24, FlxColor.WHITE);
        add(box);

        signInBox = new FlxButton(0, 475, "Continue", function()
        {
            if (box.text == '67XP+:8v!1EL0e%2gIzrfR+!&')
            {
                trace('should work');
                FlxG.switchState(new TitleState());
            }
        });
        signInBox.color = FlxColor.fromRGB(62, 62, 62);
        signInBox.label.color = FlxColor.WHITE;
        signInBox.scale.set(1.5, 1.5);
        signInBox.screenCenter(X);
        add(signInBox);

        super.create();
    }
}