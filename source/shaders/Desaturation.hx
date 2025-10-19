package shaders;

import flixel.system.FlxAssets.FlxShader;

class Desaturation {
    public var shader(default, null):DesaturationFilter = new DesaturationFilter();
    public var desaturationAmount(default, set):Float = 0;

    private function set_desaturationAmount(value:Float) {
        desaturationAmount = value;
        shader.desaturationAmount.value = [desaturationAmount];
        return desaturationAmount;
    }

    public function new() {
        shader.desaturationAmount.value = [0.0];
    }
}

class DesaturationFilter extends FlxShader {
    @glFragmentSource(
        " #pragma header

    uniform float desaturationAmount = 0.0;
    uniform float distortionTime = 0.0;
    uniform float amplitude = -0.1;
    uniform float frequency = 8.0;
    
    void main() {
        vec4 desatTexture = texture2D(bitmap, vec2(openfl_TextureCoordv.x + sin((openfl_TextureCoordv.y * frequency) + distortionTime) * amplitude, openfl_TextureCoordv.y));
        gl_FragColor = vec4(mix(vec3(dot(desatTexture.xyz, vec3(.2126, .7152, .0722))), desatTexture.xyz, desaturationAmount), desatTexture.a);
    }"
    )
    public function new()
        {
            super();
        }
}