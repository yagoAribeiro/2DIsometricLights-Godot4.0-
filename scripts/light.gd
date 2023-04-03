#Source https://github.com/yagoAribeiro
#Code to cast light in some objects with collisions, change whatever you would like
#Sorry if my english is bad in comments, im Brazillian

extends PointLight2D
class_name Light

@export var controllable: bool = true
@onready var circle_area:CircleShape2D = get_node("Area2D/CollisionShape2D").shape
@export var shadow_scale: Vector2 = Vector2(1.0, 1.8)
var in_area: Array

func _process(_delta):
	#Optional only for testing light
	if Input.is_action_pressed("ui_select") and controllable:
		global_position = get_global_mouse_position()
		
	#Make circle radius equals to light texture radius	
	circle_area.radius = (texture.get_width()/2)*texture_scale
	
	#Code below run for every body that entered the area and had they shadow saved in "in_area" array
	for shadow in in_area:
		#check distance and if shadow is in_area
		var distance: float = abs(global_position.distance_to(shadow.global_position))
		var distance_percent: float = ((distance*100)/circle_area.radius)/100
		if distance_percent>1.0:
			in_area.remove_at(in_area.find(shadow))
			shadow.queue_free()
			continue
		apply_alpha(shadow, distance_percent)
		var angle: float = rad_to_deg(shadow.global_position.angle_to_point(global_position))
		apply_angle(shadow, angle)   

func is_duplicated(foot_reference: Marker2D)->bool:
	for shadow in in_area:
		if shadow.foot_reference == foot_reference:
			return true
	return false
	
func apply_alpha(shadow: CanvasItem, distance_percent: float)->void:
	var alpha: float = abs(1-distance_percent)
	shadow.modulate.a = alpha+(alpha*energy)/100
		
func apply_angle(shadow: Node2D, light_source_angle: float)->void:
	var new_angle: float 
	new_angle = light_source_angle-180+270
	shadow.skew = deg_to_rad(new_angle)
	shadow.scale.x = shadow_scale.x+abs(shadow.skew/100)
	shadow.scale.y = shadow_scale.y-abs(shadow.skew/100)  
		
func _on_area_2d_body_entered(body):
	if body is CharacterBody2D:
		#dont append shadows with duplicated reference from this light source
		if !is_duplicated(body.get_node("foot_pos")):
			#this code was tested with AnimatedSprite2D but can work with any CanvasItem instance
			#All variants used in this piece must be in a script in the target CanvasItem
			var shadow:AnimatedSprite2D = body.get_node("AnimatedSprite2D").duplicate()
			get_tree().root.call_deferred("add_child", shadow)
			shadow.offset = shadow.offset_origin
			shadow.centered = false
			#The object must be some "foot" reference for reference to cast shadow
			shadow.foot_reference = body.get_node("foot_pos")
			shadow.global_position = shadow.foot_reference.global_position
			shadow.modulate = Color(0,0,0,0)
			shadow.flip_v = true
			#Stores the shadow from body
			in_area.append(shadow)
		

