extends KinematicBody2D

onready var HitBox = $CollisionShape2D
onready var Texture = $AnimatedSprite
onready var ParryP = $ParryPivot

var velocity = Vector2.ZERO

export var life = 100
export var speed = 1200
const move_speed = 1200
const max_speed = 2200
export var gravity = 4000
export var jump = -1800
export var jump_count = 0
var dmg;

var dash = false

enum State {
	Idle, 
	Walk, 
	Run,
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
	1 : "Mid",
	2 : "Down"
}

var state setget set_state, get_state
signal state_changed

var parry setget set_parry, get_parry
signal parry_changed

signal get_damaged

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
	$Attack/AttackBox.disabled = true
	set_state(State.Idle)
	set_parry(Parry.Mid)

func _get_input():
	#Movement System
	if Input.is_action_pressed("move_right"):
		velocity.x += speed
	if Input.is_action_pressed("move_left"):
		velocity.x -= speed
	#Parry System
	if Input.is_action_just_pressed("parry_up"):
		set_parry(Parry.Up)
	elif Input.is_action_just_pressed("parry_mid"):
		set_parry(Parry.Mid)
	elif Input.is_action_just_pressed("parry_down"):
		set_parry(Parry.Down)

func _process(delta):
	if Input.is_action_pressed("run"):
		speed = max_speed
	else :
		speed = move_speed
	
	#Set State system 
	if Input.is_action_pressed("attack"):
		$Attack/AttackBox.disabled = false
		yield(get_tree().create_timer(0.1), "timeout")
		$Attack/AttackBox.disabled = true
		set_state(State.Attack)
	elif Input.is_action_pressed("parry"):
		set_state(State.Parry)
	else : 
		if !is_on_floor():
			set_state(State.Jump)
		else:
			if velocity.y == 0:
				set_state(State.Idle)
			else:
				if velocity.x == max_speed:
					set_state(State.Run)
				else:
					set_state(State.Walk)
	#Flip the character Sprite and the Attack Box/Parry Box depend on the direction of the character
	if velocity.x < 0 : 
		Texture.flip_h = true
		$HeadPivot.rotation_degrees = 180
		$Attack.rotation_degrees = 180
		$Interaction.rotation_degrees = 180
		_update_parry(dict_parry[get_parry()])
	elif velocity.x > 0 : 
		Texture.flip_h = false
		$HeadPivot.rotation_degrees = 0
		$Attack.rotation_degrees = 0
		$Interaction.rotation_degrees = 0
		_update_parry(dict_parry[get_parry()])

func _physics_process(delta):
	velocity.x = 0 #reset the mouvement of the player for not let him infinite slide
	_get_input()
	
	velocity.y += gravity * delta
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
	#Reset the amount of jump possible if the player hit the ground
	if is_on_floor():
		jump_count = 0
	
	if Input.is_action_just_pressed("jump"): #Jump System
		if is_on_floor() or jump_count < 2:
			jump_count += 1
			velocity.y = jump

#### LOGIC ####

func _update_parry(x): #Change the parry mode with : Up / Mid / Down
	match(Texture.flip_h):
		false:
			match(x):
				"Up":
					ParryP.rotation_degrees = -45
				"Mid":
					ParryP.rotation_degrees = 0
				"Down":
					ParryP.rotation_degrees = 45
		true :
			match(x):
				"Up":
					ParryP.rotation_degrees = -135
				"Mid":
					ParryP.rotation_degrees = 180
				"Down":
					ParryP.rotation_degrees = 135

func _update_animation():
	pass 

func get_damaged(dmg):
	life -= dmg
	emit_signal("get_damaged")

#### REPONSES ####

func _on_parry_changed():
	_update_parry(dict_parry[get_parry()])

func _on_Attack_body_entered(body):
	if body.has_method("get_damaged"):
		body.get_damaged(1000)

func _on_state_changed():
	_update_animation()
