extends Node2D

func _ready() -> void:
	GameManager.set_current_level_base()
	SignalHub.on_boss_killed.connect(_on_boss_killed)

func _on_boss_killed() -> void:
	await get_tree().create_timer(1.0).timeout
	SignalHub.emit_on_level_complete(true)

func _exit_tree() -> void:
	if SignalHub.on_boss_killed.is_connected(_on_boss_killed):
		SignalHub.on_boss_killed.disconnect(_on_boss_killed)
