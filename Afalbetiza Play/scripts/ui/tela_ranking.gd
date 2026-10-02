extends Control
## Ranking de todas as crianças que já jogaram nesse aparelho, do
## maior pro menor total de pontos — com um filtro opcional por turma
## (dropdown "FiltroTurma") pra achar rápido só a turma que interessa.
## Os dados vêm do autoload PerfilJogador, que já persiste tudo em
## disco; essa tela só lê, filtra e mostra, não guarda nada por conta
## própria. A posição (1º, 2º...) é sempre relativa à lista que está
## sendo mostrada no momento — com filtro ligado, é a posição dentro
## da turma escolhida, não do ranking geral.

@onready var _lista: VBoxContainer = $Rolagem/ListaColocacoes
@onready var _label_vazio: Label = $LabelVazio
@onready var _rolagem: ScrollContainer = $Rolagem
@onready var _filtro_turma: OptionButton = $FiltroTurma

var _ranking_completo: Array = []


func _ready() -> void:
	get_tree().paused = false
	_ranking_completo = PerfilJogador.obter_ranking()
	_preencher_filtro()
	_montar_lista()


## "Todas as turmas" + uma opção por turma que já tem alguém no
## ranking, sem repetir e em ordem alfabética. Usa as turmas que
## aparecem de verdade nos dados (não a lista fixa de
## PerfilJogador.TURMAS_DISPONIVEIS) pra não mostrar turma sem
## ninguém dentro.
func _preencher_filtro() -> void:
	var turmas := {}
	for item in _ranking_completo:
		turmas[item["turma"]] = true
	var turmas_ordenadas := turmas.keys()
	turmas_ordenadas.sort()

	_filtro_turma.clear()
	_filtro_turma.add_item("Todas as turmas")
	for turma in turmas_ordenadas:
		_filtro_turma.add_item(turma)
	_filtro_turma.select(0)
	_filtro_turma.visible = not turmas_ordenadas.is_empty()


func _montar_lista() -> void:
	for filho in _lista.get_children():
		filho.queue_free()

	var ranking := _ranking_filtrado()
	_label_vazio.visible = ranking.is_empty()
	_rolagem.visible = not ranking.is_empty()
	if ranking.is_empty():
		_label_vazio.text = "Ninguém jogou ainda — o ranking aparece aqui depois da primeira partida." \
			if _ranking_completo.is_empty() else "Ninguém dessa turma jogou ainda."

	for i in ranking.size():
		var item: Dictionary = ranking[i]
		var linha := _criar_linha(i + 1, item["nome"], item["turma"], item["pontos_totais"])
		_lista.add_child(linha)


func _ranking_filtrado() -> Array:
	if _filtro_turma.selected <= 0:
		return _ranking_completo
	var turma_escolhida := _filtro_turma.get_item_text(_filtro_turma.selected)
	return _ranking_completo.filter(func(item): return item["turma"] == turma_escolhida)


func _on_filtro_turma_item_selected(_indice: int) -> void:
	_montar_lista()


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
