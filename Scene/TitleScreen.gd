extends CanvasLayer


func _on_PlayButton_pressed():
	get_tree().change_scene("res://Scene/World/Test_Scene.tscn")


func _on_QuitButton_pressed():
	get_tree().quit()
