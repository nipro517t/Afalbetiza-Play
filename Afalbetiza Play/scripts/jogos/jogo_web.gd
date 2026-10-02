extends Control
## "Minijogo" que na verdade abre no navegador do aparelho.
##
## Diferente dos outros minijogos, esta cena NÃO herda de MinigameBase
## — não faz sentido pausar a árvore ou mostrar TelaRecompensa (com
## estrelas) pra um jogo que roda fora do Godot, num navegador. O
## Godot não tem como saber o placar nem se a criança venceu ou não.
## É só uma tela de "ponte": explica o que vai acontecer e tem um botão
## que chama OS.shell_open(url), abrindo o link no navegador padrão.
##
## Pra adicionar outro jogo de navegador no futuro: duplique a cena
## (Ctrl+D numa das cenas que usam este script, ex. TratorInfantil.tscn)
## e troque só "URL do jogo" e "Título" no Inspector — não precisa
## escrever nenhum script novo.

@export var url: String = ""
@export var titulo: String = "Jogo"

@onready var _label_titulo: Label = $LabelTitulo


func _ready() -> void:
	get_tree().paused = false
	if _label_titulo:
		_label_titulo.text = titulo


func _on_botao_abrir_pressed() -> void:
	if url.is_empty():
		push_warning("JogoWeb: nenhuma URL configurada no Inspector desta cena.")
		return
	OS.shell_open(url)


func _on_botao_voltar_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/MenuPrincipal.tscn")
