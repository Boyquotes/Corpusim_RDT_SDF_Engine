@tool
class_name sdf_container_aabb extends MeshInstance3D


const SHADER_PATH = "res://SDF_Acceleration/ST_AABB.gdshader"

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
	var shader : Shader
	if _shader_material == null:
		shader = Shader.new()
	else:
		shader = _shader_material.shader

	# I want to reset all material params but Godot does not have an API for that,
	# so I just create a new material
	_shader_material = ShaderMaterial.new()
	


func _update_aabb():
	# TODO
	pass






