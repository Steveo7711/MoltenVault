extends Area2D

class_name Bullet

var _direction: Vector2 = Vector2(65, -65)
var bullet_owner: String = "player"  # or "enemy"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += _direction * delta


func setup(pos: Vector2, dir: Vector2, speed: float) -> void:
	_direction = dir.normalized() * speed
	global_position = pos

func _ready() -> void:
	# Disable monitoring for one frame so we don't collide on spawn
	monitoring = false
	await get_tree().physics_frame
	monitoring = true

func _on_body_entered(body: Node2D) -> void:
	if bullet_owner == "enemy":
		if body is Player or body is StaticBody2D or body is TileMapLayer:
			queue_free()
	elif bullet_owner == "player":
		if body is EnemyBase or body is StaticBody2D or body is TileMapLayer:
			queue_free()

func _on_area_entered(area: Area2D) -> void:
	# ignore other bullets
	if area is Bullet:
		return
	queue_free()
