extends Node

const MAIN = preload("res://Scenes/Main/Main.tscn")
const LEVEL_BASE = preload("res://Scenes/LevelBase/LevelBase.tscn")
const ARENA = preload("res://Scenes/Arena/Arena.tscn")
const SCORES_PATH = "user://high_scores.tres"

var high_scores: HighScores = HighScores.new()
var cached_score: int
var current_level: PackedScene = LEVEL_BASE

func _input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_Q):
		load_main()

func set_current_level_arena() -> void:
	current_level = ARENA

func set_current_level_base() -> void:
	current_level = LEVEL_BASE

func restart_level() -> void:
	cached_score = 0
	get_tree().paused = false
	get_tree().change_scene_to_packed(current_level)

func load_main() -> void:
	cached_score = 0
	get_tree().change_scene_to_packed(MAIN)

func _ready() -> void:
	load_high_scores()

func _exit_tree() -> void:
	save_high_scores()

func load_high_scores() -> void:
	if ResourceLoader.exists(SCORES_PATH):
		high_scores = load(SCORES_PATH)

func save_high_scores() -> void:
	ResourceSaver.save(high_scores, SCORES_PATH)

func try_add_new_score(score: int) -> void:
	high_scores.add_new_score(score)
	save_high_scores()
	cached_score = score
