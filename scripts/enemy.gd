extends CharacterBody2D

signal killed(enemy: Node)

@export var speed: float = 90.0
@export var max_health: int = 3
@export var xp_orb_scene: PackedScene
@export var contact_damage: int = 1
@export var contact_range: float = 58.0
@export var damage_interval: float = 0.7
@export var hover_amplitude: float = 0.0
@export var hover_speed: float = 0.0
@export var flip_with_movement := false
@export var faces_right_by_default := true

var player: Node2D
var current_health: int
var damage_timer := 0.0
var hover_time := 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var sprite_start_position := sprite.position

func _ready() -> void:
	current_health = max_health
	player = get_tree().get_first_node_in_group("player") as Node2D

func _physics_process(delta: float) -> void:
	if player == null:
		return

	var direction := global_position.direction_to(player.global_position)
	update_sprite_direction(direction)
	velocity = direction * speed
	move_and_slide()

	damage_timer = max(damage_timer - delta, 0.0)
	if global_position.distance_to(player.global_position) <= contact_range and damage_timer == 0.0:
		if player.has_method("take_damage"):
			player.take_damage(contact_damage)
			damage_timer = damage_interval

	if hover_amplitude > 0.0:
		hover_time += delta
		sprite.position = sprite_start_position + Vector2(0.0, sin(hover_time * hover_speed) * hover_amplitude)

func update_sprite_direction(direction: Vector2) -> void:
	if not flip_with_movement or abs(direction.x) < 0.01:
		return

	if faces_right_by_default:
		sprite.flip_h = direction.x < 0.0
	else:
		sprite.flip_h = direction.x > 0.0

func take_damage(amount: int) -> void:
	current_health = max(current_health - amount, 0)
	modulate = Color(1.0, 0.55, 0.55, 1.0)
	await get_tree().create_timer(0.08).timeout
	modulate = Color.WHITE

	if current_health == 0:
		killed.emit(self)
		drop_xp_orb()
		queue_free()

func drop_xp_orb() -> void:
	if xp_orb_scene == null:
		return

	var orb := xp_orb_scene.instantiate() as Node2D
	orb.global_position = global_position
	get_parent().add_child(orb)
