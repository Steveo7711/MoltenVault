extends Area2D

class_name Pickup

@export var points: int = 5

@onready var anim: AnimatedSprite2D = $Anim
@onready var sound: AudioStreamPlayer2D = $Sound
@onready var PlayerRef: Player



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var ln: Array[String] = []
	for an_name in anim.sprite_frames.get_animation_names():
		ln.push_back(an_name)
	anim.animation = ln.pick_random()
	anim.play()
	Hud
	

func _on_area_entered(area: Area2D) -> void:
	if not area.owner is Player:
		return
	print("entered pickuphitbox")
	hide()
	set_deferred("monitoring", false)
	sound.play()
	SignalHub.on_scored.emit(points)
	ObjectMaker._is_pickup = Constants.ObjectType.PICKUP

func _on_sound_finished() -> void:
	queue_free()
