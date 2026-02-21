extends Area2D
class_name Pickup

@export var points: int = 5

@onready var anim: AnimatedSprite2D = $Anim
@onready var sound: AudioStreamPlayer2D = $Sound

func _ready() -> void:
	var ln: Array[String] = []
	for an_name in anim.sprite_frames.get_animation_names():
		ln.push_back(an_name)
	anim.animation = ln.pick_random()
	anim.play()

func _on_area_entered(area: Area2D) -> void:
	print("Pickup hit by: ", area, " owner: ", area.owner)
	if not area.owner is Player:
		return
	var player = area.owner as Player
	player.add_hearts(1)
	hide()
	set_deferred("monitoring", false)
	sound.play()
	SignalHub.on_scored.emit(points)

func _on_sound_finished() -> void:
	queue_free()
