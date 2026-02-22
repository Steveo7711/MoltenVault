extends Control
class_name Main

@onready var play_button: TextureButton = $VBButtons/PlayButton
@onready var quit_button: TextureButton = $VBButtons/QuitButton
@onready var arena_button: TextureButton = $VBButtons/ArenaButton
@onready var scores_container: VBoxContainer = $ScoresContainer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sound: AudioStreamPlayer = $Sound
@onready var particles: CPUParticles2D = $CPUParticles2D
@onready var button_sound: AudioStreamPlayer = $ButtonSound


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	play_button.pressed.connect(_on_play_pressed)
	arena_button.pressed.connect(_on_arena_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	_populate_scores()
	animation_player.play("fade_in")
	sound.play()
	particles.emitting = true
	


func _populate_scores() -> void:
	for child in scores_container.get_children():
		child.queue_free()

	var scores: Array = GameManager.high_scores.get_scores_list()
	
	var label: Label = Label.new()
	if scores.is_empty():
		label.text = "No scores yet!"
	else:
		var best: HighScore = scores[0]
		label.text = "Personal Best: %03d" % best.score
	
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	scores_container.add_child(label)



func _on_play_pressed() -> void:
	button_sound.play()
	animation_player.play("fade_out")
	await animation_player.animation_finished
	GameManager.set_current_level_base()
	GameManager.restart_level()

func _on_arena_pressed() -> void:
	button_sound.play()
	animation_player.play("fade_out")
	await animation_player.animation_finished
	GameManager.set_current_level_arena()
	GameManager.restart_level()

func _on_quit_pressed() -> void:
	button_sound.play()
	animation_player.play("fade_out")
	await animation_player.animation_finished
	get_tree().quit()


func _on_sound_finished() -> void:
	sound.play()
