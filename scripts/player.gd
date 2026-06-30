class_name player
extends BaseCharacter


@onready var camera_pitch: Node3D = $Camera_Mount/CameraPitch
@onready var camera_free: Camera3D = $Camera_Mount/CameraPitch/Camera3D 
@onready var camera_locked: Camera3D = $Camera_Mount/Camera3DLocked 

@onready var camera_mount_free: Node3D = $Camera_Mount

@export var sens_horizontal = 0.2
@export var sens_vertical = 0.2

func _ready():
	super._ready()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# start with a locked camera
	camera_locked.make_current()

func _input(event):
	# Camera Lock change
	if Input.is_action_just_pressed("camera_lock"):
		print("camera has been locked/unlocked")
		is_camera_locked = !is_camera_locked
		
		if is_camera_locked:
			camera_locked.make_current()
			# reset all to the front
			character_visual.rotation.y = 0
			camera_mount_free.rotation.y = 0
			camera_pitch.rotation.x = 0
		else:
			camera_free.make_current()
			# Optioneel: draai visual om als je model verkeerd om staat
			# character_visual.rotation.y = deg_to_rad(180) 

	# Muisbeweging
	if event is InputEventMouseMotion:	
		if is_camera_locked:
			# 1. Horizontaal: Draai het hele lichaam
			rotate_y(deg_to_rad(-event.relative.x * sens_horizontal))
			# 2. Verticaal: Draai de locked camera omhoog/omlaag
			camera_locked.rotate_x(deg_to_rad(-event.relative.y * sens_vertical))
			camera_locked.rotation.x = clamp(camera_locked.rotation.x, deg_to_rad(-80), deg_to_rad(80))
		else:
			# 1. Horizontaal: Draai alleen de mount (lichaam blijft staan)
			camera_mount_free.rotate_y(deg_to_rad(-event.relative.x * sens_horizontal))
			# 2. Verticaal: Draai de pitch node voor de free-camera
			camera_pitch.rotate_x(deg_to_rad(-event.relative.y * sens_vertical))
			camera_pitch.rotation.x = clamp(camera_pitch.rotation.x, deg_to_rad(-80), deg_to_rad(80))
		
		# Update attack direction (pijlen)
		update_attack_direction(event.relative)

func get_input_direction() -> Vector2:
	return Input.get_vector("left", "right", "forward", "backward") 

func wants_to_attack() -> bool:
	return Input.is_action_just_pressed("attack")

func wants_to_block() -> bool:
	#print("wants to attack has been triggered in Player.gd")
	return Input.is_action_just_pressed("block") 

func wants_to_jump() -> bool:
	return Input.is_action_just_pressed("jump")
