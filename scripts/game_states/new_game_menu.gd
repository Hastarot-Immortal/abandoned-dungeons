extends Node2D

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file(Path.GAME_STATES + "StartMenu.tscn")
