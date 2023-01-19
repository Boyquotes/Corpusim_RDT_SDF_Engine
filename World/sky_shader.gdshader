// Adapts work from "lava lamp", Patricio Gonzalez
// and 3D noise by Inigo Quilez

shader_type sky;
render_mode use_half_res_pass;
render_mode disable_fog;

vec3 mod289_3(vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec2 mod289_2(vec2 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec3 permute(vec3 x) { return mod289_3(((x*34.0)+1.0)*x); }

uniform float repetition : hint_range(.5,40.) = 5.0;
uniform float speed : hint_range(0.0, 2.) = 1.;
uniform vec3 colorA : source_color = vec3(1.);
uniform vec3 colorB : source_color = vec3(0.);

uniform float patch_start : hint_range(0.05, 0.95);
uniform float patch_size : hint_range(0.05,0.95);

vec3 hash(vec3 p) {
    p = vec3(dot(p, vec3(127.1, 311.7, 74.7)),
             dot(p, vec3(269.5, 183.3, 246.1)),
             dot(p, vec3(113.5, 271.9, 124.6)));

    return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
}

float noise3D(vec3 p){
	vec3 i = floor(p);
	vec3 f = fract(p);
	vec3 u = f * f * (3.0 - 2.0 * f);

	return mix(mix(mix(dot(hash(i + vec3(0.0, 0.0, 0.0)), f - vec3(0.0, 0.0, 0.0)),
		dot(hash(i + vec3(1.0, 0.0, 0.0)), f - vec3(1.0, 0.0, 0.0)), u.x),
		mix(dot(hash(i + vec3(0.0, 1.0, 0.0)), f - vec3(0.0, 1.0, 0.0)),
		dot(hash(i + vec3(1.0, 1.0, 0.0)), f - vec3(1.0, 1.0, 0.0)), u.x), u.y),
		mix(mix(dot(hash(i + vec3(0.0, 0.0, 1.0)), f - vec3(0.0, 0.0, 1.0)),
		dot(hash(i + vec3(1.0, 0.0, 1.0)), f - vec3(1.0, 0.0, 1.0)), u.x),
		mix(dot(hash(i + vec3(0.0, 1.0, 1.0)), f - vec3(0.0, 1.0, 1.0)),
		dot(hash(i + vec3(1.0, 1.0, 1.0)), f - vec3(1.0, 1.0, 1.0)), u.x), u.y), u.z );
		
}

float fbm(vec3 p)
{
	float f;
    f = noise3D(p); p*2.01;
	f += 0.5*noise3D( p ); p = p*2.02;
    //f += .25*noise3D( p ); p = p*2.03; 
    //f += .125*noise3D( p ); p = p*2.04;
    //f += .0625*noise3D( p ); p = p*2.05;
    //f += .03125*noise3D( p );
	return f;
}

vec3 sphereProject(vec2 q){
	float theta = q.y * 3.14159;
	float phi = q.x * 3.14159 * 2.0;
	vec3 unit = vec3(0.0, 0.0, 0.0);

	unit.x = sin(phi) * sin(theta);
	unit.y = cos(theta) * -1.0;
	unit.z = cos(phi) * sin(theta);
	return normalize(unit);	
}


void sky() {
	float time = TIME * speed;
	
	vec3 st = sphereProject(SKY_COORDS.xy);
	
    vec3 color = vec3(0.0);
    vec3 pos = vec3(st*repetition);

    float DF = 0.0;

    // Add a random position
    float a = 0.0;
    vec3 vel = vec3(time)*3.;
	DF += fbm(pos+vel)*.25+.25;

    // Add a random position
    a = noise3D(pos* vec3(cos(time*0.15),sin(time*0.1),sin(time*0.13)) *0.1)*3.1415;
    vel = vec3(cos(a),sin(a),sin(a));
    DF += noise3D(pos+vel)*.25+.25;

	
	float d = smoothstep(patch_start,patch_start+patch_size,fract(DF));
    COLOR = vec3(colorA)*d  + vec3(colorB)*(1.-d);
	
}
