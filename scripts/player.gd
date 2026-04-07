class_name player
extends BaseCharacter

@onready var camera_mount: Node3D = $Camera_Mount
#@export var last_look_offset: Vector2 = Vector2.ZERO
@export var sens_horizontal = 0.2
@export var sens_vertical = 0.2

func _ready():
	super._ready() # this is needed because character.gd has its own _ready, and if it does, it doesnt run the one of the children anymore.
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion:
		# 1. Camera rotatie
		rotate_y(deg_to_rad(-event.relative.x * sens_horizontal))
		character_visual.rotate_y(deg_to_rad(event.relative.x * sens_horizontal))
		camera_mount.rotate_x(deg_to_rad(-event.relative.y * sens_vertical))
		
		# 2. Geef de muisbeweging door aan de logica in BaseCharacter
		update_attack_direction(event.relative)

func get_input_direction() -> Vector2:
	return Input.get_vector("left", "right", "forward", "backward") 

func wants_to_attack() -> bool:
		return Input.is_action_just_pressed("attack")

func wants_to_block() -> bool:
	return Input.is_action_just_pressed("block") 

func wants_to_jump() -> bool:
	return Input.is_action_just_pressed("jump")

#func get_cursor_direction(): 
	#var screen_center = get_viewport().get_visible_rect().size / 2
	#var mouse_pos = get_viewport().get_mouse_position()
	#var offset = mouse_pos - screen_center
	##normalize to -1/1 range 
	#return Vector2(sign(offset.x), sign(offset.y))
