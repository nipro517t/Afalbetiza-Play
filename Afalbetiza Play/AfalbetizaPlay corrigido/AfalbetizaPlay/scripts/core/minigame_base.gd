class_name MinigameBase
extends Control
## Base comum de todo minijogo do Afalbetiza Play.
##
## Em vez de cada minijogo repetir o mesmo código de pausar a árvore,
## mostrar a tela de recompensa e tocar som de acerto/erro, cada jogo faz
## "extends MinigameBase" (em vez de "extends Control") e só cuida da
## sua própria mecânica. Isso é o que evita a bagunça de antes: a lógica
## que É igual em todo jogo mora aqui, uma vez só.
##
## Contrato para um minijogo novo:
## - Sobrescreva _iniciar() para preparar a primeira rodada / tocar a
##   instrução de voz.
## - Chame registrar_acerto() / registrar_erro() conforme a criança joga.
## - Chame concluir(estrelas) quando o minijogo tiver acabado.
## - Se a cena tiver um botão "BotaoVoltar", conecte o sinal "pressed"
##   dele ao método _on_botao_voltar_pressed (já pronto aqui embaixo).

signal jogo_concluido(estrelas: int)

const TELA_RECOMPENSA := preload("res://scenes/ui/TelaRecompensa.tscn")

var estrelas: int = 3
var pontos: int = 0


func _ready() -> void:
	get_tree().paused = false
	_iniciar()


## Sobrescreva esta função no script do minijogo específico.
func _iniciar() -> void:
	pass


## Chame quando a criança acertar algo. Cuida do som — cada jogo decide
## sozinho se quer somar pontos, avançar de fase etc.
func registrar_acerto(pontos_ganhos: int = 10) -> void:
	pontos += pontos_ganhos
	AudioManager.tocar_sfx_acerto()


## Chame quando a criança errar algo. Nunca é "game over" por si só —
## cada jogo decide o que fazer com o erro (o GDD pede reforço positivo,
## nunca punição).
func registrar_erro() -> void:
	AudioManager.tocar_sfx_erro()


## Encerra o minijogo e mostra a tela padrão de recompensa.
## qtd_estrelas vai de 0 a 3.
func concluir(qtd_estrelas: int) -> void:
	estrelas = clamp(qtd_estrelas, 0, 3)
	jogo_concluido.emit(estrelas)
	var tela = TELA_RECOMPENSA.instantiate()
	add_child(tela)
	tela.configurar(estrelas)


## Botão "voltar ao menu" comum a todos os minijogos. Basta ter um
## Button chamado "BotaoVoltar" na cena e conectar o sinal "pressed"
## dele a este método — não precisa reescrever em cada jogo.
func _on_botao_voltar_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/MenuPrincipal.tscn")
