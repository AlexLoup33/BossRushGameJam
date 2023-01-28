extends RigidBody2D

var Player = get_node_or_null("res://Scene/Characters/Character.tscn")

func _ready():
	pass

func _process(delta):
	if Player != null:
		look_at(Player)
