package shaders;

import flixel.system.FlxAssets.FlxShader;

class ChromShockwave {
    public var shader(default, null):ChromShockwaveShader = new ChromShockwaveShader();
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

class ChromShockwaveShader extends FlxShader {
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
        
        float rand(vec2 co){
            return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
        }
        
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
            
            time = pow(time, 0.55);
            
            // Original color
            vec4 c = texture(iChannel0, uv);
            
            if (time > 0. && dist <= time + waveParams.z && dist >= time - waveParams.z) {
              
                // The pixel offset distance based on the input parameters
                float diff = (dist - time);
                float diffPow = (1.0 - pow(abs(diff * waveParams.x), waveParams.y));
                float diffTime = (diff  * diffPow);
        
                // The direction of the distortion
                vec2 dir = normalize(uv - center);
                
                
                uv.x += (rand(vec2(iTime,fragCoord.y))-1.0) / ((time * dist * 3000.0));
                
                // Perform the distortion and reduce the effect over time
                uv += ((dir * diffTime) / (time * dist * 20.0)) * (dist / 2.0);
                
        
                c = texture(iChannel0, uv);
        
                vec4 red = texture(iChannel0, vec2(uv.x - (0.2 / (time* dist * 500.0)), uv.y)) * vec4(1.0, 0.0, 0.0,1.0);
                vec4 green = texture(iChannel0, vec2(uv.x + (0.2 / (time* dist * 500.0)) , uv.y))
                   * vec4(0.0, 1.00, 0.0,1.0);
                vec4 blue  = texture(iChannel0, vec2(uv.x, uv.y)) * vec4(0.0, 0.0, 1.0,1.0);
                c += red + green + blue;
                c /= 2.;
            }
            
            if (c.r > 0.2) c.a = 0.0;
            
            fragColor = c;
        }"
    )
    public function new()
        {
            super();
        }
}