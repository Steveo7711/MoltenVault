extends Area2D
class_name HazardZone

@export var damage_interval: float = 0.8
@export var lifetime: float = 4.0
@export var fade_time: float = 1.0
@export var hazard_scale: float = 1.0
@export var hazard_height_scale: float = 1.0

var _damage_timer: float = 0.0
var _lifetime_timer: float = 0.0
var _player_inside: bool = false
var _player_ref: Player = null

func _ready() -> void:
	scale = Vector2(hazard_scale, hazard_height_scale)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	if _player_inside and _player_ref != null:
		_damage_timer += delta
		if _damage_timer >= damage_interval:
			_damage_timer = 0.0
			_player_ref.apply_hit()

	_lifetime_timer += delta
	var time_left: float = lifetime - _lifetime_timer
	if time_left <= fade_time:
		modulate.a = clampf(time_left / fade_time, 0.0, 1.0)
	if _lifetime_timer >= lifetime:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		_player_inside = true
		_player_ref = body
		_damage_timer = damage_interval

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		_player_inside = false
		_player_ref = null
		_damage_timer = 0.0
