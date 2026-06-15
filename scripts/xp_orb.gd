extends Area2D

@export var xp_value: int = 1
@export var pickup_range: float = 34.0

var player: Node2D

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") as Node2D

func _physics_process(_delta: float) -> void:
	if player == null:
		return

	if global_position.distance_to(player.global_position) <= pickup_range:
		if player.has_method("collect_xp"):
			player.collect_xp(xp_value)
			queue_free()
