extends Node2D

@export var enemy_scene: PackedScene
@export var harpie_scene: PackedScene
@export var boss_scene: PackedScene
@export var spawn_interval: float = 2.0
@export var minimum_spawn_interval: float = 0.8
@export var spawn_distance: float = 420.0
@export var max_enemies: int = 20
@export var boss_spawn_time: float = 30.0
@export var boss_warning_duration: float = 2.0

@onready var player: Node = $Player
@onready var hp_label: Label = $UI/HPLabel
@onready var time_label: Label = $UI/TimeLabel
@onready var level_label: Label = $UI/LevelLabel
@onready var xp_label: Label = $UI/XPLabel
@onready var upgrade_label: Label = $UI/UpgradeLabel
@onready var boss_label: Label = $UI/BossLabel
@onready var death_label: Label = $UI/DeathLabel
@onready var victory_label: Label = $UI/VictoryLabel

var player_dead := false
var run_won := false
var spawn_timer := 0.0
var elapsed_time := 0.0
var upgrade_message_timer := 0.0
var boss_warning_timer := 0.0
var boss_event_started := false
var boss_spawned := false

func _ready() -> void:
	player.health_changed.connect(_on_player_health_changed)
	player.xp_changed.connect(_on_player_xp_changed)
	player.upgrade_applied.connect(_on_player_upgrade_applied)
	player.died.connect(_on_player_died)
	_on_player_health_changed(player.current_health, player.max_health)
	_on_player_xp_changed(player.level, player.current_xp, player.xp_to_next_level)

	for enemy in get_tree().get_nodes_in_group("enemy"):
		connect_enemy_signals(enemy)

func _process(delta: float) -> void:
	if (player_dead or run_won) and Input.is_key_pressed(KEY_R):
		get_tree().reload_current_scene()
		return

	if player_dead or run_won:
		return

	elapsed_time += delta
	spawn_timer -= delta
	upgrade_message_timer = max(upgrade_message_timer - delta, 0.0)
	time_label.text = "Time: %s" % format_time(elapsed_time)

	if upgrade_message_timer == 0.0:
		upgrade_label.visible = false

	if not boss_event_started and elapsed_time >= boss_spawn_time:
		start_boss_event()

	if boss_event_started and not boss_spawned:
		boss_warning_timer -= delta
		if boss_warning_timer <= 0.0:
			spawn_boss()

	if not boss_event_started and spawn_timer <= 0.0:
		spawn_enemy()
		spawn_timer = get_current_spawn_interval()

func _on_player_health_changed(current_health: int, max_health: int) -> void:
	hp_label.text = "HP: %d / %d" % [current_health, max_health]

func _on_player_xp_changed(level: int, current_xp: int, xp_to_next_level: int) -> void:
	level_label.text = "Level: %d" % level
	xp_label.text = "XP: %d / %d" % [current_xp, xp_to_next_level]

func _on_player_upgrade_applied(text: String) -> void:
	upgrade_label.text = text
	upgrade_label.visible = true
	upgrade_message_timer = 1.5

func _on_player_died() -> void:
	player_dead = true
	death_label.visible = true

func spawn_enemy() -> void:
	var scene_to_spawn := choose_enemy_scene()
	if scene_to_spawn == null:
		return
	if get_tree().get_nodes_in_group("enemy").size() >= max_enemies:
		return

	var enemy := scene_to_spawn.instantiate() as Node2D
	var angle := randf() * TAU
	var spawn_offset := Vector2(cos(angle), sin(angle)) * spawn_distance
	enemy.global_position = player.global_position + spawn_offset
	add_child(enemy)
	connect_enemy_signals(enemy)

func get_current_spawn_interval() -> float:
	var pressure := elapsed_time / 60.0
	return max(spawn_interval - pressure, minimum_spawn_interval)

func choose_enemy_scene() -> PackedScene:
	if harpie_scene == null:
		return enemy_scene
	if enemy_scene == null:
		return harpie_scene

	if randf() < 0.35:
		return harpie_scene

	return enemy_scene

func start_boss_event() -> void:
	boss_event_started = true
	boss_warning_timer = boss_warning_duration
	boss_label.text = "The Cyclops approaches..."
	boss_label.visible = true

func spawn_boss() -> void:
	if boss_scene == null:
		return

	boss_spawned = true
	boss_label.text = "Cyclops Boss"

	var boss := boss_scene.instantiate() as Node2D
	var spawn_offset := Vector2(spawn_distance, 0).rotated(randf() * TAU)
	boss.global_position = player.global_position + spawn_offset
	add_child(boss)
	connect_enemy_signals(boss)

func format_time(seconds: float) -> String:
	var total_seconds := int(seconds)
	var minutes := total_seconds / 60
	var remaining_seconds := total_seconds % 60
	return "%02d:%02d" % [minutes, remaining_seconds]

func connect_enemy_signals(enemy: Node) -> void:
	if enemy.has_signal("killed"):
		enemy.killed.connect(_on_enemy_killed)

func _on_enemy_killed(enemy: Node) -> void:
	if enemy.is_in_group("boss"):
		run_won = true
		victory_label.visible = true
		boss_label.text = "Cyclops defeated"
		boss_label.visible = true
