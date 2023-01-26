extends KinematicBody2D

onready var LifeBar = $LifeBar

export var life : int = 10000
export var phase = 1

#### BUILT-IN ####

func _ready():
	LifeBar.max_value = life

func _process(delta):
	pass

#### LOGIC ####

func attack_up(dmg):
	pass

func get_damaged(dmg):
	if (life - dmg) <= 0:
		life = 0
	else : 
		life -= dmg
	LifeBar.value -= life
	if life == 0:
		queue_free()
