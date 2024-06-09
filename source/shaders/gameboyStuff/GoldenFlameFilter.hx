package shaders.gameboyStuff;

import flixel.system.FlxAssets.FlxShader;

class GoldenFlame {
    public var shader(default, null):GoldenFlameFilter = new GoldenFlameFilter();

    public function new() {
        shader.iTime.value = [0];
    }
}

class GoldenFlameHUD {
    public var shader(default, null):GoldenFlameHUDFilter = new GoldenFlameHUDFilter();

    public function new() {
        shader.interpolation.value = [1];
    }
}

class GoldenFlameHUDFilter extends FlxShader {
    @glFragmentSource("
    #pragma header

    /*
     *
     * Sources!
     * https://www.shadertoy.com/view/ttlfzj
     *
     */
    
    uniform float interpolation = 0.5;
    
    float threshold = 0.125;
    mat2 dither_2 = mat2(0.,1.,1.,0.);
    
    struct dither_tile {
        float height;
    };
    
    vec3 tex2D(sampler2D _tex,vec2 _p)
    {
        vec3 col=texture(_tex,_p).xyz;
        if(.5<abs(_p.x-.5)){
            col=vec3(.1);
        }
        return col;
    }
    
    vec3[8] gb_colors() {
         vec3 gb_colors[8];
         gb_colors[0] = vec3(26., 26., 26.)		/255.;
         gb_colors[1] = vec3(45., 28., 14.)		/255.;
         gb_colors[2] = vec3(77., 45., 6.)	/255.;
         gb_colors[3] = vec3(106., 60., 11.)	/255.;
         gb_colors[4] = vec3(166., 105., 22.)   /255.;
         gb_colors[5] = vec3(227., 167., 43.)      /255.;
         gb_colors[6] = vec3(255., 225., 122.)      /255.;
         gb_colors[7] = vec3(243., 237., 234.)      /255.;
        return gb_colors;
    }
    
    float[8] gb_colors_distance(vec3 color) {
        float distances[8];
        distances[0] = distance(color, gb_colors()[0]);
        distances[1] = distance(color, gb_colors()[1]);
        distances[2] = distance(color, gb_colors()[2]);
        distances[3] = distance(color, gb_colors()[3]);
        distances[4] = distance(color, gb_colors()[4]);
        distances[5] = distance(color, gb_colors()[5]);
        distances[6] = distance(color, gb_colors()[6]);
        distances[7] = distance(color, gb_colors()[7]);
        return distances;
    }
    
    vec3 closest_gb(vec3 color) {
        int best_i = 0;
        float best_d = 2.;
        
        vec3 gb_colors[8] = gb_colors();
        
        for (int i = 0; i < 8; i++) {
            float dis = distance(gb_colors[i], color);;
            if (dis < best_d) {
                best_d = dis;
                best_i = i;
            }
        }
        return gb_colors[best_i];
    }
    
    vec2 get_tile_sample(vec2 coords, vec2 res) {
        return floor(coords * res / 2.) * 2. / res;
    }
    
    vec3[2] gb_2_closest(vec3 color) {
         float distances[8] = gb_colors_distance(color);
        
        int first_i = 0;
        float first_d = 2.;
        
        int second_i = 0;
        float second_d = 2.;
        
        for (int i = 0; i < distances.length(); i++) {
            float d = distances[i];
            if (distances[i] <= first_d) {
                second_i = first_i;
                second_d = first_d;
                first_i = i;
                first_d = d;
            } else if (distances[i] <= second_d) {
                second_i = i;
                second_d = d;
            }
        }
        vec3 colors[8] = gb_colors();
        vec3 result[2];
        if (first_i < second_i)
            result = vec3[2](colors[first_i], colors[second_i]);
        else
             result = vec3[2](colors[second_i], colors[first_i]);   
        return result;
    }
    
    bool needs_dither(vec3 color) {
        float distances[8] = gb_colors_distance(color);
        
        int first_i = 0;
        float first_d = 2.;
        
        int second_i = 0;
        float second_d = 2.;
        
        for (int i = 0; i < distances.length(); i++) {
            float d = distances[i];
            if (d <= first_d) {
                second_i = first_i;
                second_d = first_d;
                first_i = i;
                first_d = d;
            } else if (d <= second_d) {
                second_i = i;
                second_d = d;
            }
        }
        return abs(first_d - second_d) <= threshold;
    }
    
    vec3 return_gbColor(vec3 sampleColor) {
        vec3 endColor;
        if (needs_dither(sampleColor)) {
            endColor = vec3(gb_2_closest(sampleColor)[int(dither_2[openfl_TextureCoordv.x][openfl_TextureCoordv.y])]);
        } else
            endColor = vec3(closest_gb(tex2D(bitmap, openfl_TextureCoordv).xyz));
        return endColor;
    }
    
    vec3 buried_eye_color = vec3(255.0, 0.0, 0.0) / 255.0;
    vec3 buried_grave_color = vec3(121.0, 133.0, 142.0) / 255.0;
    
    void main() {
    
        vec4 color = texture2D(bitmap, openfl_TextureCoordv);
        vec3 sampleColor = color.xyz;
        // gb colors
        vec3 colors[8] = gb_colors();
        if (color.a != 0.0) {
            vec3 colorA = sampleColor;
            vec3 colorB = return_gbColor(sampleColor);
    
            vec3 newColor;
            // if colorA is just buried alive's fucking eye
            if (colorA == buried_eye_color)
                colorB = colors[2];
            if (colorA == buried_grave_color)
                colorB = colors[2];
            newColor = mix(colorA, colorB, interpolation);
            gl_FragColor = vec4(newColor, 1.0);
        } else
            gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
    }
    
    /*
     *
     */
    ")

    public function new() {
        super();
    };
}

class GoldenFlameFilter extends FlxShader {
    @glFragmentSource("
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

    float size = 480.; // Pixelated resolution x-component
    float threshold = .0001; // Threshold for dithering (0.0045 found to be optimal)
    mat2 dither_2 = mat2(0.,1.,1.,0.);

    struct dither_tile {
        float height;
    };


    vec3[8] gb_colors() {
        vec3 gb_colors[8];
        gb_colors[0] = vec3(26., 26., 26.)		/255.;
         gb_colors[1] = vec3(45., 28., 14.)		/255.;
         gb_colors[2] = vec3(77., 45., 6.)	/255.;
         gb_colors[3] = vec3(106., 60., 11.)	/255.;
         gb_colors[4] = vec3(166., 105., 22.)   /255.;
         gb_colors[5] = vec3(227., 167., 43.)      /255.;
         gb_colors[6] = vec3(255., 225., 122.)      /255.;
         gb_colors[7] = vec3(243., 237., 234.)      /255.;
       return gb_colors;
   }
   
   float[8] gb_colors_distance(vec3 color) {
       float distances[8];
       distances[0] = distance(color, gb_colors()[0]);
       distances[1] = distance(color, gb_colors()[1]);
       distances[2] = distance(color, gb_colors()[2]);
       distances[3] = distance(color, gb_colors()[3]);
       distances[4] = distance(color, gb_colors()[4]);
       distances[5] = distance(color, gb_colors()[5]);
       distances[6] = distance(color, gb_colors()[6]);
       distances[7] = distance(color, gb_colors()[7]);
       return distances;
   }
   
   vec3 closest_gb(vec3 color) {
       int best_i = 0;
       float best_d = 2.;
       
       vec3 gb_colors[8] = gb_colors();
       
       for (int i = 0; i < 8; i++) {
           float dis = distance(gb_colors[i], color);;
           if (dis < best_d) {
               best_d = dis;
               best_i = i;
           }
       }
       return gb_colors[best_i];
   }
   

    vec2 get_tile_sample(vec2 coords, vec2 res) {
        return floor(coords * res / 2.) * 2. / res;
    }

    vec3[2] gb_2_closest(vec3 color) {
        float distances[8] = gb_colors_distance(color);
        
        int first_i = 0;
        float first_d = 2.;
        
        int second_i = 0;
        float second_d = 2.;
        
        for (int i = 0; i < distances.length(); i++) {
            float d = distances[i];
            if (distances[i] <= first_d) {
                second_i = first_i;
                second_d = first_d;
                first_i = i;
                first_d = d;
            } else if (distances[i] <= second_d) {
                second_i = i;
                second_d = d;
            }
        }
        vec3 colors[8] = gb_colors();
        vec3 result[2];
        if (first_i < second_i) {
            result = vec3[2](colors[first_i], colors[second_i]);
        } else {
            result = vec3[2](colors[second_i], colors[first_i]);   
        }
        
        
        return result;
    }

    bool needs_dither(vec3 color) {
        float distances[8] = gb_colors_distance(color);
        
        int first_i = 0;
        float first_d = 2.;
        
        int second_i = 0;
        float second_d = 2.;
        
        for (int i = 0; i < distances.length(); i++) {
            float d = distances[i];
            if (d <= first_d) {
                second_i = first_i;
                second_d = first_d;
                first_i = i;
                first_d = d;
            } else if (d <= second_d) {
                second_i = i;
                second_d = d;
            }
        }
        return abs(first_d - second_d) <= threshold;
    }

    void mainImage() {

        vec2 resolution = vec2(size, iResolution.y / iResolution.x * size);
        vec2 uv = floor(fragCoord/iResolution.xy * resolution) / resolution;
        
        vec2 tileSample = get_tile_sample(uv, resolution);
        vec3 sampleColor = texture(iChannel0, tileSample).xyz;
        
        vec3 colors[2] = vec3[2](vec3(1.,1.,1.), vec3(0.,0.,0.));
        
        if (needs_dither(sampleColor)) {
            ivec2 ti = ivec2(floor((uv - tileSample) * 2. * resolution));
            //fragColor = vec4(closest_gb(texture(iChannel0, uv).xyz),1.0);
            fragColor = vec4(gb_2_closest(sampleColor)[int(dither_2[ti.x][ti.y])], 1.);
            
            //fragColor = vec4(colors[int(dither_2[ti.x][ti.y])], 1.);
        } else {
            fragColor = vec4(closest_gb(texture(iChannel0, uv).xyz),1.0);
        }
        
        // Output to screen
        
    }
    " )

    public function new()
        {
            super();
        }
}