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

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sens_horizontal))
		character_visual.rotate_y(deg_to_rad(event.relative.x * sens_horizontal))
		camera_mount.rotate_x(deg_to_rad(-event.relative.y * sens_vertical))

func _physics_process(delta):
	if Input.is_action_pressed("shift"):
		SPEED = running_speed
		running = true
	else:
		SPEED = walking_speed
		running = false

	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Input — just trigger the handler, don't track state here
	if Input.is_action_just_pressed("attack") and not animation_handler.is_in_state(animation_handler.ATTACK):
		animation_handler.call("play_attack")
	elif Input.is_action_just_pressed("block") and not animation_handler.is_in_state(animation_handler.BLOCK):
		animation_handler.call("play_block")

	# Ask the handler what state we're in, don't store it ourselves
	var is_attacking = animation_handler.is_in_state(animation_handler.ATTACK)
	var is_blocking = animation_handler.is_in_state(animation_handler.BLOCK)

	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if not is_attacking and not is_blocking:
		if direction.length() > 0:
			character_visual.look_at(position + -direction)
			debug_arrow.look_at(position + direction)
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
			#if is_blocking:
				#animation_handler.call("set_animation_state", animation_handler.BLOCK)
			if running:
				animation_handler.call("set_animation_state", animation_handler.RUN)
			else:
				animation_handler.call("set_animation_state", animation_handler.WALK)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
			animation_handler.call("set_animation_state", animation_handler.IDLE)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
