extends Node

signal brightness_updated(value)


func _ready():
	toggle_fullscreen(SaveSettings.settings_config.fullscreen_on)
	choose_language(SaveSettings.settings_config.language)
	update_master_vol(SaveSettings.settings_config.volume)

func toggle_fullscreen(mode):
	OS.window_fullscreen = mode
	SaveSettings.settings_config.fullscreen_on = mode
	SaveSettings.save_config()

func update_brightness(value):
	emit_signal("brightness_updated", value)
	SaveSettings.settings_config.brightness = value
	SaveSettings.save_config()


func update_master_vol(volume):
	AudioServer.set_bus_volume_db(0, volume)
	SaveSettings.settings_config.volume = volume
	SaveSettings.save_config()


func choose_language(index):
	if index == 0:
		TranslationServer.set_locale("en")
	if index == 1:
		TranslationServer.set_locale("fr")
	SaveSettings.settings_config.language = index
	SaveSettings.save_config()
