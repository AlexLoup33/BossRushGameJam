extends Node

const SAVEFILE = "res://config.save"

var settings_config = {}


func _ready():
	load_config()


func load_config():
	var file = File.new()
	if not file.file_exists(SAVEFILE):
		settings_config = {
			"fullscreen_on" : 0,
			"volume" : 100,
			"brightness" : 50,
			"language" : 0,
		}
		save_config()
	file.open(SAVEFILE, file.READ)
	settings_config = file.get_var()
	file.close()


func save_config():
	var file = File.new()
	file.open(SAVEFILE, File.WRITE)
	file.store_var(settings_config)
	file.close()
