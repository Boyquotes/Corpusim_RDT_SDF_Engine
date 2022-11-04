# must set WASD and Fly_Down as inputs

extends CharacterBody3D

@onready var rotation_helper = $RotationHelper

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.0015


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
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
		
	
		

func _physics_process(delta):

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var m = SPEED * .1
	
	if Input.is_action_pressed("ui_accept"):
		# and is_on_floor():
		velocity.y = SPEED
	elif Input.is_action_pressed("Fly_Down"):
		velocity.y = -SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, m)
		
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, m)
		velocity.z = move_toward(velocity.z, 0, m)

	move_and_slide()
