extends Node

@onready var manip : Node3D = get_parent()


@export var osc_z : bool = false

@export var MAX_OSC : float = 3.0

@export var spin_axis : Vector3 = Vector3(0,0,0):
	get:
		return spin_axis
	set(a):
		spin_axis = a.normalized()


@onready var start_pos : Vector3 = manip.position


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#manip.rotate_(delta*.5)
	if spin_axis != Vector3(0,0,0):
		manip.rotate_object_local(spin_axis,delta*.5)
	if osc_z:
		var offset = MAX_OSC * sin(.001*Time.get_ticks_msec())
		manip.position = start_pos + Vector3(0,0,offset)
		
