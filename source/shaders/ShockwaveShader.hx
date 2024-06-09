package shaders;

import flixel.system.FlxAssets.FlxShader;

class Shockwave {
    public var shader(default, null):ShockwaveShader = new ShockwaveShader();
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

class ShockwaveShader extends FlxShader {
    @glFragmentSource(
       "//SHADERTOY PORT FIX
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
       
       void mainImage() {
            // Sawtooth calc of time
            float offset = (iTime - floor(iTime)) / iTime;
            float time = iTime * offset;
        
            // Wave design params
            vec3 waveParams = vec3(10.0, 0.8, 0.1 );
            
            // Find coordinate, flexible to different resolutions
            float maxSize = max(iResolution.x, iResolution.y);
            vec2 uv = fragCoord.xy / maxSize;
            
            // Find center, flexible to different resolutions
            vec2 center = iResolution.xy / maxSize / 2.;
        
            // Distance to the center
            float dist = distance(uv, center);
            
            // Original color
            vec4 c = texture(iChannel0, uv);
            
            // Limit to waves
            if (time > 0. && dist <= time + waveParams.z && dist >= time - waveParams.z) {
                // The pixel offset distance based on the input parameters
                float diff = (dist - time);
                float diffPow = (1.0 - pow(abs(diff * waveParams.x), waveParams.y));
                float diffTime = (diff  * diffPow);
        
                // The direction of the distortion
                vec2 dir = normalize(uv - center);
                
                // Perform the distortion and reduce the effect over time
                uv += ((dir * diffTime) / (time * dist * 80.0));
                
                // Grab color for the new coord
                c = texture(iChannel0, uv);
        
                // Optionally: Blow out the color for brighter-energy origin
                //c += (c * diffPow) / (time * dist * 40.0);
            }
            
            fragColor = c;
        }"
    )
    public function new()
        {
            super();
        }
}