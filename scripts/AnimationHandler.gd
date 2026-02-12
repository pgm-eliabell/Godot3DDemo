extends Node

@onready var animation_tree: AnimationTree = $"../AnimationTree"

enum {IDLE, WALK, RUN, ATTACK, BLOCK}
var current_animation = IDLE
@export var blend_speed = 15

var walk_val = 0.0
var run_val = 0.0
var attack_val = 0.0
var block_val = 0.0

# Timers for one-shot animations
var attack_timer = 0.0
var block_timer = 0.0
@export var attack_duration = 0.6
@export var block_duration = 1.0

func _physics_process(delta):
	# Count down timers
	if attack_timer > 0:
		attack_timer -= delta
		if attack_timer <= 0:
			current_animation = IDLE

	if block_timer > 0:
		block_timer -= delta
		if block_timer <= 0:
			current_animation = IDLE

	handle_animation(delta)
	update_tree()

func play_attack():
	current_animation = ATTACK
	attack_timer = attack_duration

func play_block():
	current_animation = BLOCK
	block_timer = block_duration

func set_animation_state(state):
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
			attack_val = lerpf(attack_val, 0, blend_speed * delta)
			block_val = lerpf(block_val, 0, blend_speed * delta)
		WALK:
			walk_val = lerpf(walk_val, 1, blend_speed * delta)
			run_val = lerpf(run_val, 0, blend_speed * delta)
			attack_val = lerpf(attack_val, 0, blend_speed * delta)
			block_val = lerpf(block_val, 0, blend_speed * delta)
		RUN:
			walk_val = lerpf(walk_val, 0, blend_speed * delta)
			run_val = lerpf(run_val, 1, blend_speed * delta)
			attack_val = lerpf(attack_val, 0, blend_speed * delta)
			block_val = lerpf(block_val, 0, blend_speed * delta)
		ATTACK:
			walk_val = lerpf(walk_val, 0, blend_speed * delta)
			run_val = lerpf(run_val, 0, blend_speed * delta)
			attack_val = lerpf(attack_val, 1, blend_speed * delta)
			block_val = lerpf(block_val, 0, blend_speed * delta)
		BLOCK:
			walk_val = lerpf(walk_val, 0, blend_speed * delta)
			run_val = lerpf(run_val, 0, blend_speed * delta)
			attack_val = lerpf(attack_val, 0, blend_speed * delta)
			block_val = lerpf(block_val, 1, blend_speed * delta)

func update_tree():
	animation_tree["parameters/Walk/blend_amount"] = walk_val
	animation_tree["parameters/Run/blend_amount"] = run_val
	animation_tree["parameters/Attack/blend_amount"] = attack_val
	animation_tree["parameters/Block/blend_amount"] = block_val
