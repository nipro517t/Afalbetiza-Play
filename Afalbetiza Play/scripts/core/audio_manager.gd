extends Node
## Autoload "AudioManager".
##
## Ponto único por onde todo som do app passa. Nenhum minijogo cria
## AudioStreamPlayer por conta própria — chama uma das funções abaixo.
##
## Sons ligados:
## - música de fundo (assets/sons/som de fundo.ogg) — toca em loop desde
##   que o app abre, em todas as telas;
## - estouro de balão (assets/sons/estouroBalao/estouro_1..3.ogg) — um
##   dos três sorteado a cada balão tocado;
## - vitória (assets/sons/vitoria.ogg) — toca quando a criança VENCE o
##   minijogo (derrota fica em silêncio, de propósito).
##
## Locuções e sfx de acerto/erro ainda não têm arquivo: as funções
## existem (os minijogos já chamam), só não tocam nada por enquanto.
##
## Liga/desliga (botão de som no menu principal): UM único interruptor
## que liga ou desliga TODOS os sons (música + efeitos). A escolha fica
## salva em user://config_som.cfg e vale na próxima vez que o app abrir.
##
## Volumes: tudo em escala linear (1.0 = volume original do arquivo).
## Pra mexer no volume de algum som, é só trocar a constante abaixo.

## var (e não const) porque o loop é ligado por código em _ready().
var _musica_fundo: AudioStreamOggVorbis = preload("res://assets/sons/som de fundo.ogg")
const SOM_VITORIA := preload("res://assets/sons/vitoria.ogg")
const SONS_ESTOURO: Array[AudioStream] = [
	preload("res://assets/sons/estouroBalao/estouro_1.ogg"),
	preload("res://assets/sons/estouroBalao/estouro_2.ogg"),
	preload("res://assets/sons/estouroBalao/estouro_3.ogg"),
]

const VOLUME_MUSICA := 0.4
const VOLUME_ESTOURO := 1.0
## Vitória estava alta demais: 30% mais baixo (1.0 - 0.30 = 0.70).
const VOLUME_VITORIA := 0.7

## Quantos estouros podem soar ao mesmo tempo (balões estourados em
## sequência rápida não cortam um ao outro).
const VOZES_ESTOURO := 4

const ARQUIVO_CONFIG := "user://config_som.cfg"

## Lida pelo botão de som do menu; mude só via definir_som_ativo().
var som_ativo: bool = true

var _musica_player: AudioStreamPlayer
var _vitoria_player: AudioStreamPlayer
var _voz_player: AudioStreamPlayer
var _estouro_players: Array[AudioStreamPlayer] = []
var _proximo_estouro: int = 0
var _ultimo_estouro: int = -1


func _ready() -> void:
	# A tela de recompensa pausa a árvore; sem isso a música e o som
	# de vitória parariam junto com o jogo.
	process_mode = Node.PROCESS_MODE_ALWAYS

	_musica_player = _criar_player(VOLUME_MUSICA)
	_vitoria_player = _criar_player(VOLUME_VITORIA)
	_voz_player = _criar_player(1.0)
	for i in VOZES_ESTOURO:
		_estouro_players.append(_criar_player(VOLUME_ESTOURO))

	# O .import do arquivo vem com loop=false; liga o loop por código
	# pra música não ficar muda depois dos ~68 s.
	_musica_fundo.loop = true
	_musica_player.stream = _musica_fundo

	_carregar_config()
	_aplicar_musica()


## Liga/desliga TODOS os sons. Desligando, pausa a música (retoma de onde
## parou) e corta na hora qualquer efeito que esteja tocando.
func definir_som_ativo(ativo: bool) -> void:
	som_ativo = ativo
	_aplicar_musica()
	if not ativo:
		_vitoria_player.stop()
		_voz_player.stop()
		for player in _estouro_players:
			player.stop()
	_salvar_config()


func _aplicar_musica() -> void:
	if som_ativo:
		_musica_player.stream_paused = false
		if not _musica_player.playing:
			_musica_player.play()
	else:
		_musica_player.stream_paused = true


func _carregar_config() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(ARQUIVO_CONFIG) != OK:
		return
	som_ativo = bool(cfg.get_value("som", "ativo", true))


func _salvar_config() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("som", "ativo", som_ativo)
	cfg.save(ARQUIVO_CONFIG)


func _criar_player(volume_linear: float) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.volume_linear = volume_linear
	add_child(player)
	return player


## Estouro de balão — sorteia um dos 3 sons (nunca o mesmo duas vezes
## seguidas, pra não soar repetitivo).
func tocar_estouro() -> void:
	if not som_ativo:
		return
	var indice := randi() % SONS_ESTOURO.size()
	if indice == _ultimo_estouro:
		indice = (indice + 1) % SONS_ESTOURO.size()
	_ultimo_estouro = indice

	var player := _estouro_players[_proximo_estouro]
	_proximo_estouro = (_proximo_estouro + 1) % _estouro_players.size()
	player.stream = SONS_ESTOURO[indice]
	player.play()


## Som de vitória do minijogo (já com -30% de volume, ver VOLUME_VITORIA).
func tocar_vitoria() -> void:
	if not som_ativo:
		return
	_vitoria_player.stream = SOM_VITORIA
	_vitoria_player.play()


## Efeito sonoro de acerto. Ainda sem arquivo — o Estourador usa
## tocar_estouro() no lugar. Preencha quando tiver o som.
func tocar_sfx_acerto() -> void:
	pass


## Efeito sonoro de erro — sempre suave, nunca punitivo. Ainda sem arquivo.
func tocar_sfx_erro() -> void:
	pass


## Locução de voz. "id" identifica qual frase tocar (ex: instrução de
## um minijogo). Ainda sem gravações — quando existirem, troque por um
## dicionário id -> AudioStream e toque em _voz_player.
func tocar_locucao(_id: String) -> void:
	# Quando houver gravações: respeite som_ativo aqui também.
	pass
