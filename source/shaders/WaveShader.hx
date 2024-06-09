package shaders;

import flixel.system.FlxAssets.FlxShader;

class Wave {
    public var shader(default, null):WaveShader = new WaveShader();
    public var updateShader(default, set):Float = 0;

    private function set_updateShader(value:Float) {
        updateShader = value;
        shader.iTime.value = [updateShader];
        return updateShader;
    }

    public function new() {
        shader.iTime.value = [0];
    }
}

class WaveShader extends FlxShader {
    @glFragmentSource('
    //SHADERTOY PORT FIX
    #pragma header
    vec2 uv = openfl_TextureCoordv.xy;
    vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
    vec2 iResolution = openfl_TextureSize;
    uniform float iTime;
    #define iChannel0 bitmap
    #define texture flixel_texture2D
    #define fragColor gl_FragColor
    #define mainImage main
    //****MAKE SURE TO remove the parameters from mainImage.
    //SHADERTOY PORT FIX


    void mainImage()
    {
        float frequency = 8.0;
        float amplitude = 0.05;
        
        vec2 texCoord = fragCoord.xy / iResolution.xy;
        
        vec2 pulse = sin(iTime - frequency * texCoord);
        float dist = 2.0 * length(texCoord.y - 0.5);
        
        vec2 newCoord = texCoord + amplitude * vec2(0.0, pulse.x); // y-axis only; 
        
        vec2 interpCoord = mix(newCoord, texCoord, dist);
        
        fragColor = texture(iChannel0, interpCoord);
    }
    ')
    public function new()
        {
            super();
        }
}