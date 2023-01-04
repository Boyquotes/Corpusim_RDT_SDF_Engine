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

@export_enum("Sphere", "Box", "Cylinder", "Plane") var shape :
	get:
		return _data.shape
	set(s):
		if _container != null:
			_container.set_object_shape(_data, shape)
		else:
			_data.shape = shape

func _init():
	_data = SDF.SceneObject.new(SDF.SHAPE_GENERIC)
	set_notify_transform(true) 
