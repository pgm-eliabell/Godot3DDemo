extends CharacterBody3D

@onready var camera_mount: Node3D = $Camera_Mount
@onready var character_visual: Node3D = $CharacterVisual
@onready var debug_arrow: MeshInstance3D = $Debug_Arrow
@onready var animation_handler: Node3D = $CharacterVisual/AnimationHandler

var SPEED = 3
const JUMP_VELOCITY = 4.5
@export var sens_horizontal = 0.5
@export var sens_vertical = 0.5

var running = false
var walking_speed = 3
var running_speed = 6

var is_attacking = false
var is_blocking = false

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sens_horizontal))
		character_visual.rotate_y(deg_to_rad(event.relative.x * sens_horizontal))
		camera_mount.rotate_x(deg_to_rad(-event.relative.y * sens_vertical))

func _physics_process(delta):
	# Running vs walking
	if Input.is_action_pressed("shift"):
		SPEED = running_speed
		running = true
	else:
		SPEED = walking_speed
		running = false

	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Input direction
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Handle attack/block input
	if Input.is_action_just_pressed("attack") and not is_attacking:
		is_attacking = true
		animation_handler.call("play_attack")

	elif Input.is_action_just_pressed("block") and not is_blocking:
		is_blocking = true
		animation_handler.call("play_block")

	# Reset flags when AnimationHandler timers end
	is_attacking = animation_handler.get("current_animation") == animation_handler.ATTACK
	is_blocking = animation_handler.get("current_animation") == animation_handler.BLOCK

	# Movement & animation
	if not is_attacking:  # block movement if attacking
		if direction.length() > 0:
			character_visual.look_at(position + -direction)
			debug_arrow.look_at(position + direction)
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED

			if is_blocking:
				animation_handler.call("set_animation_state", animation_handler.BLOCK)
			elif running:
				animation_handler.call("set_animation_state", animation_handler.RUN)
			else:
				animation_handler.call("set_animation_state", animation_handler.WALK)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
			if is_blocking:
				animation_handler.call("set_animation_state", animation_handler.BLOCK)
			else:
				animation_handler.call("set_animation_state", animation_handler.IDLE)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
