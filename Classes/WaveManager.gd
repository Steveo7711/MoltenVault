extends Node
class_name WaveManager

@export var frog_scene: PackedScene
@export var boss_scene: PackedScene
@export var upgrade_menu_scene: PackedScene
@export var kills_to_boss: int = 10

var _kill_count: int = 0
var _wave: int = 1
var _boss_spawned: bool = false
var _enemy_health_multiplier: float = 1.0
var _enemy_damage_multiplier: float = 1.0
var _enemy_count_multiplier: float = 1.0
var _spawn_markers: Array = []
var _upgrade_menu: UpgradeMenu

signal wave_complete

func _ready() -> void:
	SignalHub.on_enemy_killed.connect(_on_enemy_killed)
	await get_tree().process_frame
	_spawn_markers = get_tree().get_nodes_in_group("spawn_points")
	print("Spawn markers found: ", _spawn_markers.size())
	await get_tree().create_timer(2.0).timeout
	start_wave()

func start_wave() -> void:
	_kill_count = 0
	_boss_spawned = false
	var count = int(5 * _enemy_count_multiplier)
	for i in range(count):
		await get_tree().create_timer(0.5).timeout
		spawn_enemy()

func spawn_enemy() -> void:
	if _spawn_markers.is_empty():
		return
	var marker = _spawn_markers.pick_random()
	var enemy = frog_scene.instantiate()
	get_tree().current_scene.add_child(enemy)
	await get_tree().process_frame
	enemy.global_position = marker.global_position + Vector2(0, -32)
	enemy._seen_player = true
	enemy.start_timer()

func _on_enemy_killed() -> void:
	if _boss_spawned or _kill_count >= kills_to_boss:
		return
	_kill_count += 1
	if _kill_count < kills_to_boss:
		spawn_enemy()
	if _kill_count >= kills_to_boss:
		_boss_spawned = true
		spawn_boss()

func spawn_boss() -> void:
	if boss_scene == null:
		return
	await get_tree().create_timer(1.0).timeout
	var best_marker = _spawn_markers[0]
	var furthest_dist: float = 0.0
	var player = get_tree().get_first_node_in_group(Constants.PLAYER_GROUP)
	if player:
		for marker in _spawn_markers:
			var dist = marker.global_position.distance_to(player.global_position)
			if dist > furthest_dist:
				furthest_dist = dist
				best_marker = marker
	var boss = boss_scene.instantiate()
	get_tree().current_scene.add_child(boss)
	boss.global_position = best_marker.global_position + Vector2(0, -32)
	if SignalHub.on_boss_killed.is_connected(_on_boss_killed):
		SignalHub.on_boss_killed.disconnect(_on_boss_killed)
	SignalHub.on_boss_killed.connect(_on_boss_killed)

func _on_boss_killed() -> void:
	_boss_spawned = false
	_wave += 1
	await get_tree().create_timer(1.5).timeout
	_show_upgrade_menu()

func _show_upgrade_menu() -> void:
	if _upgrade_menu == null and upgrade_menu_scene != null:
		_upgrade_menu = upgrade_menu_scene.instantiate()
		_upgrade_menu.setup(self)
		get_parent().get_node("CanvasLayer").add_child(_upgrade_menu)
	if _upgrade_menu:
		_upgrade_menu.show()
		get_tree().paused = true

func apply_upgrade(choice: String) -> void:
	match choice:
		"more_enemies":
			_enemy_count_multiplier += 0.5
		"more_health":
			_enemy_health_multiplier += 0.5
		"more_damage":
			_enemy_damage_multiplier += 0.5
	get_tree().paused = false
	_upgrade_menu.hide()
	await get_tree().process_frame
	start_wave()
