# must set WASD and Fly_Down as inputs

extends CharacterBody3D

const MAX_SPEED :float = 5.0
const MOUSE_SENSITIVITY : float = 0.0015
var speed : float = MAX_SPEED

@onready var sdf_container = $"%SDFContainer"
@onready var hierarch = $"%Hierarch"
@onready var hud = $"../HUD"

const SHRINK_MIN : float = 1.0
const SHRINK_MAX : float = 50.0
var shrink : float = SHRINK_MIN
var shrink_target : float = shrink

var shrink1_pos : Vector3 = Vector3()

const SDF = preload("res://addons/sdf_rdt/sdf.gd")
const sdf_item = preload("res://addons/sdf_rdt/sdf_item.gd")
var cutaway_sphere : = preload("res://addons/sdf_rdt/sdf_sphere.gd")
var cutaway_box : = preload("res://addons/sdf_rdt/sdf_box.gd")
var cutaway_type : String = "sphere"
const cutaway_radius: float = 3.0
const cutaway_size: Vector3 = Vector3(3,3,3)
var cutaways : Array= []


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	hud.get_node("msg").text = "Shrink: %0.3f" % shrink 
	shrink1_pos = position
	_reset_cutaways()
	

func _process(_delta):
	process_input()
	process_shrink()
	if len(cutaways) == 0:
		_place_cutaway(true)
		if cutaway_type == "sphere":
			cutaways[0].radius = cutaway_radius
		else:
			cutaways[0].size = cutaway_size


		
func process_input():
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
		if cutaway_type == "sphere":
			cutaway_type = "box"
		else:
			cutaway_type = "sphere"
			
		var inst = cutaways.pop_front()
		inst.queue_free()
		_place_cutaway(true)

func process_shrink():
	if Input.is_action_just_released("shrink_increase"):
		shrink_target = clampf(shrink_target+.55,SHRINK_MIN, SHRINK_MAX)
	if Input.is_action_just_released("shrink_decrease"):
		shrink_target = clampf(shrink_target-.55,SHRINK_MIN, SHRINK_MAX)
		
	var shrink_delta = shrink_target-shrink
	if abs(shrink_delta) > .01:
		shrink = move_toward(shrink, shrink_target, abs(shrink_delta)*.1)
		if cutaway_type == "sphere":
			cutaways[0].radius = cutaway_radius/shrink
		else:
			cutaways[0].size = cutaway_size/shrink
		
		sdf_container.set_shrink(shrink)
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
			

		
	if Input.is_action_pressed("Roll_Left"):
		rotate_object_local(Vector3(0,0,1),20 * MOUSE_SENSITIVITY)
	elif Input.is_action_pressed("Roll_Right"):
		rotate_object_local(Vector3(0,0,1),20 * MOUSE_SENSITIVITY * -1)
		
		
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

# needs refactorings
func _place_cutaway(follow_probe : bool = false):
	var instance : sdf_item
	if cutaway_type == "sphere":
		instance = cutaway_sphere.new()
	else:
		instance = cutaway_box.new()
	
	
	if follow_probe:
		instance.follows_probe = true
		cutaways.push_front(instance)
	else:	
		cutaways.push_back(instance)
		
	instance.position = position/shrink
	instance.rotation = rotation
	sdf_container.add_child(instance)
		
	if cutaway_type == "sphere":
		instance.radius = cutaways[0].radius
	else:
		instance.size = cutaways[0].size
		
	instance.operation = SDF.OP_CUTAWAY
	

func _reset_cutaways():
	# clear cutaways
	for i in len(cutaways):
		var inst : sdf_item = cutaways.pop_back()
		inst.queue_free()
		

	
	
