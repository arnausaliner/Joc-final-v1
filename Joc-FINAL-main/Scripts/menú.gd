extends Node2D
@export var escena: PackedScene


func _on_button_pressed() -> void:
	get_tree().change_scene_to_packed(escena)


func _on_button_2_pressed() -> void:
	get_tree().quit()
