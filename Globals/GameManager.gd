extends Node

const MAIN = preload("res://Scenes/Main/Main.tscn")
const LEVEL_BASE = preload("res://Scenes/LevelBase/LevelBase.tscn")
const ARENA = preload("res://Scenes/Arena/Arena.tscn")



const SCORES_PATH = "user://high_scores.tres"


var high_scores: HighScores = HighScores.new()

# score to carry over between levels
var cached_score: int:
	set (value):
		cached_score = value
	get:
		return cached_score


func _input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_Q):
		load_main()  

var current_level: String = "LevelBase"  # track current level

func load_next_level() -> void:
	current_level = "LevelBase"
	get_tree().change_scene_to_packed(LEVEL_BASE)

func restart_level() -> void:
	cached_score = 0
	get_tree().paused = false
	match current_level:
		"LevelBase":
			get_tree().change_scene_to_packed(LEVEL_BASE)
		"Arena":
			get_tree().change_scene_to_packed(ARENA)

func restart_arena() -> void:
	current_level = "Arena"
	cached_score = 0
	get_tree().paused = false
	get_tree().change_scene_to_packed(ARENA)
	
func _ready() -> void:
	load_high_scores()


func _exit_tree():
	save_high_scores()


func load_main():
	cached_score = 0
	get_tree().change_scene_to_packed(MAIN)


func load_high_scores():		
	if ResourceLoader.exists(SCORES_PATH):
		high_scores = load(SCORES_PATH)


func save_high_scores():
	ResourceSaver.save(high_scores, SCORES_PATH)


# try this each time game is over / level complete
func try_add_new_score(score: int):
	high_scores.add_new_score(score)
	save_high_scores()	
	cached_score = score
