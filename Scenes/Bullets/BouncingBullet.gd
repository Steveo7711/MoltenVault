extends Bullet
class_name BouncingBullet

@export var max_bounces: int = 3

var _bounces_remaining: int
var _velocity: Vector2

func _ready() -> void:
	super._ready()
	bullet_owner = "enemy"
	_bounces_remaining = max_bounces

func setup(pos: Vector2, dir: Vector2, spd: float) -> void:
	super.setup(pos, dir, spd)
	_velocity = dir.normalized() * spd

func _process(delta: float) -> void:
	position += _velocity * delta

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		queue_free()
		return
	if body is StaticBody2D or body is TileMapLayer:
		if _bounces_remaining <= 0:
			queue_free()
			return
		_bounces_remaining -= 1
		var abs_vel = _velocity.abs()
		if abs_vel.x > abs_vel.y:
			_velocity.x = -_velocity.x
		else:
			_velocity.y = -_velocity.y
