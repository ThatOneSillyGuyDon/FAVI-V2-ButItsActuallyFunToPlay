package shaders;

import flixel.system.FlxAssets.FlxShader;

class OutlineEffect {
    public var shader(default, null):OutlineShader = new OutlineShader();
    public var thickness(default, set):Float = 0.0;

    private function set_thickness(value:Float) {
        thickness = value;
		shader.thickness.value = [thickness];
		return thickness;
    }

    public function new()
    {
        shader.thickness.value = [4.5];
    }
}

class OutlineShader extends FlxShader {
    @:glFragmentSource("
    #pragma header
	vec2 uv = openfl_TextureCoordv.xy;
    vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
    vec2 iResolution = openfl_TextureSize;
    uniform float iTime;
    #define iChannel0 bitmap
    #define iChannel1 bitmap
    #define iChannel2 bitmap
    #define iChannelResolution bitmap
    #define texture flixel_texture2D
    #define fragColor gl_FragColor
    #define mainImage main
    uniform float uTime;
    uniform vec4 iMouse;
    uniform float thickness;
	
	void mainImage()
	{


		vec2 uv = fragCoord/iResolution.xy;
		
		vec2 off = thickness / iResolution.xy;

		
		vec4 col = vec4(0.);;

		vec4 c1 = texture(iChannel0, uv);
		vec4 c2 = texture(iChannel0, uv + vec2(off.x, 0.));
		vec4 c3 = texture(iChannel0, uv + vec2(0., off.y));

		
		col = vec4(length((c1 - c2) + (c1 - c3)));
		
		
		
		
		fragColor = col;
	}")

    public function new()
    {
        super();
    }
}