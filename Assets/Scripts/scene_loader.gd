extends Node

@export_file(".tscn") var scene_path : String

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		load_level(scene_path)
		
		
func load_level(name: String):
	var scene: PackedScene = load(name) as PackedScene;
	get_tree().change_scene_to_packed(scene)
