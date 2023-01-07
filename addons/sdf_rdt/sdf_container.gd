@tool
extends MeshInstance3D

const SDF = preload("./sdf.gd")
var SDFItem = load("res://addons/sdf_rdt/sdf_item.gd")



const SHADER_PATH = "res://addons/sdf_rdt/raymarch.gdshader"


	

class ShaderTemplate:
	var before_uniforms := ""
	var after_uniforms_before_scene := ""
	var after_scene := ""


var _objects : Array= []
var _cutaways : Array= []
var _next_id := 0
var _shader_template : ShaderTemplate
var _shader_material : ShaderMaterial
var _need_shader_update := true
var _need_objects_update := true


var shrink : float = 1.0


func _ready():
	_shader_template = _load_shader_template(SHADER_PATH)
	var pm := PlaneMesh.new()
	pm.size = Vector2(2, 2)
	pm.orientation = PlaneMesh.FACE_Z
	pm.flip_faces = true
	mesh = pm
	
	
	set_process(true)
	_update_shader()
	
	
func set_shrink(shrink_val):
	_shader_material.set_shader_parameter("shrink", shrink_val)
	shrink = shrink_val


func set_object_param(so, param_index: int, value):
	var param = so.params[param_index]
	if param.value != value:
		param.value = value
		if param.uniform != "" and _shader_material != null:
			_shader_material.set_shader_parameter(param.uniform, param.value)
			

func set_object_operation(so, op: int):
	if so.operation != op:
		var cutaway_toggled : bool = (SDF.OP_CUTAWAY == so.operation) || (op == SDF.OP_CUTAWAY)
		so.operation = op
		_schedule_shader_update()
		if cutaway_toggled:
			_update_objects_from_children()
	
func set_object_shape(so, g_shape: int):
	if so.g_shape != g_shape:
		so.g_shape = g_shape
		
		

func schedule_structural_update():
	_need_objects_update = true
	set_process(true)


func _schedule_shader_update():
	_need_shader_update = true
	set_process(true)


func _process(delta):
	if _need_objects_update:
		_need_objects_update = false
		_update_objects_from_children()
		
	elif _need_shader_update:
		_need_shader_update = false
		_update_shader()
	
	set_process(false)


func _update_shader():
	var shader : Shader
	if _shader_material == null:
		shader = Shader.new()
	else:
		shader = _shader_material.shader

	# I want to reset all material params but Godot does not have an API for that,
	# so I just create a new material
	_shader_material = ShaderMaterial.new()
	
	var code := _generate_shader_code(_objects, _shader_template, _cutaways)
	set_shrink(shrink)
	# This is for debugging
	#_debug_dump_text_file("generated_shader.txt", code)

	# this is the heaviest operation, 20x _generate_shader_code()
	shader.code = code 
	
	_shader_material.set_shader(shader)
	
	set_material_override(_shader_material)
	
	_update_material()


func _update_material():
	for obj in _objects:
		for param_index in obj.params:
			var param = obj.params[param_index]
			if param.uniform != "":
				_shader_material.set_shader_parameter(param.uniform, param.value)
	for cut in _cutaways:
		for param_index in cut.params:
			var param = cut.params[param_index]
			if param.uniform != "":
				_shader_material.set_shader_parameter(param.uniform, param.value)


func _update_objects_from_children():
	_objects.clear()
	_cutaways.clear()
	for child_index in get_child_count():
		var child = get_child(child_index)
		if child is SDFItem:
			if child.operation == SDF.OP_CUTAWAY:
				_cutaways.append(child.get_sdf_scene_object())
			else:
				_objects.append(child.get_sdf_scene_object())
	_update_shader()


func _update_aabb():
	# TODO
	pass


static func _load_shader_template(fpath: String) -> ShaderTemplate:
	var f := File.new()
	var err := f.open(fpath, File.READ)
	if err != OK:
		push_error("Could not load {0}: error {1}".format([fpath, err]))
		return null
	var template := ShaderTemplate.new()
	var tags := [
		"//<uniforms>",
		"//</uniforms>",
		"//<scene>",
		"//</scene>"
	]
	var tag_index := 0
	while not f.eof_reached():
		var line := f.get_line()
		if tag_index < len(tags) and line.find(tags[tag_index]) != -1:
			tag_index += 1
			continue
		if tag_index % 2 == 0:
			line += "\n"
			match tag_index / 2:
				0:
					template.before_uniforms += line
				1:
					template.after_uniforms_before_scene += line
				2:
					template.after_scene += line
	f.close()
	return template


static func _make_uniform_name(index: int, name: String) -> String:
	return str("u_shape", index, "_", name)


static func _get_param_code(so, param_index: int) -> String:
	var param = so.params[param_index]
	if param.uniform != "":
		return param.uniform
	return str(param.value)


static func _godot_type_to_shader_type(type: int):
	match type:
		TYPE_FLOAT:
			return "float"
		TYPE_COLOR:
			return "vec4"
		TYPE_TRANSFORM3D:
			return "mat4"
		TYPE_VECTOR3:
			return "vec3"
		TYPE_INT:
			return "int"
		_:
			assert(false)


static func _godot_type_to_fcount(type: int) -> int:
	match type:
		TYPE_FLOAT:
			return 1
		TYPE_VECTOR3:
			return 3
		TYPE_COLOR:
			return 4
		TYPE_TRANSFORM3D:
			return 16
		_:
			assert(false)
	return 0


static func _get_shape_code(obj, pos_code: String, cut_layer:float = 0.) -> String:
	match obj.shape:
		
		# TODO: Replace with code for all shapes
		SDF.SHAPE_GENERIC:
			match(obj.params[SDF.PARAM_GENERIC_SHAPE].value):
				SDF.G_SPHERE:
					return str("get_sphere(", pos_code, ", vec3(0.0), ", 
					_get_param_code(obj, SDF.PARAM_SIZE_PRIMARY-cut_layer*.1)," * shrink)")
				_:
					assert(false)
					
		SDF.SHAPE_SPHERE:
			return str("get_sphere(", pos_code, ", vec3(0.0), ", 
				_get_param_code(obj, SDF.PARAM_RADIUS-cut_layer*.1)," * shrink)")

		SDF.SHAPE_BOX:
			return str("get_rounded_box(", pos_code, 
				", ", _get_param_code(obj, SDF.PARAM_SIZE-cut_layer*.1), " * shrink ",
				", ", _get_param_code(obj, SDF.PARAM_ROUNDING), ")")

		SDF.SHAPE_TORUS:
			return str("get_torus(", pos_code, 
				", vec2(", _get_param_code(obj, SDF.PARAM_RADIUS),"*shrink",
				", ", _get_param_code(obj, SDF.PARAM_THICKNESS), "*shrink))")

		SDF.SHAPE_CYLINDER:
			return str("get_rounded_cylinder(", pos_code, 
				", ", _get_param_code(obj, SDF.PARAM_RADIUS),"* shrink", 
				", ", _get_param_code(obj, SDF.PARAM_ROUNDING),
				", ", _get_param_code(obj, SDF.PARAM_HEIGHT), "* shrink)")

		_:
			assert(false)
	return ""


static func _generate_shader_code(objects : Array, template: ShaderTemplate, cutaways :Array) -> String:
	
	var uniforms := ""
	const cut_uf_offset := 1000
	var scene := ""

	var fcount := 0
	
	for cutaway_index in len(cutaways):
		var cut = cutaways[cutaway_index]
		for param_index in cut.params:
			var param = cut.params[param_index]
			param.uniform = _make_uniform_name(cutaway_index+cut_uf_offset, SDF.get_param_name(param_index))
			var type = SDF.get_param_type(param_index)
			var stype = _godot_type_to_shader_type(type)
			uniforms += str("uniform ", stype, " ", param.uniform, ";\n")
			# for debug
			#fcount += _godot_type_to_fcount(type)
	
	for object_index in len(objects):
		var obj = objects[object_index] 
		#if not obj.active:
		#	continue

		# Note: the amount of uniforms in a shader is not unlimited.
		# There is a point the driver will say "no", depending on the graphics card.
		# In the future, if more shapes are needed within one container,
		# we could "freeze" some of the params and make them consts instead of uniforms
		for param_index in obj.params:
			var param = obj.params[param_index]
			param.uniform = _make_uniform_name(object_index, SDF.get_param_name(param_index))
			var type = SDF.get_param_type(param_index)
			var stype = _godot_type_to_shader_type(type)
			uniforms += str("uniform ", stype, " ", param.uniform, ";\n")
			# for debug
			#fcount += _godot_type_to_fcount(type)

		var pos_code := str("(", _get_param_code(obj, SDF.PARAM_TRANSFORM), " * vec4(p, shrink)).xyz")
		var indent = "\t"
		
		var shape_code : String = _get_shape_code(obj, pos_code)#+displace_code
		
		# onion everything
		shape_code  = str("opOnion(", shape_code, ",.05 * shrink)")
		
		# Cutaways
		for cutaway_index in len(cutaways):
			var cut = cutaways[cutaway_index]
			
			
			var cut_pos_code := str("(", _get_param_code(cut, SDF.PARAM_TRANSFORM), " * vec4(p, shrink)).xyz")
			
			#cut
			#if cut.shape == SDF.SHAPE_BOX:
			#	cut.size -= .6*shrink*_get_param_code(obj,SDF.PARAM_LAYER)
			#elif cut.shape == SDF.SHAPE_SPHERE:
		#		cut.radius -= .6*shrink*_get_param_code(obj,SDF.PARAM_LAYER)
			var cut_code = _get_shape_code(cut, cut_pos_code)
			
			#shape_code = str("max(-1.*",cut_code,"- .6 * shrink * ",_get_param_code(obj, SDF.PARAM_LAYER), ", ", shape_code,")");
			
			shape_code = str("max(-1.*",cut_code,"- .6 * shrink * ",_get_param_code(obj, SDF.PARAM_LAYER), " * ", _get_param_code(cut, SDF.PARAM_LAYER), ",", shape_code,")");
		
		match obj.operation:
			SDF.OP_UNION:
				scene += str(indent, "s = smooth_union_c(s.w, ", shape_code, ", s.rgb, ",
					_get_param_code(obj, SDF.PARAM_COLOR), ".rgb, ", 
					_get_param_code(obj, SDF.PARAM_SMOOTHNESS), "*shrink);\n")

			SDF.OP_SUBTRACT:
				scene += str(indent, "s = smooth_subtract_c(s.w, ", shape_code, ", s.rgb, ",
					#_get_param_code(obj, SDF.PARAM_COLOR), ".rgb, ", #transparent colors
					"s.rgb+vec3(0,-0.1,-0.1),",
					_get_param_code(obj, SDF.PARAM_SMOOTHNESS), "*shrink);\n")

			SDF.OP_COLOR:
				scene += str(indent, "s.rgb = smooth_color(s.w, ", shape_code, ", s.rgb, ",
					_get_param_code(obj, SDF.PARAM_COLOR), ".rgb, ", 
					_get_param_code(obj, SDF.PARAM_SMOOTHNESS), "*shrink);\n")
			_:
				assert(false)

	# TODO Move this log in an editor utility
	# for debug
	#print("Fcount: ", fcount)

	return str(
		template.before_uniforms, 
		uniforms, 
		template.after_uniforms_before_scene, 
		scene, 
		template.after_scene)


static func _debug_dump_text_file(fpath: String, text: String):
	var f = File.new()
	var err = f.open(fpath, File.WRITE)
	if err != OK:
		push_error("Could not save file {0}: error {1}".format([fpath, err]))
		return
	f.store_string(text)
	f.close()


