extends Node

const SETTINGS_PATH = "user://settings.cfg"
var audio: Dictionary

func load_settings():
	var config = ConfigFile.new()
	var status = config.load(SETTINGS_PATH)
	
	if status == OK:
		audio = {
			'music_volume': config.get_value("Audio", "music_volume", 0.0),
			'sfx_volume': config.get_value("Audio", "sfx_volume", 0.0),
			'mute': config.get_value("Audio", "mute", false),
		}
	else:
		audio = {
			'music_volume': 0.0,
			'sfx_volume': 0.0,
			'mute': false,
		}

func save_settings():
	var config = ConfigFile.new()
	
	config.set_value("Audio", "music_volume", audio["music_volume"])
	config.set_value("Audio", "sfx_volume", audio["sfx_volume"])
	config.set_value("Audio", "mute", audio["mute"])
	
	config.save(SETTINGS_PATH)
