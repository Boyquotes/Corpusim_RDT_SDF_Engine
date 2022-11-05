extends Node

@onready var sdf_container = $"%SDFContainer"

var shrink : float = 1.0

var SDFCylinder := load("res://addons/sdf_rdt/sdf_cylinder.gd")
var cylinder = SDFCylinder.new() 



# Called when the node enters the scene tree for the first time.
func _ready():
	cylinder.radius = .1
	cylinder.height = .1
	cylinder.color = Color(0.2,.8,.4)
	cylinder.position = Vector3(-2.33, 1.64, -1.58)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _test_shrink():
	if shrink > 3.0 && !sdf_container.is_ancestor_of(cylinder):
		sdf_container.add_child(cylinder)
		sdf_container.set_shrink(3.0)
		print("added cyl")
	elif shrink < 3.0 && sdf_container.is_ancestor_of(cylinder):
		sdf_container.remove_child(cylinder)
		sdf_container.set_shrink(3.0)
		print("removed cyl")

func set_shrink(shrink_val):
	shrink = shrink_val
	_test_shrink()
