extends Control
## Ranking de todas as crianças que já jogaram nesse aparelho, do
## maior pro menor total de pontos. Os dados vêm do autoload
## PerfilJogador, que já persiste tudo em disco — essa tela só lê e
## mostra, não guarda nada por conta própria.

@onready var _lista: VBoxContainer = $Rolagem/ListaColocacoes
@onready var _label_vazio: Label = $LabelVazio
@onready var _rolagem: ScrollContainer = $Rolagem


func _ready() -> void:
	get_tree().paused = false
	_montar_lista()


func _montar_lista() -> void:
	for filho in _lista.get_children():
		filho.queue_free()

	var ranking: Array = PerfilJogador.obter_ranking()
	_label_vazio.visible = ranking.is_empty()
	_rolagem.visible = not ranking.is_empty()

	for i in ranking.size():
		var item: Dictionary = ranking[i]
		var linha := _criar_linha(i + 1, item["nome"], item["turma"], item["pontos_totais"])
		_lista.add_child(linha)


func _criar_linha(posicao: int, nome: String, turma: String, pontos: int) -> Control:
	var linha := HBoxContainer.new()
	linha.add_theme_constant_override("separation", 16)

	var label_posicao := Label.new()
	label_posicao.text = "%dº" % posicao
	label_posicao.custom_minimum_size = Vector2(50, 0)
	linha.add_child(label_posicao)

	var label_nome := Label.new()
	label_nome.text = nome
	label_nome.custom_minimum_size = Vector2(220, 0)
	label_nome.clip_text = true
	linha.add_child(label_nome)

	var label_turma := Label.new()
	label_turma.text = turma
	label_turma.custom_minimum_size = Vector2(140, 0)
	label_turma.clip_text = true
	linha.add_child(label_turma)

	var label_pontos := Label.new()
	label_pontos.text = "%d pts" % pontos
	label_pontos.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	label_pontos.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	linha.add_child(label_pontos)

	return linha


func _on_botao_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MenuPrincipal.tscn")
