extends Area2D

@onready var _can_be_killed: bool = true
var player_lives = Player.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_entered(area: Area2D) -> void:
	if _can_be_killed == true:
		player_lives.reduce_lives(player_lives.lives)
