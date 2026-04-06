class_name player 
extends BaseCharacter

@onready var camera_mount: Node3D = $Camera_Mount

@export var sens_horizontal = 0.5
@export var sens_vertical = 0.5

func _ready():
	super._ready() # this is needed because character.gd has its own _ready, and if it does, it doesnt run the one of the children anymore.
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sens_horizontal))
		character_visual.rotate_y(deg_to_rad(event.relative.x * sens_horizontal))
		camera_mount.rotate_x(deg_to_rad(-event.relative.y * sens_vertical))

func get_input_direction() -> Vector2:
	return Input.get_vector("left", "right", "forward", "backward") 

func wants_to_attack() -> bool:
		return Input.is_action_just_pressed("attack")

func wants_to_block() -> bool:
	return Input.is_action_just_pressed("block") 

func wants_to_jump() -> bool:
	return Input.is_action_just_pressed("jump")
