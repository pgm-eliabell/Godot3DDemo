extends Node

#@onready var animation_tree: AnimationTree = $AnimationTree
#@onready var animation_player: AnimationPlayer = $CharacterBasev15/AnimationPlayer

#@export var animation_tree: AnimationTree
#@export var animation_player: AnimationPlayer
@onready var animation_player: AnimationPlayer = $"../CharacterBlender/CharacterBasev19/AnimationPlayer"
@onready var animation_tree: AnimationTree = $"../CharacterBlender/AnimationTree"

#@onready var ShieldCollisionShape: CollisionShape3D = $CharacterVisual/CharacterBlender/CharacterBasev17/Armature/Skeleton3D/HandLeft/shieldv3/Area3D/CollisionShape3D
#@onready var SwordCollisionShape: CollisionShape3D = $CharacterVisual/CharacterBlender/CharacterBasev17/Armature/Skeleton3D/HandRight/swordv2/Area3D/CollisionShape3D

enum {IDLE, WALK, RUN, ATTACK, BLOCK}
var current_animation = IDLE
@export var blend_speed = 15


var walk_val = 0.0
var run_val = 0.0

var attack_timer = 0.0
var block_timer = 0.0
#@export var attack_duration = 1.5
#@export var block_duration = 1.0

#@export var attack_animation_name: StringName = &"Attack"
#@export var block_animation_name: StringName = &"BlockStance"

signal attack_ended

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
			animation_tree["parameters/BlendSpace2DAttack/blend_position"] = Vector2.ZERO
			attack_ended.emit()
	if block_timer > 0 and current_animation == BLOCK:
		block_timer -= delta
		#print("block_timer: ", block_timer) #use this to check if timers are a bit off
		if block_timer <= 0:
			current_animation = IDLE
			animation_tree["parameters/BlendSpace2DAttack/blend_position"] = Vector2.ZERO

	#handle_animation(delta)
	#update_tree()

# checks what the current state is, and compares it to the state it should be in. if true, return true, 
func is_in_state(state: int) -> bool:
	#print("current state: ", current_animation, "state to compare: ", state)
	# this will return 0,1,2,3,4 respectively, these are the indexes of the enum states defined at the top {idle, walk, run, attack, block} etc. 
	return current_animation == state

func set_animation_state(state: int, speed = 0.0, max_speed = 6.0, attack_dir = Vector2.ZERO):
	var anim_name = ""
	#print(attack_dir)
	if state == ATTACK:
		current_animation = ATTACK 
		# 1. choose which animation is being used based on direction
		if attack_dir.x > 0: anim_name = "AttackRight"
		elif attack_dir.x < 0: anim_name = "AttackLeft"
		elif attack_dir.y < 0: anim_name = "AttackUp"
		else: anim_name = "AttackDown"
		print("attack_dir: ", attack_dir)
		# 2. get the length of a certain animation
		attack_timer = _get_animation_length_or_fallback(anim_name, 1.5)
		
		# 3. play the animation 
		# print("anim_name: ", anim_name, "attack_timer: ", attack_timer )
		animation_tree["parameters/OneShotAttack/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		# print("this is the attackdir inside of animationHandler:", attack_dir)
		animation_tree["parameters/BlendSpace2DAttack/blend_position"] = attack_dir
		
	elif state == BLOCK:
		print("def_dir: ", attack_dir)
		#print("block has been triggered in animationHandler")
		current_animation = BLOCK
		# 1. choose which animation is being used based on direction
		var block_dir = attack_dir

		if block_dir.x > 0: anim_name = "BlockRight"
		elif block_dir.x < 0: anim_name = "BlockLeft"
		elif block_dir.y < 0: anim_name = "BlockUp"
		else: anim_name = "BlockDown"



		block_timer = _get_animation_length_or_fallback(anim_name, 1.5)
		#print("block_timer: ", block_timer)
		animation_tree["parameters/OneShotBlock/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		animation_tree["parameters/BlendSpace2DBlock/blend_position"] = block_dir
		
		
	elif state == WALK or state == RUN or state == IDLE:
		current_animation = state
		#print("is this current animation?", current_animation) #should return a index
		#print(animation_tree) #should print the current animationId of the animationTree
		animation_tree.active = true
		#print("speed: ",speed, "max_speed: ", max_speed)
		var blendValue = clamp(speed / max_speed, 0.0, 1.0)
		#print("this is the blendvalue: ",blendValue)
		animation_tree["parameters/BlendSpace1D/blend_position"] = blendValue
	else:
		current_animation = state
