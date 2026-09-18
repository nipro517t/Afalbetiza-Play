extends Control
## Tela de fim de minijogo: estrelas ganhas + "jogar de novo" / "voltar
## ao menu". Instanciada automaticamente pelo MinigameBase.concluir() —
## nenhum minijogo precisa criar essa tela na mão.

@onready var _estrelas: Array = [
	$Painel/Caixa/Estrelas/Estrela1,
	$Painel/Caixa/Estrelas/Estrela2,
	$Painel/Caixa/Estrelas/Estrela3,
]


func configurar(qtd_estrelas: int) -> void:
	get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in _estrelas.size():
		_estrelas[i].color = Color(1, 0.85, 0.2) if i < qtd_estrelas else Color(0.4, 0.4, 0.4, 0.5)


func _on_jogar_novamente_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_voltar_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/MenuPrincipal.tscn")
