shader_type spatial;
//render_mode unshaded;// depth_draw_never; depth_draw_opaque;
render_mode depth_draw_opaque;

uniform vec3 u_bb_center = vec3(0);
uniform float u_bb_size = 0.55;

const int MAX_STEPS = 64;
const float MAX_DISTANCE = 100.0;
const float SURFACE_DISTANCE = 0.005;
const float NORMAL_PRECISION = 0.0005;

vec3 mod289_3(vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec2 mod289_2(vec2 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec3 permute(vec3 x) { return mod289_3(((x*34.0)+1.0)*x); }
vec3 hash(vec3 p) {
    p = vec3(dot(p, vec3(127.1, 311.7, 74.7)),
             dot(p, vec3(269.5, 183.3, 246.1)),
             dot(p, vec3(113.5, 271.9, 124.6)));

    return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
}

void vertex() {
	POSITION = vec4(VERTEX, 1.0);
}

float dot2( in vec3 v ) {
	 return dot(v,v); 
}

float rand3d(vec3 p)
{
	return fract(sin(dot(p ,vec3(12.9898,78.233,128.852))) * 43758.5453)*2.0-1.0;
}


float noise3D(vec3 p)
{
	
	float f3 = 1.0/3.0;
	float s = (p.x+p.y+p.z)*f3;
	int i = int(floor(p.x+s));
	int j = int(floor(p.y+s));
	int k = int(floor(p.z+s));
	
	float g3 = 1.0/6.0;
	float t = float((i+j+k))*g3;
	float x0 = float(i)-t;
	float y0 = float(j)-t;
	float z0 = float(k)-t;
	x0 = p.x-x0;
	y0 = p.y-y0;
	z0 = p.z-z0;
	
	int i1,j1,k1;
	int i2,j2,k2;
	
	if(x0>=y0)
	{
		if(y0>=z0){ i1=1; j1=0; k1=0; i2=1; j2=1; k2=0; } // X Y Z order
		else if(x0>=z0){ i1=1; j1=0; k1=0; i2=1; j2=0; k2=1; } // X Z Y order
		else { i1=0; j1=0; k1=1; i2=1; j2=0; k2=1; }  // Z X Z order
	}
	else 
	{ 
		if(y0<z0) { i1=0; j1=0; k1=1; i2=0; j2=1; k2=1; } // Z Y X order
		else if(x0<z0) { i1=0; j1=1; k1=0; i2=0; j2=1; k2=1; } // Y Z X order
		else { i1=0; j1=1; k1=0; i2=1; j2=1; k2=0; } // Y X Z order
	}
	
	float x1 = x0 - float(i1) + g3; 
	float y1 = y0 - float(j1) + g3;
	float z1 = z0 - float(k1) + g3;
	float x2 = x0 - float(i2) + 2.0*g3; 
	float y2 = y0 - float(j2) + 2.0*g3;
	float z2 = z0 - float(k2) + 2.0*g3;
	float x3 = x0 - 1.0 + 3.0*g3; 
	float y3 = y0 - 1.0 + 3.0*g3;
	float z3 = z0 - 1.0 + 3.0*g3;	
				 
	// Godot choking on `vec3(int,int,int)` 
	vec3 ijk0 = vec3(float(i),float(j),float(k));
	vec3 ijk1 = vec3(float(i+i1),float(j+j1),float(k+k1));
	vec3 ijk2 = vec3(float(i+i2),float(j+j2),float(k+k2));
	vec3 ijk3 = vec3(float(i+1),float(j+1),float(k+1));
            
	vec3 gr0 = normalize(vec3(rand3d(ijk0),rand3d(ijk0*2.01),rand3d(ijk0*2.02)));
	vec3 gr1 = normalize(vec3(rand3d(ijk1),rand3d(ijk1*2.01),rand3d(ijk1*2.02)));
	vec3 gr2 = normalize(vec3(rand3d(ijk2),rand3d(ijk2*2.01),rand3d(ijk2*2.02)));
	vec3 gr3 = normalize(vec3(rand3d(ijk3),rand3d(ijk3*2.01),rand3d(ijk3*2.02)));
	
	float n0 = 0.0;
	float n1 = 0.0;
	float n2 = 0.0;
	float n3 = 0.0;

	float t0 = 0.5 - x0*x0 - y0*y0 - z0*z0;
	if(t0>=0.0)
	{
		t0*=t0;
		n0 = t0 * t0 * dot(gr0, vec3(x0, y0, z0));
	}
	float t1 = 0.5 - x1*x1 - y1*y1 - z1*z1;
	if(t1>=0.0)
	{
		t1*=t1;
		n1 = t1 * t1 * dot(gr1, vec3(x1, y1, z1));
	}
	float t2 = 0.5 - x2*x2 - y2*y2 - z2*z2;
	if(t2>=0.0)
	{
		t2 *= t2;
		n2 = t2 * t2 * dot(gr2, vec3(x2, y2, z2));
	}
	float t3 = 0.5 - x3*x3 - y3*y3 - z3*z3;
	if(t3>=0.0)
	{
		t3 *= t3;
		n3 = t3 * t3 * dot(gr3, vec3(x3, y3, z3));
	}
	return 96.0*(n0+n1+n2+n3);
	
}

float fbm(vec3 p)
{
	float f;
    f = noise3D(p); p*2.01;
	f += 0.5*noise3D( p ); p = p*2.02;
	return f;
}

float get_sphere(vec3 p, vec3 center, float radius) {
	return length(p - center) - radius;
}

float sharp_union(float a, float b) {
	return min(a, b);
}

float smooth_union(float a, float b, float k) {
	float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
	return mix(b, a, h) - k * h * (1.0 - h);
}

vec4 smooth_union_c(float da, float db, vec3 ca, vec3 cb, float k) {
	float h = clamp(0.5 + 0.5 * (db - da) / k, 0.0, 1.0);
	float d = mix(db, da, h) - k * h * (1.0 - h);
	vec3 col = mix(cb, ca, h);
	return vec4(col, d);
}

vec3 smooth_color(float da, float db, vec3 ca, vec3 cb, float k) {
	float h = clamp(0.5 + 0.5 * (db - da) / k, 0.0, 1.0);
	vec3 col = mix(cb, ca, h);
	return col;
}

vec4 smooth_subtract_c(float db, float da, vec3 ca, vec3 cb, float k) {
	float h = clamp(0.5 - 0.5 * (db + da) / k, 0.0, 1.0);
    float d = mix(db, -da, h) + k * h * (1.0 - h);
	vec3 col = mix(ca, cb, h);
	return vec4(col, d);
}

float subtract(float a, float b) {
	return max(a, -b);
}

float intersect(float a, float b) {
	return max(a, b);
}

vec3 repeat_domain_inf(vec3 p, vec3 c) {
	return mod(p + 0.5 * c, c) - 0.5 * c;
}

vec3 repeat_domain(vec3 p, vec3 c, vec3 l) {
	return p - c * clamp(round(p / c), -l, l);
}

float opOnion( in float sdf, in float thickness )
{
    return abs(sdf+thickness)-thickness;
}

//<functions>
//</functions>

vec4 get_scene(vec3 p, float time, vec3 world_cam_pos) {
	vec4 s = vec4(1.0, 1.0, 1.0, 99999.0);
	
	vec3 n = vec3(0.);

	
	
	//<scene>
	//s.w = sharp_union(s.w, get_sphere(p, vec3(0.0), .8+.1*sin(time)));
	s = vec4(vec3(0.5,0.2,0.1),sharp_union(s.w, get_sphere(p, vec3(0.0), .8+.1*sin(time))));
	//s.w = subtract(s.w, get_sphere(p, vec3(1.0, 0.0, 0.0), 0.8));
//	p = repeat_domain(p, vec3(3.0), vec3(5.0, 0.0, 0.0));
//  s = smooth_union_c(s.w, get_box(p, vec3(0.1, 0.5, 1.5)), s.rgb, vec3(1.0, 0.0, 0.0), 0.3);
//	s.w = subtract(s.w, get_sphere(p, vec3(0.6, 0.2, 0.5), 0.4));
	//s = smooth_subtract_c(s.w, get_sphere(p, vec3(0.3, 0.0, 1.5), 0.5), s.rgb, vec3(0.0, 1.0, 0.0), 0.1);
	//</scene>
	

	return s;
}


vec3 get_normal(vec3 p, float time, vec3 world_cam_pos) {
	float d = get_scene(p, time, world_cam_pos).w;
	vec2 e = vec2(NORMAL_PRECISION, 0.0);
	vec3 n = d - vec3(
		get_scene(p - e.xyy, time, world_cam_pos).w,
		get_scene(p - e.yxy, time, world_cam_pos).w,
		get_scene(p - e.yyx, time, world_cam_pos).w);
	return normalize(n);
}

vec4 sphere_trace(vec3 ray_origin, vec3 ray_dir, out vec3 out_normal, float time, vec3 world_cam_pos) {
	// Sphere tracing
	float d = 0.0;
	vec3 rgb;
	for (int i = 0; i < MAX_STEPS; ++i) {
		vec3 p = ray_origin + ray_dir * d;
		vec4 scene_info = get_scene(p, time, world_cam_pos);
		rgb = scene_info.rgb;
		float ds = scene_info.w;
		d += ds;
		if (d > MAX_DISTANCE || ds < SURFACE_DISTANCE) {
			break;
		}
	}

	vec3 hit_pos = ray_origin + ray_dir * d;
	out_normal = get_normal(hit_pos, time, world_cam_pos);
	

	return vec4(rgb, d);
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

bool test_bb(vec3 ray_origin,vec3 ray_dir, out vec3 tEnter, out vec3 tExit, out float edginess){
	//vec3 aabbMin = -1.*vec3(.55);
	//vec3 aabbMax = vec3(.55);
	
	vec3 aabbMin = -1.*vec3(u_bb_size)+u_bb_center;
	vec3 aabbMax = vec3(u_bb_size)+u_bb_center;
	
	vec3 tMin = (aabbMin - ray_origin)/ray_dir;
	vec3 tMax = (aabbMax - ray_origin)/ray_dir;
	
    float tIn = max(max(min(tMin.x, tMax.x), min(tMin.y, tMax.y)), min(tMin.z, tMax.z));
    float tOut = min(min(max(tMin.x, tMax.x), max(tMin.y, tMax.y)), max(tMin.z, tMax.z));

   	if ((tIn > tOut) || (tOut < 0.)){
		return false;
	}
		
	else{
		tEnter = ray_origin + ray_dir*tIn;
		tExit = ray_origin + ray_dir*tOut;
		vec3 hit = ray_origin+ray_dir*tIn;
		edginess = 1.0 - min(
		min(length(hit.x-aabbMin.x)+length(hit.y-aabbMin.y),
		length(hit.y-aabbMin.y)+length(hit.z-aabbMin.z)),
		length(hit.x-aabbMin.x)+length(hit.z-aabbMin.z));
		
		return true;
	}
}

vec4 traverse_accstruct(vec3 ray_origin,vec3 ray_dir, out vec3 out_normal, float time, vec3 world_cam_pos){
	vec3 tASEnter, tASExit;
	float edginess = 0.;
	vec4 trace_result = vec4(0);
	bool hit_as = test_bb(ray_origin, ray_dir, tASEnter, tASExit, edginess);
	if (hit_as){
		trace_result = mix(
			sphere_trace(ray_origin,ray_dir, out_normal, time, world_cam_pos),
			vec4(vec3(1),10.),
			smoothstep(0.95,1.0,edginess));
	}
	else{
		trace_result = vec4(0,0,0,MAX_DISTANCE*2.0);
	}
	return trace_result;
}

vec3 miss_shader(vec3 dir_uv, vec2 uv){
	//vec3 st = sphereProject(SKY_COORDS.xy);
	//vec3 st = sphereProject1(CAMERA_DIRECTION_WORLD.xy+UV);
	vec3 st = vec3(dir_uv.xy+uv,0);
	float time = TIME;

    vec3 color = vec3(0.0);
    vec3 pos = vec3(st*2.);

    float DF = 0.0;

    // Add a random position
    float a = 0.0;
    vec3 vel = vec3(time)*0.5;
	DF += fbm(pos+vel)*.25+.25;

    // Add a random position
    a = noise3D(pos* vec3(cos(time*0.15),sin(time*0.1),sin(time*0.13)) *0.1)*3.1415;
    vel = vec3(cos(a),sin(a),sin(a));
    DF += noise3D(pos+vel)*.25+.25;

	
	float d = smoothstep(0.3,0.8,fract(DF));
    return vec3(0.,.4,.5)*d  + vec3(.0,.7,.1)*(1.-d);
}

void fragment() {
	// Could certainly be optimized I think
	vec3 ndc = vec3(SCREEN_UV, 0.0) * 2.0 - 1.0;
	vec4 view_coords = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view_coords.xyz /= view_coords.w;
	vec3 world_cam_pos = (INV_VIEW_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
	vec4 world_coords = INV_VIEW_MATRIX * vec4(view_coords.xyz, 1.0);
	
	vec3 ray_origin = world_coords.xyz;
	vec3 ray_dir = normalize(world_coords.xyz - world_cam_pos);
	
	//float time = 0.0;
	float time = float(TIME);
	
	vec3 normal;
	
	
	vec4 trace_result = traverse_accstruct(ray_origin, ray_dir, normal, time, world_cam_pos);
	
	//vec4 rm = sphere_trace(ray_origin, ray_dir, normal, time, world_cam_pos);
	float d = trace_result.w;
	
	vec4 sdf_ndc = PROJECTION_MATRIX * VIEW_MATRIX * vec4(ray_origin + ray_dir * d, 1.0);
	DEPTH = (sdf_ndc.z / sdf_ndc.w) * 0.5 + 0.5;
		
	
	if (d > MAX_DISTANCE) {
		trace_result.rgb = miss_shader(-CAMERA_POSITION_WORLD, UV);
	}
	else{	
		NORMAL = (VIEW_MATRIX * vec4(normal, 0.0)).xyz;
	}
	
	ALBEDO = trace_result.rgb;
	
}
