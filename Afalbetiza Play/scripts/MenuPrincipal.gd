extends Control

@onready var titulo_jogo = $TituloJogo
@onready var card_central = $CardCentral
var indice_atual

var lista_jogos: Array = [
	{"nome": "A Pista das Letras", "cena": "res://scenes/jogos/APistaDasLetras.tscn", "imagem": preload("res://assets/disgner/WhatsApp Image 2026-07-09 at 02.04.43.jpeg")},
	{"nome": "Estourar Sílabas", "cena": "res://scenes/jogos/Estourador de Sílabas.tscn", "imagem": preload("res://assets/disgner/retouch_2026070922171390.png")},
	{"nome": "Forma Palavras", "cena": "res://scenes/jogos/Forma Palavras/formarpalavrasMenu.tscn", "imagem": preload("res://assets/disgner/retouch_2026072218415569.jpg")},
]

func _ready():
	get_tree().paused = false
	indice_atual = 0        # garante que começa no primeiro jogo
	atualizar_card()
	##func _ready():
	print("Viewport size: ", get_viewport_rect().size)
	print("Window size: ", DisplayServer.window_get_size())
	print("Screen size: ", DisplayServer.screen_get_size())
	$Label.text = str(get_viewport_rect().size) + " | " + str(DisplayServer.window_get_size())

func atualizar_card():
	var jogo = lista_jogos[indice_atual]
	titulo_jogo.text = jogo["nome"]
	card_central.texture_normal = jogo["imagem"]

func _on_botao_esquerda_pressed():
	if indice_atual > 0:
		indice_atual -= 1
	else:
		indice_atual = lista_jogos.size() - 1
	atualizar_card()

func _on_botao_direita_pressed():
	if indice_atual < lista_jogos.size() - 1:
		indice_atual += 1
	else:
		indice_atual = 0
	atualizar_card()

func _on_card_central_pressed():
	var cena = lista_jogos[indice_atual]["cena"]
	if ResourceLoader.exists(cena):
		get_tree().change_scene_to_file(cena)
	else:
		print("Cena não encontrada: ", cena)
