extends Node2D

@onready var music_volume_label = $GridContainer/Audio/music_volume/Label
@onready var music_scrollbar = $GridContainer/Audio/music_volume/HScrollBar
@onready var sfx_volume_label = $GridContainer/Audio/sfx_volume/Label
@onready var sfx_scrollbar = $GridContainer/Audio/sfx_volume/HScrollBar
@onready var mute_button = $GridContainer/Audio/mute/CheckButton

func _ready() -> void:
	music_scrollbar.value = Settings.audio["music_volume"]
	sfx_scrollbar.value = Settings.audio["sfx_volume"]
	mute_button.set_pressed_no_signal(Settings.audio["mute"])

func _process(_delta: float) -> void:
	music_volume_label.text = str(int(Settings.audio["music_volume"])) + '%'
	sfx_volume_label.text = str(int(Settings.audio["sfx_volume"])) + '%'

func _on_back_button_pressed() -> void:
	Settings.save_settings()
	get_tree().change_scene_to_file(Path.GAME_STATES + "StartMenu.tscn")

func _on_mute_button_pressed() -> void:
	Settings.audio["mute"] = !Settings.audio["mute"]

func _on_music_value_changed(value: float) -> void:
	Settings.audio["music_volume"] = round(value)

func _on_sfx_value_changed(value: float) -> void:
	Settings.audio["sfx_volume"] = round(value)
	
