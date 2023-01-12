@tool
extends "./sdf_item.gd"


@export var size_primary: float :
	get:
		return _data.params[SDF.PARAM_SIZE_PRIMARY].value
	set(s):
		size_primary = s # Useless but doing it anyways
		_set_param(SDF.PARAM_SIZE_PRIMARY, s)
@export var size_secondary:  float :
	get:
		return _data.params[SDF.PARAM_SIZE_SECONDARY].value
	set(s):
		size_secondary = s # Useless but doing it anyways
		_set_param(SDF.PARAM_SIZE_SECONDARY, s)
@export var rounding: float :
	get:
		return _get_param(SDF.PARAM_ROUNDING)
	set(r):
		rounding = r # Useless but doing it anyways
		_set_param(SDF.PARAM_ROUNDING, r)
		

@export var offset : Vector3 = Vector3(0,0,0) :
	get:
		return _data.params[SDF.PARAM_OFFSET].value
	set(o):
		offset = o # Useless but doing it anyways
		_set_param(SDF.PARAM_OFFSET, o)

@export_enum("Sphere", "Box", "Torus", "Cylinder", "Rounded Cone", "Plane") var g_shape:int = SDF.G_SPHERE:
	get:
		return _get_param(SDF.PARAM_GENERIC_SHAPE)
	set(s):
		g_shape = s
		_set_param(SDF.PARAM_GENERIC_SHAPE, s)

func _init():
	_data = SDF.SceneObject.new(SDF.SHAPE_GENERIC)
	set_notify_transform(true) 
