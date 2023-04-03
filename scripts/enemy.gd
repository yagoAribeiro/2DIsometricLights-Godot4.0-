extends CharacterBody2D
@export var controllable: bool = true


func _physics_process(_delta):
	if controllable and Input.is_action_pressed("ui_select"):
		global_position = get_global_mouse_position()
