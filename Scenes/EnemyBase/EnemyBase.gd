extends CharacterBody2D


class_name EnemyBase


const FALL_OFF_Y: int = 200.0

@export var points: int = 1
@export var speed: float = 30.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var _player_ref: Player

var _gravity: float = 800.0



func _physics_process(delta: float) -> void:
	# Find player lazily if not found yet
	if _player_ref == null:
		_player_ref = get_tree().get_first_node_in_group(Constants.PLAYER_GROUP)
		return
	
	if global_position.y > FALL_OFF_Y:
		queue_free()

func flip_me() -> void:
	if _player_ref == null:
		return
	animated_sprite_2d.flip_h = _player_ref.global_position.x > animated_sprite_2d.global_position.x

func die() -> void:
	SignalHub.emit_on_create_object(
		global_position, Constants.ObjectType.PICKUP
	)
	#SignalHub.emit_on_create_object(
		#global_position, Constants.ObjectType.EXPLOSION
	#)
	SignalHub.on_scored.emit(points)
	set_physics_process(false)
	queue_free()


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	pass # Replace with function body.


func _on_hit_box_area_entered(area: Area2D) -> void:
	if area is Bullet and area.bullet_owner == "player":
		die()
