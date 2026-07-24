extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	get_tree().paused = false
	queue_free()

func _on_button_2_pressed() -> void:
	get_tree().paused = false
	queue_free()

	var cena_atual = get_tree().current_scene
	var nome_cena_atual = cena_atual.scene_file_path

	if nome_cena_atual == "res://scenes/MenuPrincipal.tscn":
		get_tree().quit()
	else:
		get_tree().change_scene_to_file("res://scenes/MenuPrincipal.tscn")


func _on_button_3_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menuDev.tscn")
