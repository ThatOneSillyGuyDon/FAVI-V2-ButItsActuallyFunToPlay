package gameObjects.ui;

/**
 * SpectrumWaveform by mr_chaoss
 * 
 * thx so much for lending me this code (don)
 * 
 * **/

import haxe.Json;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.system.FlxSound;
import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

using StringTools;
using flixel.util.FlxSpriteUtil;

// Define some constants
enum abstract SpectrumAlignment(String) from String to String {
    var FROM_UP_TO_DOWN = "{\"name\": \"FROM_UP_TO_DOWN\", \"axe\": \"X\"}";
    var TO_UP_TO_DOWN = "{\"name\": \"TO_UP_TO_DOWN\", \"axe\": \"X\"}";
    var TO_UP_FROM_DOWN = "{\"name\": \"TO_UP_FROM_DOWN\", \"axe\": \"X\"}";
    
    var FROM_LEFT_TO_RIGHT = "{\"name\": \"FROM_LEFT_TO_RIGHT\", \"axe\": \"Y\"}";
    var TO_LEFT_TO_RIGHT = "{\"name\": \"TO_LEFT_TO_RIGHT\", \"axe\": \"Y\"}";
    var TO_LEFT_FROM_RIGHT = "{\"name\": \"TO_LEFT_FROM_RIGHT\", \"axe\": \"Y\"}";

    public var axe(get, never):FlxAxes;
    function get_axe():FlxAxes {
        var config:Dynamic = Json.parse(this);
        return FlxAxes.fromString(config.axe);
    }
}

enum SpectrumDesign {
    DEFAULT;
    ROUNDED;
}

class SpectrumWaveform extends FlxSpriteGroup {
    // Define some constants
    static inline var SAMPLE_RATE:Int = 2048;
    static inline var MAX_AMPLITUDE:Int = 65535;
    static inline var LERP_SPEED:Float = 30;

    @:noPrivateAccess var elapsed:Float = 0;
    @:noPrivateAccess var previous:Int = 0;

    public var numBars(default, null):Int;
    public var sound(default, set):FlxSound = null;

    // customization shit
    public var alignment:SpectrumAlignment = TO_UP_TO_DOWN;
    public var barWidth:Float = 15;
    public var barSpacing:Float = 33;
    public var barScale:Float = 1;
    public var formLength:Int = 0;
    public var maxHeight:Float = 0;
    public var dynamicAlpha:Bool = true;
    public var design:SpectrumDesign = DEFAULT;
    public var roundValue:Float = 10;
    
    function set_sound(value:FlxSound):FlxSound {
        sound = value;
        numBars = get_numBars();
        return value;
    }

    public function new(x:Float = 0, y:Float = 0, sound:FlxSound = null, formLength:Int, maxHeight:Float, alignment:SpectrumAlignment = TO_UP_TO_DOWN, design:SpectrumDesign = DEFAULT, color:FlxColor = FlxColor.WHITE) {
        super(x, y);
        this.formLength = formLength <= 0 ? FlxG.width : formLength;
        this.maxHeight = maxHeight;
        this.alignment = alignment;
        this.design = design;
        this.sound = sound;
        this.color = color;
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        this.elapsed += elapsed;
        if (previous != Math.floor(this.elapsed * SAMPLE_RATE)) {
            if (sound != null && sound.playing) {
                updateSamples();
            } else {
                spectrum = [];
                
                for (i in 0...numBars)
                    spectrum.push(0);
            }
            updateWaveform(elapsed);
        }
        previous = Math.floor(this.elapsed * SAMPLE_RATE);
    }

    public var spectrum:Array<Float> = [];
    public var lerpSpectrum:Array<Float> = [];
    public function updateSamples() {
        @:privateAccess {
            var index:Int = Math.floor(sound.time * (sound._sound.__buffer.sampleRate / 1000));

            spectrum = [];

            for (i in index...index + numBars) {
                if (i >= 0) {
                    var byte:Int = sound._sound.__buffer.data.buffer.getUInt16(i * sound._sound.__buffer.channels * 2);

                    if (byte > MAX_AMPLITUDE / 2)
                        byte -= MAX_AMPLITUDE;

                    spectrum.push(Math.abs(byte / MAX_AMPLITUDE));
                }
            }
        }
    }

    public function updateWaveform(elapsed:Float) {
        clear();

        var curHeight:Float = 0;
        for (i in 0...Std.int(formLength / (barSpacing - 1))) {
            var spec:Float = spectrum[Math.floor(i * (barSpacing - 1))];

            lerpSpectrum[i] = FlxMath.lerp(spec, lerpSpectrum[i], Math.max(0, Math.min(1, 1 - elapsed * LERP_SPEED)));
            var barHeight:Float = lerpSpectrum[i] * 1000 * barScale;
            if (barHeight > maxHeight)
                barHeight = maxHeight;

            if (dynamicAlpha) {
                if (barHeight > curHeight) {
                    if (barHeight > maxHeight)
                        curHeight = maxHeight;
                    else
                        curHeight = barHeight;
                }
            }

            var spr:FlxSprite = new FlxSprite();
            if (alignment.axe == X) {
                spr.setPosition(i * barSpacing, switch(alignment) {
                    case TO_UP_TO_DOWN: -barHeight / 2;
                    case TO_UP_FROM_DOWN: -barHeight;
                    default: 0;
                });
                spr.makeGraphic(Std.int(barWidth), Std.int(barHeight), FlxColor.TRANSPARENT);
                switch(design) {
                    case DEFAULT:
                        spr.drawRect(0, 0, Std.int(barWidth), Std.int(barHeight), color);
                    case ROUNDED:
                        spr.drawRoundRect(0, 0, Std.int(barWidth), Std.int(barHeight), roundValue, roundValue, color);
                }
            } else if (alignment.axe == Y) {
                spr.setPosition(switch(alignment) {
                    case TO_LEFT_TO_RIGHT: -barHeight / 2;
                    case TO_LEFT_FROM_RIGHT: -barHeight;
                    default: 0;
                }, i * barSpacing);
                spr.makeGraphic(Std.int(barHeight), Std.int(barWidth), FlxColor.TRANSPARENT);
                switch(design) {
                    case DEFAULT:
                        spr.drawRect(0, 0, Std.int(barHeight), Std.int(barWidth), color);
                    case ROUNDED:
                        spr.drawRoundRect(0, 0, Std.int(barHeight), Std.int(barWidth), roundValue, roundValue, color);
                }
            }
            spr.alpha = dynamicAlpha ? (barHeight / curHeight) : 1;
            spr.updateHitbox();
            add(spr);
        }
    }

    function get_numBars():Int {
        var n:Int = SAMPLE_RATE;
        var m:Float = n;
        while (true) {
            m = n;
            while (m % 2 == 0)
                m /= 2;
            while (m % 3 == 0)
                m /= 3;
            while (m % 5 == 0)
                m /= 5;
            if (m <= 1)
                break;
            n++;
        }
        return n;
    }
}