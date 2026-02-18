extends Line2D

@export var speed = 500
@onready var lava_ray: RayCast2D = $lavaRay

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if lava_ray.is_colliding():
		set_point_position(1,Vector2(0,lava_ray.get_collision_point().y+(get_global_position().y*-1)))
		

func _physics_process(delta: float) -> void:
	if lava_ray.is_colliding():
		set_point_position(1,Vector2(0,lava_ray.get_collision_point().y+(get_global_position().y*-1)))
	else:
		set_point_position(1,Vector2(0,min(get_point_position(1).y+(speed*delta),lava_ray.get_global_position().y)))
