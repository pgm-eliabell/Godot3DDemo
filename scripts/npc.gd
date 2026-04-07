class_name npc
extends BaseCharacter

func get_input_direction() -> Vector2:
	var dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	#print(dir)
	return dir
	
func wants_to_attack() -> bool:
	return Input.is_action_just_pressed("ui_accept")

func wants_to_block() -> bool:
	return Input.is_action_just_pressed("block") 

func wants_to_jump() -> bool:
	return Input.is_action_just_pressed("jump")
