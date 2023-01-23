extends Node2D


func _ready():
	GlobalSettings.connect("brightness_updated", self, "_on_brightness_updated")


func _on_brightness_updated(value):
	$BrightnessControler.color = Color(0,0,0,1*value/100)
