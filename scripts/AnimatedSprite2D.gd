extends AnimatedSprite2D

@export var offset_origin: Vector2 = Vector2(-8, -3)
var foot_reference: Marker2D

func _physics_process(_delta):
	if foot_reference!=null:
		global_position = foot_reference.global_position
