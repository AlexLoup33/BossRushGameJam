extends KinematicBody2D

var velocity = Vector2.ZERO
var mouvement_speed = 15000

func _physics_process(delta):
	var collision = move_and_slide(velocity.normalized() * delta * mouvement_speed)

func _on_body_entered(body):
	if body.name == "Charater":
		body.get_damaged(50)
	queue_free()
