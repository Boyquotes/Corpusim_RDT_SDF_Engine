# must set WASD and Fly_Down as inputs

extends CharacterBody3D

const MAX_SPEED :float = 5.0
const MOUSE_SENSITIVITY : float = 0.0015
var speed : float = MAX_SPEED

const SDFContainer = preload("res://addons/sdf_rdt/sdf_container.gd")
const SDFGeneric = preload("res://addons/sdf_rdt/sdf_generic.gd")

@onready var sdf_container : SDFContainer = $"%SDFContainer"
@onready var hierarch = $"%Hierarch"
@onready var hud = $"../HUD"

const SHRINK_MIN : float = 1.0
const SHRINK_MAX : float = 50.0
var shrink : float = SHRINK_MIN
var shrink_target : float = shrink

var velocity_roll : float = 0.
var VELOCITY_ROLL_MAX : float = .03;

var shrink1_pos : Vector3 = Vector3()

const SDF = preload("res://addons/sdf_rdt/sdf.gd")

var cutaway_shape : int = SDF.G_SPHERE
var cutaway_shape_index : int = 0
const cutaway_shape_index_max : int = 2

var cutaway_index = 1
@export var cutaway_index_max = 4
const cutaway_radius: float = 3.0
const CUTAWAY_SIZE_SPHERE : float = 3.0
const CUTAWAY_SIZE_PLANE : float = -1.5
const CUTAWAY_SIZE_BOX : float = 3.0
var cutaway_normalized_size : float = CUTAWAY_SIZE_SPHERE




func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	hud.get_node("msg").text = "Shrink: %0.3f" % shrink 
	shrink1_pos = position
	_init_cutaways()
	_reset_cutaways()
	

# TODO: Spawn cutaways up to cutaway_index_max+1
func _init_cutaways():
	var new_cut = SDFGeneric.new()
	new_cut.operation = SDF.OP_CUTAWAY
	new_cut.g_shape = SDF.G_SPHERE
	new_cut.follows_probe = true
	sdf_container.add_child(new_cut)
	
	for i in cutaway_index_max:
		new_cut = SDFGeneric.new()
		new_cut.operation = SDF.OP_CUTAWAY
		new_cut.g_shape = SDF.G_SPHERE
		new_cut.size_primary = 0.0
		new_cut.size_secondary = 0.0
		sdf_container.add_child(new_cut)
		
	cutaway_index = 1
	
		
	

func _process(_delta):
	_process_input()
	_process_shrink()

		
func _process_input():
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			
	if Input.is_action_just_pressed("toggle_fullscreen"):
		pass
		
	if Input.is_action_just_pressed("cutaway_place"):
		_place_cutaway()
	elif Input.is_action_just_pressed("cutaways_reset"):
		_reset_cutaways()
		
	if Input.is_action_just_pressed("cutaway_change_type"):
		_change_cutaway_shape()
		

func _process_shrink():
	var shrink_speed : float = .55
	if Input.is_action_just_released("shrink_increase"):
		shrink_target = clampf(shrink_target+shrink_speed,SHRINK_MIN, SHRINK_MAX)
	if Input.is_action_just_released("shrink_decrease"):
		shrink_target = clampf(shrink_target-shrink_speed,SHRINK_MIN, SHRINK_MAX)
		
	var shrink_delta = shrink_target-shrink
	if abs(shrink_delta) > .01:
		shrink = move_toward(shrink, shrink_target, abs(shrink_delta)*.1)
		sdf_container.calibrate_shrink(shrink, cutaway_normalized_size)
		hierarch.set_shrink(shrink)
		hud.get_node("msg").text = "Shrink: %0.3f" % shrink 
		position = shrink1_pos*shrink			

func _input(event):
	if event is InputEventMouseMotion && Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_object_local(Vector3(1,0,0),event.relative.y * MOUSE_SENSITIVITY * -1)
		rotate_object_local(Vector3(0,1,0),event.relative.x * MOUSE_SENSITIVITY * -1)
		


		

func _physics_process(_delta):

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var input_dir_y : float = 0.0
	if Input.is_action_pressed("Fly_Up"):
		input_dir_y = 1.0
	elif Input.is_action_pressed("Fly_Down"):
		input_dir_y = -1.0
	var direction = (global_transform.basis * Vector3(input_dir.x, input_dir_y, input_dir.y)).normalized()
	
	
	

	
	var m = speed * .1
	
	if Input.is_action_just_pressed("move_slowly"):
		if speed == MAX_SPEED:
			speed = MAX_SPEED*.3
		else:
			speed = MAX_SPEED
			

	var r_delt = .002
	if Input.is_action_pressed("Roll_Left"):
		velocity_roll = move_toward(velocity_roll, VELOCITY_ROLL_MAX, r_delt)
		rotate_object_local(Vector3(0,0,1),velocity_roll)
	elif Input.is_action_pressed("Roll_Right"):
		velocity_roll = move_toward(velocity_roll, -VELOCITY_ROLL_MAX, r_delt)
		rotate_object_local(Vector3(0,0,1),velocity_roll)
	else:
		velocity_roll = move_toward(velocity_roll, 0, r_delt*2)
		rotate_object_local(Vector3(0,0,1),velocity_roll)
		
		
	if direction:
		velocity.x = direction.x * speed
		velocity.y = direction.y * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, m)
		velocity.y = move_toward(velocity.y, 0, m)
		velocity.z = move_toward(velocity.z, 0, m)

	move_and_slide()
	
	shrink1_pos = position/shrink

func _calibrate_cutaway_shrink():
	sdf_container.calibrate_shrink(shrink, cutaway_normalized_size)
	



func _place_cutaway():
	if cutaway_index < cutaway_index_max:
		sdf_container.cutaway_place(cutaway_index)
		cutaway_index += 1
		_calibrate_cutaway_shrink()
	else:
		print("Max Cutaways Placed. Right Mouse Button to Reset Cutaways.")
	

func _reset_cutaways():
	cutaway_index = 1
	sdf_container.cutaways_reset()

func _change_cutaway_shape():
	if cutaway_shape_index < cutaway_shape_index_max:
		cutaway_shape_index += 1
	else:
		cutaway_shape_index = 0
	
	match cutaway_shape_index:
		0:
			sdf_container.cutaway_set_shape(SDF.G_SPHERE)
			cutaway_normalized_size = CUTAWAY_SIZE_SPHERE
		1:
			sdf_container.cutaway_set_shape(SDF.G_PLANE, CUTAWAY_SIZE_PLANE)
			cutaway_normalized_size = CUTAWAY_SIZE_PLANE
		2:
			sdf_container.cutaway_set_shape(SDF.G_BOX)
			cutaway_normalized_size = CUTAWAY_SIZE_SPHERE
		_: 
			sdf_container.cutaway_set_shape(SDF.G_SPHERE)
			cutaway_normalized_size = CUTAWAY_SIZE_SPHERE
			print("Misconfigured # of cutaway shapes in Player.gd")
			
