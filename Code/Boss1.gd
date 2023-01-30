extends KinematicBody2D

var prefabDrone = preload("res://Scene/Bosses/Drone.tscn")

onready var LifeBar = $LifeBar
onready var AnimationSprite = $AnimatedSprite

export var life : int = 10000
export var dmg = 45
export var LeftPillarRes = 3000
export var RightPillarRes = 3000
var armor = 0
var parry = 0

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
	Down
}

var dict_state = {
	0 : "Idle",
	1 : "Attack",
	2 : "Death" 
}

var dict_Dir = {
	0 : "Up",
	1 : "Down"
}

var state = State.Idle setget set_state, get_state
var rage = Rage.Off setget set_rage, get_rage
var dir = Dir.Up setget set_dir, get_dir

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
					parry = 0
					for i in range(3):
						attack(randi()%2)
					if parry == 3:
						yield(get_tree().create_timer(4), "timeout")
					else : 
						yield(get_tree().create_timer(2), "timeout")
				1:
					for i in range(6):
						parry = 0
						attack(randi()%2)
					if parry == 3:
						yield(get_tree().create_timer(4), "timeout")
					else : 
						yield(get_tree().create_timer(2), "timeout")
		1:
			yield(rage_seq(), "rage_finished")

func ennemy_parry():
	parry += 1
	_update_damage(true)

func update_armor():
	if get_rage():
		armor = 100
	else :
		armor = 0

#### LOGIC ####

func attack(direction):
	set_dir(direction)
	_update_damage(false)
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

func left_pillar_damaged(dmg):
	if LeftPillarRes <= 0:
		LeftPillarRes = 0
	else : 
		LeftPillarRes -= dmg
	if LeftPillarRes == 0:
		queue_free()

func Right_pillar_damaged(dmg):
	if RightPillarRes <= 0:
		RightPillarRes = 0
	else : 
		RightPillarRes -= dmg
	if RightPillarRes == 0:
		#rDrone.queue_free()
		queue_free()

func _update_animation():
	if get_state() == State.Attack:
		AnimationSprite.play(dict_state[get_state()]+dict_Dir[get_dir()])
	else :
		AnimationSprite.play(dict_state[get_state()])

func rage_seq():
	var rDrone = prefabDrone.instance()
	var lDrone = prefabDrone.instance()
	get_parent().add_child(lDrone)
	get_parent().add_child(rDrone)
	lDrone.global_position = $LeftPillar/Position2D.global_position
	rDrone.global_position = $RightPillar/Position2D.global_position
	while get_rage():
		if get_node("RightPillar") == null and get_node("LeftPillar") == null :
			set_rage(Rage.Off)
			emit_signal("rage_finished")
		else :
			parry = 0
			var att_num = randi()%7
			for i in range(att_num):
				var att = randi()%2
				attack(att)
				yield(AnimationSprite, "animation_finished")
			if parry == att_num:
				yield(get_tree().create_timer(5), "timeout")
			else : 
				yield(get_tree().create_timer(2), "timeout")
		if get_node("LeftPillar") == null:
			lDrone.queue_free()
		if get_node("RightPillar") == null:
			rDrone.queue_free()

func _update_damage(p):
	var d = 0
	if p:
		match(get_rage()):
			0:
				match(get_dir()):
					0:
						d = 150
					1:
						d = 100
			1:
				match(get_dir()):
					0:
						d = 200
					1:
						d = 150
	else :
		d = 0
	return d

#### RESPONSES ####

func _on_Boss1_rage_changed():
	update_armor()

func _on_Boss1_state_changed():
	_update_animation()

func _on_AttackArea_body_entered(body):
	if body.name == "Character":
		body.get_damaged(dmg)

func _on_AnimatedSprite_animation_finished():
	if "Attack".is_subsequence_of(AnimationSprite.name):
		set_state(State.Idle)
