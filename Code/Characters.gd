extends KinematicBody2D

enum STATE {
	Idle, Walk, Run, Jump, Parry, Attack, Hurt
}



export var speed : int = 500
export var gravity : int = 400
export var jump : int = 300
var moving_direction :=  Vector2.ZERO

var facing_direction := Vector2.ZERO setget set_facing_direction, get_facing_direction
signal facing_direction_changed

var state : int = STATE.Idle setget set_state, get_state
signal state_changed

#### ACCESSORS ####

func set_state(value :int) -> void:
	if state != value:
		state = value
	emit_signal("state_changed")

func get_state() -> int:
	return state

func set_facing_direction(value : Vector2) -> void:
	if facing_direction != value:
		facing_direction = value
	emit_signal("facing_direction_changed")

func get_facing_direction() -> Vector2:
	return facing_direction

#### BUILT-IN ####

func _process(delta):
	
	moving_direction = moving_direction.normalized()
	
	moving_direction.y += gravity * delta
	moving_direction = move_and_slide(moving_direction * speed)

func _input(event):
	moving_direction.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	
	if (moving_direction == Vector2.LEFT or moving_direction == Vector2.RIGHT) and  moving_direction != facing_direction:
		set_facing_direction(moving_direction)
	
	if Input.is_action_pressed("attack"):
		set_state(STATE.Attack)
	else : 
		set_state(STATE.Idle)
		if moving_direction != Vector2.ZERO:
			if Input.is_action_pressed("run"):
				speed = 700
				set_state(STATE.Run)
			speed = 500
			set_state(STATE.Walk)
	
	moving_direction = moving_direction.normalized()
	
	moving_direction = move_and_slide(moving_direction * speed)

#### LOGIC ####

func _update_animation():
	pass

#### Responses ####

func _on_state_changed():
	_update_animation()

func _on_facing_direction_changed():
	pass # Replace with function body.
