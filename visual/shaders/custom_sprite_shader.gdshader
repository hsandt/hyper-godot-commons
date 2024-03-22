shader_type canvas_item;

uniform float brightness : hint_range(0.0, 1.0) = 0.0;

// Custom modulate varying parameter, set it in vertex to COLOR when it is still just
// MODULATE (inaccessible in Godot 4), then retrieve it in fragment and use it
// See https://github.com/godotengine/godot/issues/49781 CiberTurtle's answer
varying flat vec4 modulate;

// Source: https://www.shadertoy.com/view/wt23Rt
// which itself uses several sources, but adapted the code each time
// For rgb2hsl, we chose a direct implementation not going through HSV
// to avoid issues with pure black & white becoming black at any brightness.
// For hsl2rgb, most versions work fine as it's much more simple.

vec3 saturate(vec3 v){
	return clamp(v,0.,1.);
}

// Hue to RGB (red, green, blue).
// Source: https://github.com/tobspr/GLSL-Color-Spaces/blob/master/ColorSpaces.inc.glsl
vec3 hue2rgb(float hue){
	hue=fract(hue);
	return saturate(vec3(
		abs(hue*6.-3.)-1.,
		2.-abs(hue*6.-2.),
		2.-abs(hue*6.-4.)
	));
}

// RGB to HSL (hue, saturation, lightness/luminance).
// Source: https://gist.github.com/yiwenl/745bfea7f04c456e0101
// (adapted)
vec3 rgb2hsl(vec3 c){
	float cMin=min(min(c.r,c.g),c.b),
		  cMax=max(max(c.r,c.g),c.b),
		  delta=cMax-cMin;
	vec3 hsl=vec3(0.,0.,(cMax+cMin)/2.);
	if(delta!=0.0){ //If it has chroma and isn't gray.
		if(hsl.z<.5){
			hsl.y=delta/(cMax+cMin); //Saturation.
		}else{
			hsl.y=delta/(2.-cMax-cMin); //Saturation.
		}
		float deltaR=(((cMax-c.r)/6.)+(delta/2.))/delta,
			  deltaG=(((cMax-c.g)/6.)+(delta/2.))/delta,
			  deltaB=(((cMax-c.b)/6.)+(delta/2.))/delta;
		//Hue.
		if(c.r==cMax){
			hsl.x=deltaB-deltaG;
		}else if(c.g==cMax){
			hsl.x=(1./3.)+deltaR-deltaB;
		}else{ //if(c.b==cMax){
			hsl.x=(2./3.)+deltaG-deltaR;
		}
		hsl.x=fract(hsl.x);
	}
	return hsl;
}

// HSL to RGB.
// Source: https://github.com/Jam3/glsl-hsl2rgb/blob/master/index.glsl
// (adapted to use hue2rgb)
vec3 hsl2rgb(vec3 hsl){
	if(hsl.y==0.){
		return vec3(hsl.z); //Luminance.
	}else{
		float b;
		if(hsl.z<.5){
			b=hsl.z*(1.+hsl.y);
		}else{
			b=hsl.z+hsl.y-hsl.y*hsl.z;
		}
		float a=2.*hsl.z-b;
		return a+hue2rgb(hsl.x)*(b-a);
	}
}

void vertex() {
	modulate = COLOR;
}

void fragment() {
	// Retrieve texture color
	vec4 tex = texture(TEXTURE, UV);

	// Convert RGB to HSL
	vec3 hsl = rgb2hsl(tex.rgb);

	// Increase lightness based on brightness parameter
	float lightness = hsl.z;
	lightness = mix(lightness, 1, brightness);
	hsl.z = lightness;

	// Convert HSL back to RGB
	vec3 brightened_color = hsl2rgb(hsl);

	// Inject texture alpha
	vec4 col = vec4(brightened_color, tex.a);

	// Apply custom modulate parameter
	COLOR = col * modulate;
}
