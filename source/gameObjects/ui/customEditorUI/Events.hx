package gameObjects.ui.customEditorUI;

class Events {
    public static var eventStuff:Array<Dynamic>;

    public static function getEvents() {
        var default_events:Array<Dynamic> = [
            ['', "Nothing. Yep, that's right."],
            ['Hey!', "Plays the \"Hey!\" animation from Bopeebo,\nValue 1: BF = Only Boyfriend, GF = Only Girlfriend,\nSomething else = Both.\nValue 2: Custom animation duration,\nleave it blank for 0.6s"],
            ['Set GF Speed', "Sets GF head bopping speed,\nValue 1: 1 = Normal speed,\n2 = 1/2 speed, 4 = 1/4 speed etc.\nUsed on Fresh during the beatbox parts.\n\nWarning: Value must be integer!"],
            ['Add Camera Zoom', "Used on MILF on that one \"hard\" part\nValue 1: Camera zoom add (Default: 0.015)\nValue 2: UI zoom add (Default: 0.03)\nLeave the values blank if you want to use Default."],
            ['Play Animation', "Plays an animation on a Character,\nonce the animation is completed,\nthe animation changes to Idle\n\nValue 1: Animation to play.\nValue 2: Character (Dad, BF, GF)"],
            ['Alt Idle Animation', "Sets a specified suffix after the idle animation name.\nYou can use this to trigger 'idle-alt' if you set\nValue 2 to -alt\n\nValue 1: Character to set (Dad, BF or GF)\nValue 2: New suffix (Leave it blank to disable)"],
            ['Change Character', "Value 1: Character to change (Dad, BF, GF)\nValue 2: New character's name"],
            ['Change Scroll Speed', "Value 1: Scroll Speed Multiplier (1 is default)\nValue 2: Time it takes to change fully in seconds."],
            ['Set Property', "Value 1: Variable name\nValue 2: New value"],
            ['Play Sound', "Value 1: Sound file name\nValue 2: Volume (Default: 1), ranges from 0 to 1"],
    //      -- The Custom AVI events -- 
            ['Add Camera Zoom Chain', 'Value 1: Camera Zoom Intensity\nValue 2: UI Zoom Intensity\n(Leave the values blank to disable the event)'],
            ['Tween BPM', "Value 1: New BPM\nValue 2: Time it takes"],
            ['Show Song Card', 'Triggers the title cards for each song (DOES NOT WORK IN LEGACY SONGS)\n\nValue 1: Intro Bool\nValue 2: Animation delay, Time, Ease type'],
            ['Scroll Type', "Changes Scroll Type, Mid-Song\n \nValue 1 = BF Notes\nValue 2 = Dad Notes\n \nDefault = Normal Scroll Type\nFlip = Flips Current Scroll Type\nDown = Locks Downscroll\nUp = Locks Upscroll\nLeft = Sidescroll from Left\nRight = Sidescroll from Right\nUndyne = Centerscroll"],
		    ['Change Strumline Style', "Value 1: Opponent Note Skin, Player Note Skin\nValue 2: Trigger intro tween?"],
            ['Manage Lyrics', "Value 1: Event Type\nValue 2: Event Data\n\nMove - Text Link, Timer 1, Delay Timer, Timer 2, Ease 1, Ease 2\nData - Text Link, Textbox width, Icon Name\nTween Data - X, Y, Angle, ScaleX, ScaleY, Alpha, X2, Y2, Angle2, ScaleX2, ScaleY2, Alpha2\nText Data - Text Link, Font File, Size, R, G, B, AlignType, Rb, Gb, Bb, Sizeb\nPosition - Text Link, X, Y\nText - Text Link, String, Delay Timer"],
            ['Meta Event', 'Handles 4th wall breaking elements!\n\nValue 1: Meta Value\nValue 2: Meta Data\n\nDiscord - Details Txt, State Txt, Icon Name\nWindow Title - Bool Check for Extra Text, Main Text, Extra Text\nWindow Position - X Pos, Y Pos, Timer, Ease\nToggle Fullscreen - Bool Value\nToggle Fake Closeout - Bool Value\nToggle Window Transparency - Bool Value\nShake Window - Intensity, Duration in milliseconds'],
            ['Cinematic Event', "Creates a cinematic visual in-game\n\nValue 1: Action Type you want\nValue 2: Control inputs for action\n\nMove - Thickness, Duration, Ease name\nBop - Intensity, Speed, Ease name\nAngle - Angle, Duration, Ease name\nFlash - R, G, B, Duration, Ease name\nColor - R, G, B, Duration, Ease name\nAlpha - Visibility, Duration, Ease name\n\n(You must use the \"Move\" action type first before\nusing any other action! Move creates the bars!)"],
            ['Camera Event', "A series of customizers and event types that\nchanges the camera behavior!\n\nValue 1: Name of event you want\nValue 2: Controls the event\n\nStart Hidden - makes the song start off hidden no matter where you place the event!\nChange Value - Value Name, Value Input\nTween Value - Value Name, Value Input, Duration, Ease type\nShake - Intensity, Duration, Game or HUD\nFade - R, G, B, Duration, Alpha, Fade In Bool Toggle\nFlash - R, G, B, Duration, Alpha, Blend Bool Toggle\nChange Pos/Set Position - X Pos, Y Pos\nTween Position: X Pos, Y Pos, Duration, Ease type\nSnap Position: X Pos, Y Pos\n\n(Please refer to documentation or code that comes with this for\nvalid value names for \"Tween Value\" & \"Change Value\")"],
            ['Background Controls', "A series of customizers and event types that\nchanges the background's behavior!\n\nValue 1: Name of event you want\nValue 2: Controls the event\n\nFlash - Time, Ease type, Visibility, Colors (IN RGB FORM!!!)\nDarken - Visibility, Time, Ease type\nSet Color - Visibility, Colors (R, G, B)\nTween Color - Visibility, Time, Ease Type, Colors (R, G, B)"],
    //      -- The events used in specific songs --
            ['Change Screen Dimming', "Value 1: Visibility, Time"],
            ['Devilish Events', "Value 1: Event Num"],
            ['Icon Handler', "Value 1: Event num"],
            ['Tween Chromatic Abberation', 'Value 1 - Name of the event\nValue 2 - Event Data\n\nTween - Intensity, Duration\nZoom - Intensity, Duration\nSet - Intensity'],
            ['Toggle Shadow Drop', 'is it NOT obvious?'],
            ['Lunacy Event Thing idk', ""],
            ['Fire Handler', "Value 1: Alpha, Y, Time,, Ease type"],
            ['Rain Handler', "Value 1: Alpha, Time, Ease type"],
            ['Delusional Events', "Value 1: Event Num"],
            ['Trigger Hunted Stuffs', "Value 1: Event Name"],
            ['Bless Events', 'duh 2: electric boogaloo'],
            ['Invert Shit', 'ONLY WORKS IN BLESS\n\nValue 1: Bool to enable/disable\nValue 2: Time, Ease'],
            ['Dad Tween', 'Value 1: Alpha\nValue 2: Time'],
            ['Toggle TV', 'duh'],
            ['Tween Blur', 'Value 1 - Name of the event\nValue 2 - Event Data\n\nTween - Intensity, Duration\nZoom - Intensity, Duration\nSet - Intensity'],
            ['Trigger TG shader shi', 'Value 1: Event Name'],
            ['Mercy Transition', "too lazy to put a description here"],
            ['Mercy Stuff idk', "Value 1: Event Name"],
            ['Remove Health', "Value 1: How much health to remove"],
            ['Relapse Gimmick', "Value 1:\nReaction Time (Default is 2),\nDamage Amount (Default is 0.4),\nDouble Barrel Bool (Default is false)"],
            ['Relapse Events', "Value 1: Event Num"],
            ['Change Dads Cam Offset', "Value 1: X Offset\nValue 2: Y Offset"],
            ['Add Mal Shaders', "No Description"],
            ['Malfunction Countdown', "Value 1: Countdown Number"],
            ['Static Event', "Value 1: Determines what this triggers\nValue 2: Additional value input if needed\n\nValue 1 Inputs available:\n- togglevis\n- setalpha\n- twnalpha\n- settime"],
            ['Change Mal BG', "Value 1: Determines what this triggers\nValue 2: Additional value input if needed\n\nValue 1 Inputs available:\n- togglevis\n- setalpha\n- changebg"],
            ['No Signal Event', "Value 1: Determines what this triggers\nValue 2: Additional value input if needed\n\nValue 1 Inputs available:\n- togglevis\n- setalpha\n- changebg"],
            ['Tween Char Scale', "Value 1: Event Name"],
            ['Mania BG Flash', "Value 1 Info: Customizer for how the flash will work\nValue 2 Info: Whether only the sky or the whole BG will flash\n\nValue 1: timer, ease, alpha, red value, green value, blue value\nValue 2: sky or all"]
            
        ];
        return default_events;
    }
}