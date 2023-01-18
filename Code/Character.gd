extends KinematicBody2D

onready var HitBox = $CollisionShape2D
onready var Texture = $Sprite

var velocity = Vector2.ZERO

export var life = 100
export var move_speed = 1200
export var gravity = 4000
export var jump = -1800

var dash = false

enum State {
	Idle, 
	Walk, 
	Dash, 
	Attack,
	Jump,
}

var dict_state = {
	0 : "Idle",
	1 : "Walk",
	2 : "Dash",
	3 : "Attack",
	4 : "Jump"
}

var state setget set_state, get_state
signal state_changed

#### ACCESSORS ####

func set_state(value):
	state = value
	emit_signal("state_changed")

func get_state():
	return state

#### BUILT-IN ####

func _ready():
	set_state(State.Idle)

func _get_input():
	if Input.is_action_pressed("move_right"):
		velocity.x += move_speed
	if Input.is_action_pressed("move_left"):
		velocity.x -= move_speed
	if Input.is_action_pressed("dash"):
		dash = true
	else : 
		dash = false

func _process(delta):
	if dash:
		set_state(State.Dash)
	else :
		if !is_on_floor():
			set_state(State.Jump)
		else : 
			if velocity == Vector2.ZERO:
				set_state(State.Idle)
			else :
				set_state(State.Walk)
	
	if velocity.x < 0 : 
		Texture.flip_h = true
	elif velocity.x > 0 : 
		Texture.flip_h = false

func _physics_process(delta):
	velocity.x = 0 
	_get_input()
	
	velocity.y += gravity * delta
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or is_on_wall():
			velocity.y = jump

#### LOGIC ####
#### REPONSES ####
