package states;

class EVILantileakState extends FlxState 
{
    var passworld = 'test';
    var box:PsychUIInputText;
    var pass:FlxText;
    var signInBox:PsychUIButton;

    override function create() {
        pass = new FlxText(0, 125, 300, "Insert the password to continue", 20);
        pass.setFormat(Paths.font("resultsFont.ttf"), 30, FlxColor.WHITE, CENTER);
        pass.screenCenter(X);
        add(pass);

        box = new PsychUIInputText(0, 175, 300, '', 32);
        box.screenCenter();
        add(box);

        var signInBox:PsychUIButton = new PsychUIButton(0, 475, "Continue", function()
		{
			if (box.text == '67XP+:8v!1EL0e%2gIzrfR+!&')
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