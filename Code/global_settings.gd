extends Node

signal brightness_updated(value)

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
