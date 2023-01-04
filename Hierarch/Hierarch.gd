extends Node

@onready var sdf_container = $"%SDFContainer"

var shrink : float = 1.0


func _test_shrink():
	pass

func set_shrink(shrink_val):
	shrink = shrink_val
	_test_shrink()
