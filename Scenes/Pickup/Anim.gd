extends AnimatedSprite2D

# Speed of the rainbow cycle
@export var speed: float = 0.5 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Calculate hue based on time: (time * speed) modulo 1.0
	var hue = fmod(Time.get_ticks_msec() * 0.0001 * speed, 1.0)
	# Set modulation using HSV: Hue, Saturation, Value, Alpha
	self.modulate = Color.from_hsv(hue, 1.0, 1.0, 1.0)
