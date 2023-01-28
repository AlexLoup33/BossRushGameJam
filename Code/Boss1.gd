extends KinematicBody2D

onready var LifeBar = $LifeBar
onready var AnimationSprite = $AnimatedSprite

export var life : int = 100000
export var phase = 1
export var dmg = 45
var armor = 0

enum State {
	Idle, 
	Attack,
	Death,
}

enum Rage {
	Off, 
	On
}

enum Dir{
	Up, 
	Mid, 
	Down
}

var dict_state = {
	0 : "Idle",
	1 : "Attack",
	2 : "Death" 
}

var dict_Dir = {
	0 : "Up",
	1 : "Mid",
	2 : "Down"
}

var state = State.Idle setget set_state, get_state
var rage = Rage.Off setget set_rage, get_rage
var dir = Dir.Mid setget set_dir, get_dir

signal state_changed
signal rage_changed
signal attack_seq_finished
signal rage_finished

#### ACCESSORS ####

func set_state(value):
	if state != value:
		state = value
	emit_signal("state_changed")

func get_state():
	return state

func set_rage(value):
	if rage != value:
		rage = value
	emit_signal("rage_changed")

func get_rage():
	return rage

func set_dir(value):
	if dir != value:
		dir = value

func get_dir():
	return dir

#### BUILT-IN ####

func _ready():
	LifeBar.max_value = life
	LifeBar.value = life

func _process(delta):
	$AttackArea/AttackBox.disabled = ("Attack".is_subsequence_of(AnimationSprite.animation) and AnimationSprite.frame == 1)
	
	var heavy = randi()%2 #randomize if the boss will use heavy attack sequences or not
	var seq = randi()%2 #Pick one of the attack sequence's boss
	match(get_rage()):
		0: 
			match(heavy):
				0:
					match(seq):
						0:
							for i in range(3):
								if i == 2:
									attack(Dir.Down)
						1:
							for i in range(3):
								attack(Dir.Up)
				1:
					for i in range(6):
						attack(Dir.Up)
		1:
			yield(rage_seq(), "rage_finished")

#### LOGIC ####

func attack(direction):
	set_dir(direction)
	set_state(State.Attack)
	yield(AnimationSprite, "animation_finished")

func get_damaged(dmg):
	if (life - (dmg - (armor*dmg)/100)) <= 0:
		life = 0
	else : 
		life -= (dmg - (armor*dmg)/100)
	LifeBar.value -= (dmg - (armor*dmg)/100)
	if life == 0:
		set_state(State.Death)
		yield(AnimationSprite, "animation_finished")
		queue_free()

func _update_animation():
	if get_state() == State.Attack:
		AnimationSprite.play(dict_state[get_state()]+dict_Dir[get_dir()])
	else :
		AnimationSprite.play(dict_state[get_state()])

func rage_seq():
	while get_rage():
		armor = 100

#### RESPONSES ####

func _on_Boss1_rage_changed():
	if get_rage():
		dmg = 65
	else:
		dmg = 45

func _on_Boss1_state_changed():
	_update_animation()

func _on_AttackArea_body_entered(body):
	if body.name == "Character":
		body.get_damaged(dmg)

func _on_AnimatedSprite_animation_finished():
	if "Attack".is_subsequence_of(AnimationSprite.name):
		set_state(State.Idle)
