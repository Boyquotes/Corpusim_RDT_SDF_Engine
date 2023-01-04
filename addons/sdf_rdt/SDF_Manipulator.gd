extends Node

@onready var manip : Node3D = get_parent()

@export var spin_z : bool = false;
@export var osc_z : bool = false;


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#manip.rotate_(delta*.5)
	if spin_z:
		manip.rotate_object_local(Vector3(0,0,1),delta*.5)
	if osc_z:
		#manip.
		pass
