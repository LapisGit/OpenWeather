extends Node

func changescene(pathtoscene: String):
	Fade.fade_out(0.5)
	await Fade.fade_out().finished
	get_tree().change_scene_to_file(pathtoscene)
	Fade.fade_in(0.5)
