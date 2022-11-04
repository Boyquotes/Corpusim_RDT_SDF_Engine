# must set WASD and Fly_Down as inputs

extends CharacterBody3D

@onready var rotation_helper = $RotationHelper

const MAX_SPEED := 5.0
const MOUSE_SENSITIVITY := 0.0015
var speed := MAX_SPEED

@onready var sdf_container = $"%SDFContainer"

const SHRINK_MIN := 1.0
const SHRINK_MAX := 5.0
var shrink := SHRINK_MIN
var shrink_target := shrink

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(_delta):
	process_input()
	
func process_input():
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			
	if Input.is_action_just_pressed("toggle_fullscreen"):
		pass

			
	
func _input(event):
	if event is InputEventMouseMotion && Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(event.relative.y * MOUSE_SENSITIVITY * -1)
		self.rotate_y(event.relative.x * MOUSE_SENSITIVITY * -1)
		

		

func _physics_process(_delta):

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var m = speed * .1
	
	if Input.is_action_just_pressed("move_slowly"):
		if speed == MAX_SPEED:
			speed = MAX_SPEED*.3
		else:
			speed = MAX_SPEED
			
	if Input.is_action_just_released("shrink_increase"):
		shrink_target = clampf(shrink_target+.15,SHRINK_MIN, SHRINK_MAX)
	if Input.is_action_just_released("shrink_decrease"):
		shrink_target = clampf(shrink_target-.15,SHRINK_MIN, SHRINK_MAX)
		
	var shrink_delta = abs(shrink_target-shrink)
	if shrink_delta > .01:
		shrink = move_toward(shrink, shrink_target, shrink_delta*.3)
		sdf_container.set_shrink(shrink)
		
	if Input.is_action_pressed("ui_accept"):
		velocity.y = speed
	elif Input.is_action_pressed("Fly_Down"):
		velocity.y = -speed
	else:
		velocity.y = move_toward(velocity.y, 0, m)
		
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, m)
		velocity.z = move_toward(velocity.z, 0, m)

	move_and_slide()
