extends Line2D
@export var speed = 500
@onready var lava_ray: RayCast2D = $lavaRay


func _ready() -> void:
	lava_ray.force_raycast_update()
	if lava_ray.is_colliding():
		var local_hit = to_local(lava_ray.get_collision_point())
		set_point_position(1, Vector2(0, local_hit.y))

func _physics_process(delta: float) -> void:
	if lava_ray == null:
		print("ERROR: lava_ray is null!")
		return
	if lava_ray.is_colliding():
		var local_hit = to_local(lava_ray.get_collision_point())
		#print("Collision at local Y: ", local_hit.y, " | hitting: ", lava_ray.get_collider())
		set_point_position(1, Vector2(0, local_hit.y))
	else:
		set_point_position(1, Vector2(0, min(get_point_position(1).y + (speed * delta), to_local(lava_ray.get_global_position()).y)))
