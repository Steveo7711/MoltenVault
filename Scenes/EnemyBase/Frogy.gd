extends EnemyBase

@export var shoot_interval: float = 2.0
@export var bullet_speed: float = 75.0



@onready var jump_timer: Timer = $JumpTimer
@onready var shooter: Shooter = $Shooter
@onready var ribbet_sound: AudioStreamPlayer = $RibbetSound



const JUMP_VELOCITY_R: Vector2 = Vector2(100, -150)
const JUMP_VELOCITY_L: Vector2 = Vector2(-100, -150)

var _seen_player: bool = false
var _can_jump: bool = false

func _ready() -> void:
	$ShootTimer.wait_time = shoot_interval
	$ShootTimer.start()
	animated_sprite_2d.frame_changed.connect(_on_frame_changed)
	# Play ribbet on spawn with random pitch
	ribbet_sound.pitch_scale = randf_range(0.7, 1.4)
	ribbet_sound.play()

func shoot() -> void:
	if _player_ref == null or _seen_player == false:
		return
	animated_sprite_2d.play("attack")
	
func _on_frame_changed() -> void:
	if animated_sprite_2d.animation == "attack" and animated_sprite_2d.frame == 3:
		if _player_ref == null:
			return
		var direction = (_player_ref.global_position - global_position).normalized()
		SignalHub.emit_on_create_bullet(
			global_position,
			direction,
			bullet_speed,
			Constants.ObjectType.FROGY_BULLET
		)

func _on_shoot_timer_timeout() -> void:
	shoot()

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	velocity.y += delta * _gravity
	apply_jump()
	move_and_slide()
	flip_me()
	if is_on_floor():
		velocity.x = 0
	if animated_sprite_2d.animation != "attack":
		animated_sprite_2d.play("idle")


func _process(delta: float) -> void:
	if is_on_floor() == false:
		flip_me()
		if animated_sprite_2d.animation != "attack":
			animated_sprite_2d.play("fall")

func apply_jump() -> void:
	if _player_ref == null:
		return
	if is_on_floor() == false or _can_jump == false:
		return
	if _seen_player == false:
		return
	
	# Jump toward the player directly
	if _player_ref.global_position.x > global_position.x:
		velocity = JUMP_VELOCITY_R
	else:
		velocity = JUMP_VELOCITY_L
	
	_can_jump = false
	start_timer()
	animated_sprite_2d.play("jump")


func _on_jump_timer_timeout() -> void:
	_can_jump = true

func start_timer() -> void:
	jump_timer.wait_time = randf_range(2.0, 3.0)
	jump_timer.start()

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	if _seen_player == false:
		_seen_player = true
		start_timer()
