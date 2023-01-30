extends KinematicBody2D

var Player = get_node_or_null("res://Scene/Characters/Character.tscn")
var prefabTir = preload("res://Scene/Bosses/Bullet.tscn")

func _ready():
	pass

func _process(delta):
	if Player != null:
		look_at(Player)
		shoot()
		yield(get_tree().create_timer(randi()%4), "timeout")

func shoot():
	var projectile = prefabTir.instance()
	get_parent().add_child(projectile)
	projectile.rotation_degrees = rotation_degrees
	
	projectile.position = $Position2D.global_position
	projectile.velocity = global_position - position
