extends Control

@onready var campo_nome = $LineEdit
var texto

func _physics_process(_delta: float) -> void:
	if texto == 67:
		$ButtonSecret.visible = true
	
func _ready():
	campo_nome.text_submitted.connect(_ao_confirmar_texto)
	$ButtonSecret.visible = false
	
func _ao_confirmar_texto(texto_digitado: String):
	Pause.definir(texto_digitado.to_int())
	texto = texto_digitado.to_int()

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/jogos/Forma Palavras/F.P.CARA.tscn")


func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MenuPrincipal.tscn")
	
	


func _on_button_secret_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/vnvnpa.tscn")
