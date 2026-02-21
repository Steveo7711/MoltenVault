extends EnemyBase
class_name Boss


@export var max_hp: int = 20
@export var attack_interval: float = 2.5
@export var bullet_speed: float = 120.0
@export var burst_count: int = 5          # bullets per aimed burst
@export var burst_delay: float = 0.15     # seconds between burst shots
@export var spiral_count: int = 12        # bullets in one spiral ring
@export var spiral_rings: int = 4         # how many rings to fire
@export var spiral_ring_delay: float = 0.2
@export var bounce_count: int = 6         # bouncing bullets per attack
@export var move_speed: float = 60.0
@export var jump_velocity: float = -320.0         # upward force on jump
@export var jump_horizontal_force: float = 120.0  # horizontal force toward player when jumping
@export var jump_height_threshold: float = 40.0   # how much higher player must be to trigger jump
@export var jump_timer_min: float = 2.0           # min seconds between timer-based jumps
@export var jump_timer_max: float = 4.0           # max seconds between timer-based jumps
@export var hazard_scene: PackedScene     # assign HazardZone.tscn in Inspector
@export var bullet_scale: float = 1.0
@export var hazard_drop_interval: float = 3.0  # seconds between drops
@export var hazard_size: float = 3.0
@export var hazard_height: float = 0.5

enum Phase { ONE, TWO, THREE }
enum Attack { AIMED_BURST, SPIRAL, BOUNCING }

var _hp: int
var _current_phase: Phase = Phase.ONE
var _is_attacking: bool = false
var _move_direction: float = 1.0
var _move_timer: float = 0.0
var _move_change_interval: float = 2.0
var _jump_timer: float = 0.0
var _next_jump_time: float = 0.0
var _hazard_drop_timer: float = 0.0
var _active_bullets: Array = []

@onready var attack_timer: Timer = $AttackTimer
@onready var visible_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

func _ready() -> void:
	_hp = max_hp
	set_physics_process(false)
	attack_timer.stop()
	animated_sprite_2d.play("idle")  # just idle while waiting off screen
	
	# Wait until visible
	if not visible_notifier.is_on_screen():
		await visible_notifier.screen_entered
	
	# Now do spawn animation
	animated_sprite_2d.play("spawn")
	await animated_sprite_2d.animation_finished
	animated_sprite_2d.play("idle")
	
	# Now activate
	set_physics_process(true)
	attack_timer.wait_time = attack_interval
	attack_timer.connect("timeout", _on_attack_timer_timeout)
	attack_timer.start()
	_next_jump_time = randf_range(jump_timer_min, jump_timer_max)


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	velocity.y += delta * _gravity
	_handle_movement(delta)
	_handle_jump(delta)
	move_and_slide()
	flip_me()


func _handle_movement(delta: float) -> void:
	if _player_ref == null:
		return
	_move_timer += delta
	if _move_timer >= _move_change_interval:
		_move_timer = 0.0
		_move_change_interval = randf_range(1.5, 3.0)
		_move_direction = 1.0 if _player_ref.global_position.x > global_position.x else -1.0
	velocity.x = move_speed * _move_direction

	# Drop hazard zone periodically while moving
	_hazard_drop_timer += delta
	if _hazard_drop_timer >= hazard_drop_interval:
		_hazard_drop_timer = 0.0
		spawn_hazard(global_position + Vector2(0, 32))  # tweak 40 to match boss height

func _handle_jump(delta: float) -> void:
	if _player_ref == null or not is_on_floor():
		return

	var player_is_higher: bool = (global_position.y - _player_ref.global_position.y) > jump_height_threshold

	# Tick the jump timer
	_jump_timer += delta

	# Jump if player is significantly above OR the jump timer fires
	var timer_jump: bool = _jump_timer >= _next_jump_time
	if player_is_higher or timer_jump:
		_do_jump()
		_jump_timer = 0.0
		_next_jump_time = randf_range(jump_timer_min, jump_timer_max)

func _do_jump() -> void:
	if _player_ref == null:
		return
	velocity.y = jump_velocity
	# Push horizontally toward the player during the jump
	var dir_to_player: float = sign(_player_ref.global_position.x - global_position.x)
	velocity.x = jump_horizontal_force * dir_to_player


func _update_phase() -> void:
	var hp_pct: float = float(_hp) / float(max_hp)
	if hp_pct > 0.66:
		_current_phase = Phase.ONE
	elif hp_pct > 0.33:
		_current_phase = Phase.TWO
	else:
		_current_phase = Phase.THREE

func take_damage(amount: int = 1) -> void:
	_hp -= amount
	_update_phase()
	if _hp <= 0:
		die()


func _on_attack_timer_timeout() -> void:
	if _is_attacking or _player_ref == null:
		return
	match _current_phase:
		Phase.ONE:
			_start_attack(Attack.AIMED_BURST)
		Phase.TWO:
			_start_attack(Attack.SPIRAL)
		Phase.THREE:
			# Randomly pick spiral or bouncing in phase 3
			var pick: Attack = Attack.SPIRAL if randf() < 0.5 else Attack.BOUNCING
			_start_attack(pick)

func _start_attack(attack: Attack) -> void:
	_is_attacking = true
	match attack:
		Attack.AIMED_BURST:
			await _do_aimed_burst()
		Attack.SPIRAL:
			await _do_spiral()
		Attack.BOUNCING:
			await _do_bouncing()
	_is_attacking = false

func _do_aimed_burst() -> void:
	if _player_ref == null:
		return
	for i in range(burst_count):
		if not is_instance_valid(self):
			return
		var dir: Vector2 = (_player_ref.global_position - global_position).normalized()
		var nb: BouncingBullet = preload("res://Scenes/Bullets/BouncingBullet.tscn").instantiate()
		nb.max_bounces = 0
		nb.bullet_owner = "enemy"
		nb.scale = Vector2(bullet_scale, bullet_scale)
		nb.setup(global_position, dir, bullet_speed)
		get_tree().current_scene.add_child(nb)
		_active_bullets.append(nb)
		await get_tree().create_timer(burst_delay).timeout

func _do_spiral() -> void:
	for ring in range(spiral_rings):
		if not is_instance_valid(self):
			return
		for i in range(spiral_count):
			var angle: float = (TAU / spiral_count) * i + (TAU / spiral_count / spiral_rings) * ring
			var dir: Vector2 = Vector2(cos(angle), sin(angle))
			var nb: BouncingBullet = preload("res://Scenes/Bullets/BouncingBullet.tscn").instantiate()
			nb.max_bounces = 0
			nb.bullet_owner = "enemy"
			nb.scale = Vector2(bullet_scale, bullet_scale)
			nb.setup(global_position, dir, bullet_speed * 0.7)
			get_tree().current_scene.add_child(nb)
			_active_bullets.append(nb)
		await get_tree().create_timer(spiral_ring_delay).timeout

func _do_bouncing() -> void:
	if _player_ref == null:
		return
	for i in range(bounce_count):
		if not is_instance_valid(self):
			return
		var base_dir: Vector2 = (_player_ref.global_position - global_position).normalized()
		var spread_angle: float = deg_to_rad(randf_range(-30.0, 30.0))
		var dir: Vector2 = base_dir.rotated(spread_angle)
		var nb: BouncingBullet = preload("res://Scenes/Bullets/BouncingBullet.tscn").instantiate()
		nb.max_bounces = 3
		nb.bullet_owner = "enemy"
		nb.scale = Vector2(bullet_scale, bullet_scale)
		nb.setup(global_position, dir, bullet_speed)
		get_tree().current_scene.add_child(nb)
		_active_bullets.append(nb)
		await get_tree().create_timer(0.1).timeout
		

func spawn_hazard(pos: Vector2) -> void:
	if hazard_scene == null:
		return
	var hz = hazard_scene.instantiate()
	hz.global_position = pos
	hz.hazard_scale = hazard_size
	hz.hazard_height_scale = hazard_height
	get_tree().current_scene.add_child(hz)


func _on_hit_box_area_entered(area: Area2D) -> void:
	if area is Bullet and area.bullet_owner == "player":
		take_damage(1)

func die() -> void:
	set_physics_process(false)
	attack_timer.stop()
	
	# Clean up any lingering bullets
	for b in _active_bullets:
		if is_instance_valid(b):
			b.queue_free()
	_active_bullets.clear()
	
	animated_sprite_2d.play("die")
	await animated_sprite_2d.animation_finished
	SignalHub.emit_on_boss_killed()
	super.die()
