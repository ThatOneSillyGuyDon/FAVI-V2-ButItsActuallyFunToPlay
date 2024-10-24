package backend.windows;

import sys.FileSystem;
import lime.app.Application;
import openfl.Lib;
import lime.graphics.Image;
import openfl.utils.Assets;
import openfl.display.BitmapData;

// get the icons first
@:bitmap("art/appIcon/newIcon.png") class NewIcon extends BitmapData {}
@:bitmap("art/appIcon/legacyIcon.png") class LegacyIcon extends BitmapData {}
@:bitmap("art/appIcon/invertedIcon.png") class BlessIcon extends BitmapData {}
@:bitmap("art/appIcon/malIcon.png") class MalIcon extends BitmapData {}
@:bitmap("art/appIcon/gearIcon.png") class GearIcon extends BitmapData {}

// now we control it here
class AppIcon {
    public static var icon:Image;

    inline public static function changeIcon(name:String)
    {
        switch (name.toLowerCase())
        {
            case "newicon" | "v2icon":
                icon = Image.fromBitmapData(new NewIcon(0,0));
            case "oldicon" | "legacyicon":
                icon = Image.fromBitmapData(new LegacyIcon(0,0));
            case "blessicon" | "whiteicon" | "invertedicon":
                icon = Image.fromBitmapData(new BlessIcon(0,0));
            case "malicon" | "glitchicon":
                icon = Image.fromBitmapData(new MalIcon(0,0));
            case "gearicon" | "devicon" | "debugicon":
                icon = Image.fromBitmapData(new GearIcon(0,0));
        }

        Application.current.window.setIcon(icon);
    }
}