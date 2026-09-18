extends Control
## Menu principal do Afalbetiza Play.
##
## Mostra um carrossel simples com um "card" central: cada jogo vira um
## card, com nome e imagem. As setas trocam de jogo e clicar no card
## carrega a cena daquele jogo.
##
## A lista de jogos não mora aqui — vem do autoload Catalogo (veja
## res://scripts/core/catalogo.gd), que é a fonte única de verdade sobre
## quais jogos existem. Pra adicionar um jogo novo, mexa só lá.

@onready var titulo_jogo: Label = $Carrossel/TituloJogo
@onready var card_central: TextureButton = $Carrossel/CardCentral
@onready var botao_esquerda: Button = $Carrossel/BotaoEsquerda
@onready var botao_direita: Button = $Carrossel/BotaoDireita

var indice_atual: int = 0

## Cada item: { "nome": String, "cena": String (res://...), "imagem": Texture2D }
var lista_jogos: Array = []


func _ready() -> void:
	get_tree().paused = false
	lista_jogos = Catalogo.jogos
	indice_atual = 0
	atualizar_card()


## Atualiza o texto e a imagem do card central de acordo com indice_atual.
## Sem jogos cadastrados, mostra um placeholder e desativa a navegação
## em vez de quebrar (evita erro de índice em lista vazia).
func atualizar_card() -> void:
	var tem_jogos := lista_jogos.size() > 0
	botao_esquerda.visible = tem_jogos
	botao_direita.visible = tem_jogos
	card_central.disabled = not tem_jogos

	if not tem_jogos:
		titulo_jogo.text = "Em breve"
		card_central.texture_normal = null
		return

	var jogo: Dictionary = lista_jogos[indice_atual]
	titulo_jogo.text = jogo["nome"]
	card_central.texture_normal = jogo["imagem"]


func _on_botao_esquerda_pressed() -> void:
	if lista_jogos.is_empty():
		return
	indice_atual = (indice_atual - 1 + lista_jogos.size()) % lista_jogos.size()
	atualizar_card()


func _on_botao_direita_pressed() -> void:
	if lista_jogos.is_empty():
		return
	indice_atual = (indice_atual + 1) % lista_jogos.size()
	atualizar_card()


func _on_card_central_pressed() -> void:
	if lista_jogos.is_empty():
		return
	var cena: String = lista_jogos[indice_atual]["cena"]
	if ResourceLoader.exists(cena):
		get_tree().change_scene_to_file(cena)
	else:
		print("Cena não encontrada: ", cena)
