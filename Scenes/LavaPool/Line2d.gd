extends Line2D
@export var speed = 500
@onready var lava_ray: RayCast2D = $lavaRay
@export var max_length: float = 350.0  # adjust to taste


func _ready() -> void:
	lava_ray.force_raycast_update()
	if lava_ray.is_colliding():
		var local_hit = to_local(lava_ray.get_collision_point())
		set_point_position(1, Vector2(0, local_hit.y))
	else:
		set_point_position(1, Vector2(0, max_length))


func _physics_process(delta: float) -> void:
	if lava_ray == null:
		return
	if lava_ray.is_colliding():
		var local_hit = to_local(lava_ray.get_collision_point())
		set_point_position(1, Vector2(0, local_hit.y))
	else:
		# No floor found, just draw to max length
		set_point_position(1, Vector2(0, max_length))
