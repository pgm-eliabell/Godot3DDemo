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

func _physics_process(delta):
	if attack_timer > 0:
		attack_timer -= delta
		#print(attack_timer)
		if attack_timer <= 0:
			current_animation = IDLE
			animation_tree.active = true 

	if block_timer > 0:
		block_timer -= delta
		if block_timer <= 0:
			current_animation = IDLE
			animation_tree.active = true

	handle_animation(delta)
	update_tree()

func is_in_state(state) -> bool:
	return current_animation == state

func play_attack():
	animation_tree.active = false  # hand control back to AnimationPlayer
	animation_player.play("Attack")
	current_animation = ATTACK
	attack_timer = animation_player.current_animation_length

func play_block():
	animation_tree.active = false
	animation_player.play("BlockStance")
	current_animation = BLOCK
	block_timer = animation_player.current_animation_length

func set_animation_state(state):
	print("set_anim_stat function ran")
	if state == ATTACK:
		play_attack()
	elif state == BLOCK:
		play_block()
	else:
		current_animation = state

func handle_animation(delta):
	match current_animation:
		IDLE:
			walk_val = lerpf(walk_val, 0, blend_speed * delta)
			run_val = lerpf(run_val, 0, blend_speed * delta)
		WALK:
			walk_val = lerpf(walk_val, 1, blend_speed * delta)
			run_val = lerpf(run_val, 0, blend_speed * delta)
		RUN:
			walk_val = lerpf(walk_val, 0, blend_speed * delta)
			run_val = lerpf(run_val, 1, blend_speed * delta)
		ATTACK, BLOCK:
			walk_val = lerpf(walk_val, 0, blend_speed * delta)
			run_val = lerpf(run_val, 0, blend_speed * delta)

func update_tree():
	animation_tree["parameters/Walk/blend_amount"] = walk_val
	animation_tree["parameters/Run/blend_amount"] = run_val
