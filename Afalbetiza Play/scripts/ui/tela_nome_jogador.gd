extends Control
## Tela inicial: deixa a criança escolher um perfil já criado (aba
## "Perfil Existente") ou criar um perfil novo com nome + turma (aba
## "Novo Jogador") antes de abrir o menu. É essa tela que liga os
## pontos de cada minijogo a uma pessoa — sem isso, PerfilJogador não
## sabe pra quem salvar.
##
## Como o mesmo aparelho costuma ser usado por várias crianças, essa
## tela sempre aparece de novo ao abrir o app (ninguém fica "logado"
## sozinho pra sempre) e também é pra onde o botão "Trocar jogador" do
## menu principal volta. Nos dois casos, se já existir gente
## cadastrada, a aba "Perfil Existente" abre primeiro sozinha — não
## precisa redigitar nome/turma toda vez que troca de criança.
##
## A turma agora é sempre uma escolha do dropdown (PerfilJogador.
## TURMAS_DISPONIVEIS), nunca mais texto livre — mais fácil pra
## criança pequena e mantém o filtro do Ranking consistente.

@onready var _abas: TabContainer = $Painel/Abas
@onready var _lista_perfis: VBoxContainer = $Painel/Abas/PerfilExistente/Rolagem/ListaPerfis
@onready var _rolagem_perfis: ScrollContainer = $Painel/Abas/PerfilExistente/Rolagem
@onready var _label_sem_perfis: Label = $Painel/Abas/PerfilExistente/LabelSemPerfis
@onready var _campo_nome: LineEdit = $Painel/Abas/NovoJogador/CampoNome
@onready var _opcao_turma: OptionButton = $Painel/Abas/NovoJogador/OpcaoTurma
@onready var _label_erro: Label = $Painel/Abas/NovoJogador/LabelErro


func _ready() -> void:
	get_tree().paused = false
	_abas.set_tab_title(0, "Perfil Existente")
	_abas.set_tab_title(1, "Novo Jogador")
	_label_erro.visible = false
	_campo_nome.text = ""
	_preencher_opcoes_turma()
	_montar_lista_perfis()


func _preencher_opcoes_turma() -> void:
	_opcao_turma.clear()
	for turma in PerfilJogador.TURMAS_DISPONIVEIS:
		_opcao_turma.add_item(turma)
	if _opcao_turma.item_count > 0:
		_opcao_turma.select(0) # sempre tem algo selecionado — evita erro bobo de "esqueci de escolher"


## Monta a lista de botões de perfis já existentes na aba "Perfil
## Existente". Sem nenhum perfil salvo ainda (primeira vez do
## aparelho), mostra a mensagem de vazio e já abre direto na aba
## "Novo Jogador", já que não faz sentido abrir numa lista vazia.
func _montar_lista_perfis() -> void:
	for filho in _lista_perfis.get_children():
		filho.queue_free()

	var perfis: Array = PerfilJogador.obter_lista_perfis()
	_label_sem_perfis.visible = perfis.is_empty()
	_rolagem_perfis.visible = not perfis.is_empty()

	if perfis.is_empty():
		_abas.current_tab = 1
		return

	_abas.current_tab = 0
	for perfil in perfis:
		var botao := Button.new()
		botao.text = "%s — %s" % [perfil["nome"], perfil["turma"]]
		botao.custom_minimum_size = Vector2(0, 64)
		botao.add_theme_font_size_override("font_size", 28)
		botao.pressed.connect(_on_perfil_existente_selecionado.bind(perfil["nome"], perfil["turma"]))
		_lista_perfis.add_child(botao)


func _on_perfil_existente_selecionado(nome: String, turma: String) -> void:
	PerfilJogador.definir_jogador(nome, turma)
	get_tree().change_scene_to_file("res://scenes/MenuPrincipal.tscn")


func _on_campo_text_submitted(_texto: String) -> void:
	_tentar_comecar()


func _on_botao_comecar_pressed() -> void:
	_tentar_comecar()


func _tentar_comecar() -> void:
	var nome := _campo_nome.text.strip_edges()
	if nome.is_empty() or _opcao_turma.selected < 0:
		_label_erro.visible = true
		return
	var turma := _opcao_turma.get_item_text(_opcao_turma.selected)
	PerfilJogador.definir_jogador(nome, turma)
	get_tree().change_scene_to_file("res://scenes/MenuPrincipal.tscn")
