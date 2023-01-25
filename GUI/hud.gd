extends Control


@onready var hud_cuts = []
var cut_tex_empty : Texture2D = preload("res://addons/sdf_rdt/tools/icons/icon_cut_empty.svg")
var cut_tex_sphere : Texture2D = preload("res://addons/sdf_rdt/tools/icons/icon_cut_sphere.svg")
var cut_tex_cube : Texture2D = preload("res://addons/sdf_rdt/tools/icons/icon_cut_cube.svg")
var cut_tex_plane : Texture2D = preload("res://addons/sdf_rdt/tools/icons/icon_cut_plane.svg")

const SDF = preload("res://addons/sdf_rdt/sdf.gd")

# Called when the node enters the scene tree for the first time.
func _ready():
	hud_cuts.append(get_node("VBoxContainer/HBoxContainer/Cut0"))
	hud_cuts.append(get_node("VBoxContainer/HBoxContainer/Cut1"))
	hud_cuts.append(get_node("VBoxContainer/HBoxContainer/Cut2"))
	for i in hud_cuts:
		i.set_texture(cut_tex_empty)
	hud_cuts[0].set_texture(cut_tex_sphere)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func set_cut(icon_index, shape):
	if hud_cuts == null:
		return
	icon_index -= 1
	match shape:
		SDF.G_SPHERE:
			hud_cuts[icon_index].set_texture(cut_tex_sphere)
		SDF.G_PLANE:
			hud_cuts[icon_index].set_texture(cut_tex_plane)
		SDF.G_BOX:
			hud_cuts[icon_index].set_texture(cut_tex_cube)
		_:
			hud_cuts[icon_index].set_texture(cut_tex_sphere)
			print("Invalid cutaway icon shape in hud.gd")
	if icon_index > 0:
		if icon_index == 2:
			hud_cuts[icon_index].modulate = Color(1.,.6,.6)
		while icon_index > 0:
			icon_index -= 1
			hud_cuts[icon_index].modulate = Color(.6,.6,.6)
			

func reset_cuts(shape):
	if hud_cuts == null:
		return
	for c in hud_cuts:
		c.set_texture(cut_tex_empty)
		c.modulate = Color(1.,1.,1.)
	set_cut(1,shape)
