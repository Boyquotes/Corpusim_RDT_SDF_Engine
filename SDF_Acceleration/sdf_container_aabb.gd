@tool
class_name sdf_container_aabb extends MeshInstance3D

@export var bb_center:Vector3 = Vector3(0,0,0) :
	get:
		return bb_center
	set(s):
		bb_center = s
		_update_shader_param() 


@export_range(0.1,2.0) var bb_size:float = .55 :
	get:
		return bb_size
	set(s):
		bb_size = s
		_update_shader_param()
		

const SHADER_PATH = "res://SDF_Acceleration/ST_AABB.gdshader"

class ShaderTemplate:
	var before_uniforms := ""
	var after_uniforms_before_scene := ""
	var after_scene := ""


#var _objects : Array= []
#var _cutaways : Array= []
#var _next_id := 0
#var _shader_template : ShaderTemplate
var _shader_material : ShaderMaterial = ShaderMaterial.new()
#var _need_shader_update := true
#var _need_objects_update := true


var shrink : float = 1.0


func _ready():
	var pm := PlaneMesh.new()
	pm.size = Vector2(2, 2)
	pm.orientation = PlaneMesh.FACE_Z
	pm.flip_faces = true
	mesh = pm
	
	set_process(true)
	_update_shader()
	




func _process(delta):
	pass
		


func _update_shader():
	var shader = load(SHADER_PATH)
	#var _shader_material = ShaderMaterial.new()
	_shader_material.shader = shader

	set_material_override(_shader_material)
	

func _update_shader_param():
	_shader_material.set_shader_parameter("u_bb_size", bb_size)
	_shader_material.set_shader_parameter("u_bb_center", bb_center)

func _update_aabb():
	# TODO
	pass






