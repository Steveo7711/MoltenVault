extends Control
class_name Main

@onready var play_button: TextureButton = $VBButtons/PlayButton
@onready var quit_button: TextureButton = $VBButtons/QuitButton
@onready var scores_container: VBoxContainer = $ScoresContainer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	_populate_scores()
	# Fade in on load
	animation_player.play("fade_in")

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
	animation_player.play("fade_out")
	await animation_player.animation_finished
	GameManager.load_next_level()

func _on_quit_pressed() -> void:
	animation_player.play("fade_out")
	await animation_player.animation_finished
	get_tree().quit()
