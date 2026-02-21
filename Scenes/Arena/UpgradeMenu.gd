extends Control
class_name UpgradeMenu

@onready var wave_manager: WaveManager = $"../WaveManager"

func _ready() -> void:
	hide()
	wave_manager.wave_complete.connect(_show_upgrade_menu)

func _show_upgrade_menu() -> void:
	show()
	get_tree().paused = true

func _on_more_enemies_pressed() -> void:
	get_tree().paused = false
	hide()
	wave_manager.apply_upgrade("more_enemies")

func _on_more_health_pressed() -> void:
	get_tree().paused = false
	hide()
	wave_manager.apply_upgrade("more_health")

func _on_more_damage_pressed() -> void:
	get_tree().paused = false
	hide()
	wave_manager.apply_upgrade("more_damage")
