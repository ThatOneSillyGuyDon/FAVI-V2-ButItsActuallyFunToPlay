package states.refactored;

import flixel.input.keyboard.FlxKey;

class SafeModeTypes {
    public static var allowedKeys:Array<Int> = [
        FlxKey.ENTER, FlxKey.BACKSPACE, FlxKey.SPACE, FlxKey.A, FlxKey.B, FlxKey.C, FlxKey.D, FlxKey.E, FlxKey.F, FlxKey.G, FlxKey.H, FlxKey.I, FlxKey.J,
        FlxKey.K, FlxKey.L, FlxKey.M, FlxKey.N, FlxKey.O, FlxKey.P, FlxKey.Q, FlxKey.R, FlxKey.S, FlxKey.T, FlxKey.U, FlxKey.V, FlxKey.W, FlxKey.X, FlxKey.Y,
        FlxKey.Z
    ];

    public static var commands:Array<String> = ["help", "getinfo", "about", "shutdown", "clear", "say"];
}
