extends KinematicBody2D

enum STATE {
	Idle, Run, Attack, Parry, Jump, Dash
}
var State = STATE.Idle setget set_state, get_state

var dict_state = {
	0: "Idle", 
	1: "Run", 
	2: "Attack",
	3: "Parry",
	4: "Jump ",
	5: "Dash"
}

var direction = Vector2.ZERO
export var move_speed = 300
export var dmg = 100
onready var animated_sprite = $AnimatedSprite
onready var attack_box = $Attack/AttackBox

signal state_changed

#### ACCESSORS ####

func set_state(value):
	if State != value:
		State = value
	emit_signal("state_changed")

func get_state():
	return State

#### BUILT-IN ####

func _ready():
	pass

func _process(delta):
	var __ = move_and_slide(direction * move_speed)
	
	if Input.is_action_just_pressed("attack"):
		set_state(STATE.Attack)
	elif Input.is_action_just_pressed("dash"):
		pass #state for dash (Progress)
	elif Input.is_action_just_pressed("parry"):
		pass #state for parry (Progress)
	
	if get_state() != STATE.Attack and get_state() != STATE.Parry and get_state() != STATE.Jump:
		if direction.x != 0:
			set_state(STATE.Run)
		else : 
			set_state(STATE.Idle)
	_update_rotation()
	_update_anim_box()

func _input(event):
	direction.x = 0
	if get_state() != STATE.Dash:
		direction.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))

#### LOGIC ####

func _update_anim_box():
	if (get_state() == STATE.Attack):
		if (animated_sprite.frame >= 4 and animated_sprite.frame <= 6):
			attack_box.disabled = false
		else :
			attack_box.disabled = true
	elif (get_state() == STATE.Parry):
		pass

func _update_animation():
	animated_sprite.play(dict_state[get_state()])

func _update_rotation():
	if direction.x > 0:
		animated_sprite.flip_h = false
	elif direction.x < 0:
		animated_sprite.flip_h = true

#### SIGNAL RESPONSES ####

func on_state_changed():
	_update_animation()

func _on_animation_finished():
	if "Attack".is_subsequence_of(animated_sprite.get_animation()) or "Parry".is_subsequence_of(animated_sprite.get_animation()) or "Dash".is_subsequence_of(animated_sprite.get_animation()):
		if direction.x != 0:
			set_state(STATE.Idle)
		else : 
			set_state(STATE.Run)

func _on_Attack_body_entered(body):
	if body.has_method("boss_damaged"):
		body.boss_damaged(dmg)
	if body.has_method("pillar_damaged"):
		body.pillar_damaged(dmg)
