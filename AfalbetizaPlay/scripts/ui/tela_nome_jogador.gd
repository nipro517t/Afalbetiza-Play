extends Control
## Tela inicial: pede o nome e a turma/série da criança antes de abrir
## o menu. É essa tela que liga os pontos de cada minijogo a uma
## pessoa — sem ela, PerfilJogador não sabe pra quem salvar.
##
## Como o mesmo aparelho costuma ser usado por várias crianças, essa
## tela sempre aparece de novo ao abrir o app (ninguém fica "logado"
## sozinho pra sempre) e também dá pra voltar aqui a qualquer momento
## pelo botão "Trocar jogador" no menu principal.

@onready var _campo_nome: LineEdit = $Painel/Caixa/CampoNome
@onready var _campo_turma: LineEdit = $Painel/Caixa/CampoTurma
@onready var _label_erro: Label = $Painel/Caixa/LabelErro


func _ready() -> void:
	get_tree().paused = false
	_label_erro.visible = false
	_campo_nome.text = ""
	_campo_turma.text = ""
	_campo_nome.grab_focus()


func _on_campo_text_submitted(_texto: String) -> void:
	_tentar_comecar()


func _on_botao_comecar_pressed() -> void:
	_tentar_comecar()


func _tentar_comecar() -> void:
	var nome := _campo_nome.text.strip_edges()
	var turma := _campo_turma.text.strip_edges()
	if nome.is_empty() or turma.is_empty():
		_label_erro.visible = true
		return
	PerfilJogador.definir_jogador(nome, turma)
	get_tree().change_scene_to_file("res://scenes/MenuPrincipal.tscn")
