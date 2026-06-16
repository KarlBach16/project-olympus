extends CharacterBody2D

signal health_changed(current_health: int, max_health: int)
signal xp_changed(level: int, current_xp: int, xp_to_next_level: int)
signal upgrade_applied(text: String)
signal died

@export var speed: float = 220.0
@export var max_health: int = 10
@export var attack_damage: int = 1
@export var attack_range: float = 135.0
@export var attack_cooldown: float = 0.8
@export var walk_frame_1: Texture2D
@export var walk_frame_2: Texture2D
@export var walk_animation_speed: float = 5.0

var facing_right := true

var current_health: int
var level := 1
var current_xp := 0
var xp_to_next_level := 5
var is_dead := false
var attack_timer := 0.0
var walk_animation_time := 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var attack_visual: Polygon2D = $AttackVisual

func _ready() -> void:
	current_health = max_health
	attack_visual.visible = false
	if walk_frame_1 != null:
		sprite.texture = walk_frame_1
	health_changed.emit(current_health, max_health)
	xp_changed.emit(level, current_xp, xp_to_next_level)

func _physics_process(delta: float) -> void:
	if is_dead:
		velocity = Vector2.ZERO
		return

	attack_timer = max(attack_timer - delta, 0.0)

	var direction := Vector2.ZERO

	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		direction.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		direction.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		direction.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		direction.y += 1.0

	velocity = direction.normalized() * speed
	move_and_slide()
	update_walk_animation(direction, delta)

	if attack_timer == 0.0:
		attack_nearest_enemy()

func update_walk_animation(direction: Vector2, _delta: float) -> void:
	if walk_frame_1 == null or walk_frame_2 == null:
		return

	if direction.x > 0.0:
		facing_right = true
	elif direction.x < 0.0:
		facing_right = false

	sprite.flip_h = false

	if facing_right:
		sprite.texture = walk_frame_1
	else:
		sprite.texture = walk_frame_2

func take_damage(amount: int) -> void:
	if is_dead:
		return

	current_health = max(current_health - amount, 0)
	health_changed.emit(current_health, max_health)

	if current_health == 0:
		is_dead = true
		velocity = Vector2.ZERO
		died.emit()

func attack_nearest_enemy() -> void:
	var nearest_enemy := find_nearest_enemy()
	if nearest_enemy == null:
		return

	var attack_direction := global_position.direction_to(nearest_enemy.global_position)
	attack_visual.position = attack_direction * 62.0
	attack_visual.rotation = attack_direction.angle()
	attack_visual.visible = true

	if nearest_enemy.has_method("take_damage"):
		nearest_enemy.take_damage(attack_damage)

	attack_timer = attack_cooldown
	await get_tree().create_timer(0.12).timeout
	attack_visual.visible = false

func find_nearest_enemy() -> Node2D:
	var nearest_enemy: Node2D = null
	var nearest_distance := attack_range

	for enemy in get_tree().get_nodes_in_group("enemy"):
		if not enemy is Node2D:
			continue

		var distance := global_position.distance_to(enemy.global_position)
		if distance < nearest_distance:
			nearest_enemy = enemy
			nearest_distance = distance

	return nearest_enemy

func collect_xp(amount: int) -> void:
	if is_dead:
		return

	current_xp += amount

	while current_xp >= xp_to_next_level:
		current_xp -= xp_to_next_level
		level += 1
		xp_to_next_level += 3
		apply_random_upgrade()

	xp_changed.emit(level, current_xp, xp_to_next_level)

func apply_random_upgrade() -> void:
	var upgrade_index := randi_range(0, 2)

	if upgrade_index == 0:
		attack_damage += 1
		upgrade_applied.emit("Level Up! +1 Damage")
	elif upgrade_index == 1:
		attack_cooldown = max(attack_cooldown * 0.9, 0.2)
		upgrade_applied.emit("Level Up! +10% Attack Speed")
	else:
		speed *= 1.1
		upgrade_applied.emit("Level Up! +10% Move Speed")
