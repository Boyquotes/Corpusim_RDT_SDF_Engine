// adapted from thebookofshaders.com "lava lamp"
// https://thebookofshaders.com/edit.php#11/lava-lamp.frag

shader_type sky;
render_mode use_half_res_pass;
render_mode disable_fog;

vec3 mod289_3(vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec2 mod289_2(vec2 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec3 permute(vec3 x) { return mod289_3(((x*34.0)+1.0)*x); }

uniform float repetition = 5.0;
uniform float seam_size : hint_range(0.0, 5.) = 0.;
uniform float speed : hint_range(0.0, 2.) = 1.;
uniform vec3 colorA : source_color = vec3(1.);
uniform vec3 colorB : source_color = vec3(0.);

uniform float patch_start : hint_range(0.05, 0.95);
uniform float patch_size : hint_range(0.05,0.95);


float snoise(vec2 v) {
    const vec4 C = vec4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
                        0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
                        -0.577350269189626,  // -1.0 + 2.0 * C.x
                        0.024390243902439); // 1.0 / 41.0
    vec2 i  = floor(v + dot(v, C.yy) );
    vec2 x0 = v -   i + dot(i, C.xx);
    vec2 i1;
    i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    vec4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;
    i = mod289_2(i); // Avoid truncation effects in permutation
    vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
        + i.x + vec3(0.0, i1.x, 1.0 ));

    vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
    m = m*m ;
    m = m*m ;
    vec3 x = 2.0 * fract(p * C.www) - 1.0;
    vec3 h = abs(x) - 0.5;
    vec3 ox = floor(x + 0.5);
    vec3 a0 = x - ox;
    m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );
    vec3 g;
    g.x  = a0.x  * x0.x  + h.x  * x0.y;
    g.yz = a0.yz * x12.xz + h.yz * x12.yw;
    return 130.0 * dot(m, g);
}

vec2 sphereProject(vec2 q){
	float phi = (2.*q.y-1.)*PI/2.;
	return vec2((2.*q.x-1.)*cos(phi), q.y );
}

void sky() {
	float time = TIME * speed;
	
	vec2 st = sphereProject(SKY_COORDS.xy);
	
    vec3 color = vec3(0.0);
    vec2 pos = vec2(st*repetition);

    float DF = 0.0;

    // Add a random position
    float a = 0.0;
    vec2 vel = vec2(time*.1);
    DF += snoise(pos+vel)*.25+.25;

    // Add a random position
    a = snoise(pos*vec2(cos(time*0.15),sin(time*0.1))*0.1)*3.1415;
    vel = vec2(cos(a),sin(a));
    DF += snoise(pos+vel)*.25+.25;

	float seam = seam_size*(smoothstep(0.86,1.,SKY_COORDS.x)+smoothstep(.14,0.,SKY_COORDS.x) );
	float d = smoothstep(patch_start,patch_start+patch_size+seam,fract(DF));
    COLOR = vec3(colorA)*d  + vec3(colorB)*(1.-d);
	
}
