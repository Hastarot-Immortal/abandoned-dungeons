extends Node2D

func _ready() -> void:
	Settings.load_settings()

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_settings_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/settings_page.tscn")

func _on_new_game_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/new_game_page.tscn")
