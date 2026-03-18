class_name Character
extends CharacterBody3D

@onready var attack_area_3d: Area3D = $CharacterVisual/Skeleton3D/BoneAttachment3D/Area3D
@onready var character_visual: Node3D = $CharacterVisual
@onready var debug_arrow: MeshInstance3D = $Debug_Arrow
@onready var animation_handler: Node3D = $CharacterVisual/AnimationHandler
@onready var label_3d: Label3D = $Node3D/Label3D


var SPEED = 3
const JUMP_VELOCITY = 4.5

var HP = 100
var running = false
var walking_speed = 3
var running_speed = 6

func _ready():
	attack_area_3d.body_entered.connect(_on_attack_body_entered)
	label_3d.text = "HP: " + str(HP) 
	#print("current characters affected: ", self.name )
	#print(label_3d.text)
	
func _physics_process(delta):
	if Input.is_action_pressed("shift"):
		SPEED = running_speed
		running = true
	else:
		SPEED = walking_speed
		running = false

	if not is_on_floor():
		velocity += get_gravity() * delta

	if wants_to_jump() and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# If attack is triggered and not currently active, call the animationHandler Node. 
	if wants_to_attack() and not animation_handler.is_in_state(animation_handler.ATTACK):
		animation_handler.call("set_animation_state", animation_handler.ATTACK)
		#print("current state attack: ", animation_handler.current_animation)
	elif wants_to_block() and not animation_handler.is_in_state(animation_handler.BLOCK):
		animation_handler.call("set_animation_state", animation_handler.BLOCK)

	# Ask the handler what state we're in, don't store it ourselves
	var is_attacking = animation_handler.is_in_state(animation_handler.ATTACK)
	var is_blocking = animation_handler.is_in_state(animation_handler.BLOCK)
	# var _is_walking = animation_handler.is_in_state(animation_handler.WALK)
	# var _is_running = animation_handler.is_in_state(animation_handler.RUN)
	# var _is_idle = animation_handler.is_in_state(animation_handler.IDLE)

	var input_dir := get_input_direction()
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var has_input := input_dir != Vector2.ZERO #just simply checks if there is any input, if the input vector is not zero, then there is input.
	
	if not is_attacking and not is_blocking:
		if has_input:
			character_visual.look_at(global_position - direction, Vector3.UP)
			debug_arrow.look_at(global_position + direction, Vector3.UP)
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED

			# Only horizontal speed for walk/run logic.
			var horizontal_speed := Vector2(velocity.x, velocity.z).length()

			if horizontal_speed > walking_speed + 0.01:
				animation_handler.call("set_animation_state", animation_handler.RUN, horizontal_speed)
				#print("current state run: ", animation_handler.current_animation)
			else:
				animation_handler.call("set_animation_state", animation_handler.WALK, horizontal_speed)
				#print("current state walk: ", animation_handler.current_animation)
		else:
			velocity.x = move_toward(velocity.x, 0.0, SPEED)
			velocity.z = move_toward(velocity.z, 0.0, SPEED)
			animation_handler.call("set_animation_state", animation_handler.IDLE, 0)
			
	move_and_slide()

func get_input_direction() -> Vector2:
	return Vector2.ZERO
		
func wants_to_attack() -> bool:
		
	return false
		
func wants_to_block() -> bool:
	return false
	
func wants_to_jump() -> bool:
	return false
	
func take_damage(amount: int)-> void:
	HP -= amount
	label_3d.text = "HP: " + str(HP) #this does not define the variable type, its just to change the int to a string for display purposes
	
func _on_attack_body_entered(body):
	if body == self:
		print(body.name ,"hit self, you can ignore this")
		return
	print(self.name ," hit ", body.name)
	
	body.take_damage(10)
	
	
