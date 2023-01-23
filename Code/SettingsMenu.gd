extends CanvasLayer

signal game_paused()

onready var display_mode_select = $MarginContainer/GridContainer/DisplayModeSelector
onready var volume_slider = $MarginContainer/GridContainer/VolumeSliderContainer/VolumeSlider
onready var brightness_slider = $MarginContainer/GridContainer/BrightnessSliderContainer/BrightnessSlider
onready var language_select = $MarginContainer/GridContainer/LanguageSelector


func _ready():
	display_mode_select.select(SaveSettings.settings_config.fullscreen_on)
	GlobalSettings.toggle_fullscreen(SaveSettings.settings_config.fullscreen_on)
	volume_slider.set_value(SaveSettings.settings_config.volume)
	brightness_slider.set_value(SaveSettings.settings_config.brightness)
	get_tree().call_group("SettingsMenu", "hide")
	$SettingsButton.show()
	$KeyMapContainer.hide()

func _on_SettingsButton_pressed():
	get_tree().call_group("SettingsMenu", "show")
	$SettingsButton.hide()


func _on_CloseMenu_pressed():
	get_tree().call_group("SettingsMenu", "hide")
	$SettingsButton.show()
	$KeyMapContainer.hide()


#Options
func _on_DisplayModeSelector_item_selected(index):
	GlobalSettings.toggle_fullscreen(index)


func _on_VolumeSlider_value_changed(value):
	GlobalSettings.update_master_vol(value)


func _on_BrightnessSlider_value_changed(value):
	GlobalSettings.update_brightness(value)


func _on_LanguageSelector_item_selected(index):
	pass


func _on_KeyMappingBtn_pressed():
	$KeyMapContainer.show()

