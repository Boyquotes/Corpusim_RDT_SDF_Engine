extends Node

signal shrink_modified

@onready var sdf_container = $"%SDFContainer"

var shrink : float = 1.0



func set_shrink(shrink_val):
	shrink = shrink_val
	shrink_modified.emit(shrink)
