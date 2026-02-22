extends Control

class_name Hud

var lives: int = 4

const GAME_OVER = preload("res://assests/sound/GameOver.wav")
const YOU_WIN = preload("res://assests/sound/LevelComplete.wav")


@onready var score_label: Label = $MarginContainer/ScoreLabel
@onready var hb_hearts: HBoxContainer = $MarginContainer/HBHearts
@onready var color_rect: ColorRect = $ColorRect
@onready var vb_game_over: VBoxContainer = $ColorRect/VBGameOver
@onready var vb_complete: VBoxContainer = $ColorRect/VBComplete
@onready var complete_timer: Timer = $CompleteTimer
@onready var sound: AudioStreamPlayer = $Sound
@onready var restart_label: Label = $ColorRect/VBGameOver/RestartLabel
@onready var level_complete_label: Label = $ColorRect/VBComplete/RestartLabel2

var _score: int = 0
var _hearts: Array 
var _can_continue: bool = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		GameManager.load_main()
	if _can_continue and event.is_action_pressed("jump"):
		GameManager.restart_level()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_hearts = hb_hearts.get_children()
	print("Hearts found: ", _hearts.size())  # confirm this prints 5
	_score = GameManager.cached_score
	on_scored(0)
	on_player_hit(lives, false)  # initialize hearts to correct state on start

func late_init() -> void:
	SignalHub.emit_on_player_hit(lives, false)  # this drives the initial heart display

func _enter_tree() -> void:
	SignalHub.on_scored.connect(on_scored)
	SignalHub.on_player_hit.connect(on_player_hit)
	SignalHub.on_level_complete.connect(on_level_complete)
	

func on_player_hit(lives: int, shake: bool) -> void:
	for index in range(_hearts.size()):
		_hearts[index].visible = lives > index
		
	if lives == 0:
		on_level_complete(false)

func on_level_complete(complete: bool) -> void:
	sound.stop()
	color_rect.show()
	restart_label.hide()
	level_complete_label.hide()  # add this
	if complete:
		vb_complete.show()
		sound.stream = YOU_WIN
	else:
		sound.stream = GAME_OVER
		vb_game_over.show()
	sound.play()
	get_tree().paused = true
	complete_timer.start()

func _exit_tree() -> void:
	GameManager.try_add_new_score(_score)

func on_scored(points: int) -> void:
	_score += points
	score_label.text = "%03d" % _score


func _on_complete_timer_timeout() -> void:
	_can_continue = true
	restart_label.show()  # show it after the timer fires
	level_complete_label.show()


func _on_sound_finished() -> void:
	pass
	#if sound.stream == BG_MUSIC:
		#sound.play()
