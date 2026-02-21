extends Control
class_name UpgradeMenu

var wave_manager: WaveManager

func setup(wm: WaveManager) -> void:
	wave_manager = wm

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()

func _on_more_enemies_pressed() -> void:
	wave_manager.apply_upgrade("more_enemies")

func _on_more_health_pressed() -> void:
	wave_manager.apply_upgrade("more_health")

func _on_more_damage_pressed() -> void:
	wave_manager.apply_upgrade("more_damage")
