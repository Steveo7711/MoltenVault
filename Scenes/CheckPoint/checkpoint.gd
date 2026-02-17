extends Area2D

var _boss_killed: bool = true



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalHub.on_boss_killed.connect(on_boss_killed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func on_boss_killed() -> void:
	#_boss_killed = true
	pass




func _on_area_entered(area: Area2D) -> void:
	print("Level completed")
	SignalHub.emit_on_level_complete(true)
