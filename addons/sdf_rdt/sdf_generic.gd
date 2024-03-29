@tool
extends "./sdf_item.gd"

@onready var hierarch = get_node("/root/Node3d/Hierarch")
var start_pos : Vector3
@onready var shrink : float = 1.0

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
		
@export_range(0.0,1.0,1.0) var onion_alpha : float = 0.0:
	get:
		return _data.params[SDF.PARAM_ONION_ALPHA].value
	set(o):
		onion_alpha = o
		_set_param(SDF.PARAM_ONION_ALPHA,o)
	
@export var onion_thickness : float = 1.0:
	get:
		return _data.params[SDF.PARAM_ONION_THICKNESS].value
	set(t):
		onion_thickness = t
		_set_param(SDF.PARAM_ONION_THICKNESS, t)

@export_enum("Sphere", "Box", "Torus", "Cylinder", "Rounded Cone", "Plane") var g_shape:int = SDF.G_SPHERE:
	get:
		return _get_param(SDF.PARAM_GENERIC_SHAPE)
	set(s):
		g_shape = s
		_set_param(SDF.PARAM_GENERIC_SHAPE, s)

@export var osc_z : bool = false:
	set(b):
		start_pos = position
		osc_z = b



@export var MAX_OSC : float = 3.0
@export_range(0.0,.6,.02) var spin_speed : float = 0.0

@export var spin_axis : Vector3 = Vector3(0,0,0):
	get:
		return spin_axis
	set(a):
		spin_axis = a.normalized()


func _init():
	_data = SDF.SceneObject.new(SDF.SHAPE_GENERIC)
	set_notify_transform(true) 
	
	
func _ready():
	hierarch.connect("shrink_modified", _shrink_modified)
	

func _process(delta):
	super(delta)
	if spin_speed > 0.0 && spin_axis != null && spin_axis != Vector3(0,0,0):
		rotate_object_local(spin_axis,delta*spin_speed / shrink)
	if osc_z:
		var offset = MAX_OSC * sin(.001*Time.get_ticks_msec())
		position = start_pos + Vector3(0,0,offset)

func _shrink_modified(s):
	shrink = s
