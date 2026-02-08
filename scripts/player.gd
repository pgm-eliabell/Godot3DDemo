#extends CharacterBody3D
#
#@onready var camera_mount: Node3D = $Camera_Mount
#@onready var animation_player: AnimationPlayer = $Visuals/Knight/AnimationPlayer
#
#@onready var visuals: Node3D = $Visuals
#
#
#var SPEED = 3
#const JUMP_VELOCITY = 4.5
#@export var sens_horizontal = 0.5
#@export var sens_vertical = 0.5
#
#var running = false
#var walking_speed = 3
#var running_speed = 6
#
#var is_attacking = false
#
#func _ready():
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
#
#func _input(event):
	#if event is InputEventMouseMotion:
		#rotate_y(deg_to_rad(-event.relative.x*sens_horizontal))
		#visuals.rotate_y(deg_to_rad(event.relative.x*sens_horizontal))
		#camera_mount.rotate_x(deg_to_rad(-event.relative.y*sens_vertical))
#
#func _physics_process(delta: float) -> void:
	#if !animation_player.is_playing():
		#is_attacking = false
	#
	#if Input.is_action_just_pressed("attack"):
		#if animation_player.current_animation != "1H_Melee_Attack_Slice_Horizontal":
			#animation_player.play("1H_Melee_Attack_Slice_Horizontal")
			#is_attacking = true
			#
	#if Input.is_action_pressed("shift"):
		#SPEED = running_speed
		#running = true
	#else: 
		#SPEED = walking_speed
		#running = false
	## Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
#
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var input_dir := Input.get_vector("left", "right", "forward", "backward")
	#var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#if direction:
		#if !is_attacking: 
			#if running: 
				#if animation_player.current_animation != "Running_B":
					#animation_player.play("Running_B")
			#else:
				#if animation_player.current_animation != "Walking_A":
					#animation_player.play("Walking_A")
					#
				#
			#visuals.look_at(position + direction)
			#
		#velocity.x = direction.x * SPEED
		#velocity.z = direction.z * SPEED
		#
	#else:
		#if !is_attacking:
			#if animation_player.current_animation != "Idle":
				#animation_player.play("Idle")
					#
				#velocity.x = move_toward(velocity.x, 0, SPEED)
				#velocity.z = move_toward(velocity.z, 0, SPEED)
		#
	#if !is_attacking:
		#move_and_slide()




extends CharacterBody3D

@onready var camera_mount: Node3D = $Camera_Mount
#@onready var animation_player: AnimationPlayer = $Visuals/Knight/AnimationPlayer

@onready var character_visual: Node3D = $CharacterVisual
@onready var debug_arrow: MeshInstance3D = $Debug_Arrow



var SPEED = 3
const JUMP_VELOCITY = 4.5
@export var sens_horizontal = 0.5
@export var sens_vertical = 0.5

var running = false
var walking_speed = 3
var running_speed = 6

var is_attacking = false

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x*sens_horizontal))
		character_visual.rotate_y(deg_to_rad(event.relative.x*sens_horizontal))
		camera_mount.rotate_x(deg_to_rad(-event.relative.y*sens_vertical))

func _physics_process(delta: float) -> void:
	#if !animation_player.is_playing():
		#is_attacking = false
	
	#if Input.is_action_just_pressed("attack"):
		#if animation_player.current_animation != "1H_Melee_Attack_Slice_Horizontal":
			#animation_player.play("1H_Melee_Attack_Slice_Horizontal")
			#is_attacking = true
			
	if Input.is_action_pressed("shift"):
		SPEED = running_speed
		running = true
	else: 
		SPEED = walking_speed
		running = false
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		print("Direction: ", direction, " | Arrow rotation: ", debug_arrow.rotation_degrees)
		character_visual.look_at(position + -direction)
		debug_arrow.look_at(position + direction)
			
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
	else:
		#if !is_attacking:
			#if animation_player.current_animation != "Idle":
				#animation_player.play("Idle")
					
				velocity.x = move_toward(velocity.x, 0, SPEED)
				velocity.z = move_toward(velocity.z, 0, SPEED)
		
	if !is_attacking:
		move_and_slide()
