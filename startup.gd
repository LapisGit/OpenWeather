extends Node2D

func _ready():
	var file_path = "user://data.weather"
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	if file == null:
		get_tree().change_scene_to_file("res://setup.tscn")
	else:
		get_tree().change_scene_to_file("res://main.tscn")
