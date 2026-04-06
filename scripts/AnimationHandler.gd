extends Node

@onready var animation_tree: AnimationTree = $"../AnimationTree"
@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"

enum {IDLE, WALK, RUN, ATTACK, BLOCK}
var current_animation = IDLE
@export var blend_speed = 15

var walk_val = 0.0
var run_val = 0.0

var attack_timer = 0.0
var block_timer = 0.0
@export var attack_duration = 1.5
@export var block_duration = 1.0
@export var attack_animation_name: StringName = &"Attack"
@export var block_animation_name: StringName = &"BlockStance"

func _get_animation_length_or_fallback(animation_name: StringName, fallback: float) -> float:
	var anim := animation_player.get_animation(animation_name)
	if anim:
		return anim.length

	push_warning("Animation '%s' was not found on AnimationPlayer. Using fallback duration %s." % [animation_name, fallback])
	return fallback

#if block or an attack has been done, default to idle
func _physics_process(delta):
	if attack_timer > 0 and current_animation == ATTACK:
		#print("attack timer psyhyc triggered:", attack_timer)
		attack_timer -= delta
		if attack_timer <= 0:
			current_animation = IDLE
			animation_tree["parameters/BlendSpace1DMovement/blend_position"] = 0.0
	if block_timer > 0 and current_animation == BLOCK:
		block_timer -= delta
		if block_timer <= 0:
			current_animation = IDLE
			animation_tree["parameters/BlendSpace1DMovement/blend_position"] = 0.0

	#handle_animation(delta)
	#update_tree()

# checks what the current state is, and compares it to the state it should be in. if true, return true, 
func is_in_state(state: int) -> bool:
	#print("current state: ", current_animation, "state to compare: ", state)
	# this will return 0,1,2,3,4 respectively, these are the indexes of the enum states defined at the top {idle, walk, run, attack, block} etc. 
	return current_animation == state

func set_animation_state(state: int, speed = 0.0, max_speed = 6.0):
	if state == ATTACK:
		current_animation = ATTACK 
		#var attack_timer2 = animation_player.current_animation_length
		#var currentTestAnim = animation_player.current_animation
		#print("this is the current running animation", currentTestAnim)
		#print("attack_timer2:", attack_timer2)
		attack_timer = _get_animation_length_or_fallback(attack_animation_name, attack_duration)
		#print("attack_timer1:", attack_timer)
		animation_tree["parameters/oneshotAttack/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	elif state == BLOCK:
		current_animation = BLOCK
		block_timer = _get_animation_length_or_fallback(block_animation_name, block_duration)
		animation_tree["parameters/oneshotBlock/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	elif state == WALK or state == RUN or state == IDLE:
		current_animation = state
		animation_tree.active = true
		var blendValue = clamp(speed / max_speed, 0.0, 1.0)
		#print(blendValue)
		animation_tree["parameters/BlendSpace1DMovement/blend_position"] = blendValue
	else:
		current_animation = state
