extends KinematicBody2D

onready var HitBox = $CollisionShape2D
onready var Texture = $Sprite

var velocity = Vector2.ZERO

export var life = 100
export var move_speed = 1200
export var gravity = 4000
export var jump = -1800
export var jump_count = 0

var dash = false

enum State {
	Idle, 
	Walk, 
	Dash, 
	Attack,
	Jump,
	Parry,
}

enum Parry {
	Up,
	Mid, 
	Down,
}

var dict_state = {
	0 : "Idle",
	1 : "Walk",
	2 : "Dash",
	3 : "Attack",
	4 : "Jump"
}

var dict_parry = {
	0 : "Up",
	1 : "Middle",
	2 : "Down"
}

var state setget set_state, get_state
signal state_changed

var parry setget set_parry, get_parry
signal parry_changed

#### ACCESSORS ####

func set_state(value):
	state = value
	emit_signal("state_changed")

func get_state():
	return state

func set_parry(value):
	parry = value
	emit_signal("parry_changed")

func get_parry():
	return parry

#### BUILT-IN ####

func _ready():
	set_state(State.Idle)
	parry = Parry.Mid

func _get_input():
	#Movement System
	if Input.is_action_pressed("move_right"):
		velocity.x += move_speed
	if Input.is_action_pressed("move_left"):
		velocity.x -= move_speed
	if Input.is_action_pressed("dash"):
		dash = true
	else : 
		dash = false
	
	#Fight System
	if Input.is_action_pressed("attack"):
		set_state(State.Attack)
	if Input.is_action_pressed("parry"):
		set_state(State.Parry)
	
	#Parry System
	if Input.is_action_just_pressed("parry_up"):
		set_parry(Parry.Up)
	elif Input.is_action_just_pressed("parry_mid"):
		set_parry(Parry.Mid)
	elif Input.is_action_just_pressed("parry_down"):
		set_parry(Parry.Down)

func _process(delta):
	#Update State System
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
	
	#Flip the character Sprite and the Attack Box/Parry Box depend on the direction of the character
	if velocity.x < 0 : 
		Texture.flip_h = true
	elif velocity.x > 0 : 
		Texture.flip_h = false

func _physics_process(delta):
	velocity.x = 0 #reset the mouvement of the player for not let him infinite slide
	_get_input()
	
	velocity.y += gravity * delta
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
	#Reset the amount of jump possible if the player hit the ground
	if is_on_floor():
		jump_count = 0
	print(jump_count)
	
	if Input.is_action_just_pressed("jump"): #Jump System
		if is_on_floor() or jump_count < 2:
			jump_count += 1
			velocity.y = jump

#### LOGIC ####

func _update_parry(): #Change the parry mode with : Up / Mid / Down
	pass

func _attack():
	pass

func _update_animation():
	pass

#### REPONSES ####
