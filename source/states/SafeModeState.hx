package states;

import flixel.input.keyboard.FlxKey;

class SafeModeState extends MusicBeatState
{
	var curLine:Int = 0;
	var command:String = "";

	var allowedKeys:Array<Int> = [
		FlxKey.ENTER, FlxKey.BACKSPACE, FlxKey.SPACE, FlxKey.A, FlxKey.B, FlxKey.C, FlxKey.D, FlxKey.E, FlxKey.F, FlxKey.G, FlxKey.H, FlxKey.I, FlxKey.J,
		FlxKey.K, FlxKey.L, FlxKey.M, FlxKey.N, FlxKey.O, FlxKey.P, FlxKey.Q, FlxKey.R, FlxKey.S, FlxKey.T, FlxKey.U, FlxKey.V, FlxKey.W, FlxKey.X, FlxKey.Y,
		FlxKey.Z
	];

	var commands:Array<String> = ["help", "getinfo", "about", "shutdown", "clear", "say"];
	var texts:Array<FlxText> = [];
	var lines:Array<String> = [];
	var underscored:String = '_';

	override function create()
	{
		lines.resize(40);

		for (i in 0...40)
		{
			var text:FlxText = new FlxText(0, 18 * i, FlxG.width, '', 17);
			add(text);
			texts.push(text);
		}

		new FlxTimer().start(0.5, function(tmr:FlxTimer)
		{
			if (underscored == '_')
			{
				underscored = ' ';
			}
			else
			{
				underscored = '_';
			}
		}, 0);

		super.create();
	}

	override function update(elapsed:Float)
	{
		var key:FlxKey = FlxG.keys.firstJustPressed();

		if (allowedKeys.contains(key))
		{
			switch (key)
			{
				case 8:
					command = command.substring(0, (command.length - 1));
				case 32:
					command += " ";
				case 13:
					execute_command(command);
					command = "";
				case _:
					command += key.toString().toLowerCase();
			}
		}

		lines[curLine] = "@root> " + command + underscored;
		for (i in 0...texts.length)
		{
			texts[i].text = lines[i];
		}
	}

	function execute_command(command:String)
	{
		lines[curLine] = "@root> " + command;
		if (curLine >= 39)
		{
			curLine = 39;
			lines.shift();
			lines.push("");
		}
		else
		{
			curLine++;
		}
		switch (command)
		{
			case "help":
		}
	}
}
