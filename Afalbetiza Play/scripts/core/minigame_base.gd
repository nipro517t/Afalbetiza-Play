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
## - Chame concluir(estrelas) quando o minijogo tiver acabado
##   (concluir(estrelas, false) se foi derrota — sem som de vitória).
## - Se a cena tiver um botão "BotaoVoltar", conecte o sinal "pressed"
##   dele ao método _on_botao_voltar_pressed (já pronto aqui embaixo).

signal jogo_concluido(estrelas: int)

const TELA_RECOMPENSA := preload("res://scenes/ui/TelaRecompensa.tscn")

const HUD_ESTRELAS := preload("res://scripts/ui/hud_estrelas.gd")
const HUD_VIDAS := preload("res://scripts/ui/hud_vidas.gd")

## Vidas com que todo minijogo começa (errou = perde 1).
const VIDAS_INICIAIS := 3

var estrelas: int = 3
var pontos: int = 0

var _hud_estrelas: Control
var _hud_vidas: Control


func _ready() -> void:
	get_tree().paused = false
	_criar_hud()
	_iniciar()


## HUD padrão de todo minijogo, montado por código: estrela + número no
## canto superior esquerdo e corações de vida no canto superior direito.
## Os jogos não criam nem mexem nisso direto — usam registrar_acerto()
## e atualizar_vidas_hud().
func _criar_hud() -> void:
	# Remove os quadrados antigos (vidas) e o "PONTOS: N" antigo, caso
	# ainda estejam na cena — assim não precisa apagar na mão.
	for nome in ["LabelPontos", "Vidas"]:
		var antigo := get_node_or_null(nome)
		if antigo:
			antigo.queue_free()
	_hud_estrelas = HUD_ESTRELAS.new()
	add_child(_hud_estrelas)
	_hud_vidas = HUD_VIDAS.new()
	_hud_vidas.total = VIDAS_INICIAIS
	add_child(_hud_vidas)


## Chame sempre que as vidas mudarem (início do jogo e a cada erro).
func atualizar_vidas_hud(restantes: int) -> void:
	if _hud_vidas:
		_hud_vidas.definir(restantes)


## Sobrescreva esta função no script do minijogo específico.
func _iniciar() -> void:
	pass


## Chame quando a criança acertar algo. Cuida do som — cada jogo decide
## sozinho se quer somar pontos, avançar de fase etc.
func registrar_acerto(pontos_ganhos: int = 10) -> void:
	pontos += pontos_ganhos
	_hud_estrelas.definir(pontos)
	AudioManager.tocar_sfx_acerto()


## Chame quando a criança errar algo. Nunca é "game over" por si só —
## cada jogo decide o que fazer com o erro (o GDD pede reforço positivo,
## nunca punição).
func registrar_erro() -> void:
	AudioManager.tocar_sfx_erro()


## Encerra o minijogo e mostra a tela padrão de recompensa.
## qtd_estrelas vai de 0 a 3. Também salva os pontos feitos nessa
## partida no perfil da criança atual (PerfilJogador) — cada minijogo
## não precisa fazer isso na mão, já sai pronto aqui.
## venceu = true toca o som de vitória; passe false na derrota (fim por
## falta de vidas) pra ficar em silêncio.
func concluir(qtd_estrelas: int, venceu: bool = true) -> void:
	estrelas = clamp(qtd_estrelas, 0, 3)
	if venceu:
		AudioManager.tocar_vitoria()
	jogo_concluido.emit(estrelas)
	PerfilJogador.adicionar_pontos(scene_file_path, pontos)
	var tela = TELA_RECOMPENSA.instantiate()
	add_child(tela)
	tela.configurar(estrelas, venceu)


## Botão "voltar ao menu" comum a todos os minijogos. Basta ter um
## Button chamado "BotaoVoltar" na cena e conectar o sinal "pressed"
## dele a este método — não precisa reescrever em cada jogo.
func _on_botao_voltar_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/MenuPrincipal.tscn")
