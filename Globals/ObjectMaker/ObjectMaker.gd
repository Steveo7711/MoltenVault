extends Node2D

var _is_pickup = null


const OBJECT_SCENES: Dictionary[Constants.ObjectType, PackedScene] = {
	Constants.ObjectType.BULLET_PLAYER: 
		preload("res://Scenes/Bullets/player_bullet.tscn"),
	Constants.ObjectType.BULLET_ENEMY: 
		preload("res://Scenes/Bullets/enemy_bullet.tscn"),
	Constants.ObjectType.CRYSTAL: 
		preload("res://Scenes/Pickup/Crystal.tscn"),
	Constants.ObjectType.PICKUP: 
		preload("res://Scenes/Pickup/pickup.tscn"),
	Constants.ObjectType.FROGY_BULLET:
		preload("res://Scenes/Bullets/enemy_bullet.tscn"),
	Constants.ObjectType.BOUNCING_BULLET:
		preload("res://Scenes/Bullets/BouncingBullet.tscn")
}


func _enter_tree() -> void:
	SignalHub.on_create_bullet.connect(on_create_bullet)
	SignalHub.on_create_object.connect(on_create_object)

func on_create_object(pos: Vector2, ob_type: Constants.ObjectType) -> void:
	if OBJECT_SCENES.has(ob_type) == false:
		return
	var newobj: Node2D = OBJECT_SCENES[ob_type].instantiate()
	newobj.global_position = pos
	get_tree().current_scene.add_child(newobj)  # change from call_deferred add_child

func on_create_bullet(pos: Vector2, dir: Vector2, speed: float, ob_type: Constants.ObjectType) -> void:
	if OBJECT_SCENES.has(ob_type) == false:
		return
	
	var nb: Bullet = OBJECT_SCENES[ob_type].instantiate()
	nb.setup(pos, dir, speed)
	
	# Set bullet owner based on type
	#if i add more bullet types later i might need to update the logic here to add more elif statments checking each bullet type!!!
	if ob_type == Constants.ObjectType.BULLET_PLAYER:
		nb.bullet_owner = "player"
	else:
		nb.bullet_owner = "enemy"
	
	add_child(nb)
