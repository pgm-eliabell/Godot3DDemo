class_name BaseCharacter
extends CharacterBody3D

#@onready var attack_area_3d: Area3D = $CharacterVisual/Skeleton3D/BoneAttachment3D/Area3D

@onready var character_visual: Node3D = $CharacterVisual #good 
@onready var debug_arrow: MeshInstance3D = $Debug_Arrow #good 
@onready var animation_handler: Node3D = $CharacterVisual/AnimationHandler
@onready var label_3d: Label3D = $Node3D/Label3D
@onready var center_direction: MeshInstance3D = $CenterDirection
@onready var arrow_left: MeshInstance3D = $CenterDirection/ArrowLeft
@onready var arrow_right: MeshInstance3D = $CenterDirection/ArrowRight
@onready var arrow_up: MeshInstance3D = $CenterDirection/ArrowUp
@onready var arrow_down: MeshInstance3D = $CenterDirection/ArrowDown

#@onready var ShieldCollisionShape: CollisionShape3D = $CharacterVisual/CharacterBlender/CharacterBasev19/Armature/Skeleton3D/HandLeft/shieldv3/Area3D/CollisionShape3D
#@onready var SwordCollisionShape: CollisionShape3D = $CharacterVisual/CharacterBlender/CharacterBasev19/Armature/Skeleton3D/HandRight/swordv2/Area3D/CollisionShape3D
#@onready var SwordCollisionShape: Area3D = $CharacterVisual/CharacterBlender/CharacterBasev19/Armature/Skeleton3D/HandRight/swordv2/Area3D
@onready var SwordCollisionShape: Area3D = $CharacterVisual/CharacterBlender/CharacterBasev19/Armature/Skeleton3D/HandLeft/shieldv3/Area3D
@onready var ShieldCollisionShape: Area3D = $CharacterVisual/CharacterBlender/CharacterBasev19/Armature/Skeleton3D/HandLeft/shieldv3/Area3D


var is_camera_locked : bool = true # locks the character based on the boolean, default locked
var last_attack_dir: Vector2 = Vector2.ZERO
var DIRECTION_THRESHOLD = 2.0


var SPEED = 3
const JUMP_VELOCITY = 4.5

var HP = 100
var running = false
var walking_speed = 3
var running_speed = 6

func _ready():
	#SwordCollisionShape.body_entered.connect(_on_attack_body_entered)
	label_3d.text = "HP: " + str(HP) 
	print("current characters affected: ", self.name )
	print(label_3d.text)
	
	
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
		print("wants to attack")
		animation_handler.call("set_animation_state", animation_handler.ATTACK, 0, 6.0, last_attack_dir)
		#print("current state attack: ", animation_handler.current_animation, "get_last_cursor_direction: ", get_last_cursor_direction())
		print("value sent -> animationhandler: ", get_last_cursor_direction())
	elif wants_to_block() and not animation_handler.is_in_state(animation_handler.BLOCK):
		animation_handler.call("set_animation_state", animation_handler.BLOCK, 0, 6.0, Vector2.ZERO)

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
			if is_camera_locked:
				character_visual.rotation.y = lerp_angle(character_visual.rotation.y, deg_to_rad(180) , delta * 10)
			else:
				# Gebruik een lerp voor vloeibare rotatie naar de looprichting
				var target_dir = global_position - direction
				var look_target = character_visual.global_position.direction_to(target_dir)
				if look_target != Vector3.ZERO:
					character_visual.look_at(target_dir, Vector3.UP)
					
			debug_arrow.look_at(global_position + direction, Vector3.UP)
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED

			# Only horizontal speed for walk/run logic.
			var horizontal_speed := Vector2(velocity.x, velocity.z).length()

			if horizontal_speed > running_speed + 0.01: # A small threshold to prevent jitter between walk/run at low speeds
				#print("running: walking_speed: ", walking_speed, "horizontal_speed: ", horizontal_speed)
				animation_handler.call("set_animation_state", animation_handler.RUN, horizontal_speed, 6.0, Vector2.ZERO)
				#print("current state run: ", animation_handler.current_animation)
			else:
				#print("walking: walking_speed: ", walking_speed, "horizontal_speed: ", horizontal_speed)
				animation_handler.call("set_animation_state", animation_handler.WALK, horizontal_speed, 6.0, Vector2.ZERO)
				#print("current state walk: ", animation_handler.current_animation)
		else:
			velocity.x = move_toward(velocity.x, 0.0, SPEED)
			velocity.z = move_toward(velocity.z, 0.0, SPEED)
			animation_handler.call("set_animation_state", animation_handler.IDLE, 0, 6.0, Vector2.ZERO)
			
	move_and_slide()
	var attack_dir = get_last_cursor_direction()
	#print("this is the debugdirection: ", attack_dir)
	DEBUG_give_attack_direction(attack_dir)

func update_attack_direction(input_delta: Vector2):
	if input_delta.length() > DIRECTION_THRESHOLD:
		if abs(input_delta.x) > abs(input_delta.y):
			last_attack_dir = Vector2(sign(input_delta.x), 0)
		else:
			last_attack_dir = Vector2(0, -sign(input_delta.y))

func get_last_cursor_direction() -> Vector2:
	return last_attack_dir

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
	if not body is BaseCharacter:
		print(self.name, " hit -> ", body.name, " you can ignore this")
		return
	print(self.name ," hit ", body.name)
	
	body.take_damage(10)
	
	
	
func set_arrow_color(mesh: MeshInstance3D, color: Color):
	var mat = mesh.get_active_material(0)
	if mat == null:
		mat = StandardMaterial3D.new()
		mesh.set_surface_override_material(0, mat)
	mat.albedo_color = color

func DEBUG_give_attack_direction(dir: Vector2):
	var default_color = Color(1, 1, 1)
	for arrow in [arrow_left, arrow_right, arrow_up, arrow_down]:
		set_arrow_color(arrow, default_color)

	if dir.x > 0: set_arrow_color(arrow_right, Color(1, 0, 0))
	elif dir.x < 0: set_arrow_color(arrow_left, Color(1, 0, 0))
	elif dir.y > 0: set_arrow_color(arrow_down, Color(1, 0, 0))
	elif dir.y < 0: set_arrow_color(arrow_up, Color(1, 0, 0))
