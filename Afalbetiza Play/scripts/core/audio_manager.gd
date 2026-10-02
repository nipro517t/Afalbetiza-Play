extends Node
## Autoload "AudioManager".
##
## Ponto único por onde todo som do app passa. Por enquanto só avisa no
## console (Output) — quando os áudios finais estiverem prontos, é só
## trocar o miolo de cada função aqui por um AudioStreamPlayer tocando
## o arquivo de verdade. Nenhum minijogo precisa mudar.

var _sfx_player: AudioStreamPlayer
var _voz_player: AudioStreamPlayer


func _ready() -> void:
	_sfx_player = AudioStreamPlayer.new()
	_voz_player = AudioStreamPlayer.new()
	add_child(_sfx_player)
	add_child(_voz_player)


## Efeito sonoro de acerto (ex: pop, sino, palminhas).
func tocar_sfx_acerto() -> void:
	_avisar("sfx acerto")


## Efeito sonoro de erro — sempre suave, nunca punitivo.
func tocar_sfx_erro() -> void:
	_avisar("sfx erro")


## Locução de voz. "id" identifica qual frase tocar (ex: instrução de
## um minijogo específico) — troque por um dicionário id -> AudioStream
## quando as gravações estiverem prontas.
func tocar_locucao(id: String) -> void:
	_avisar("locução: " + id)


func _avisar(nome: String) -> void:
	# TODO: substituir por reprodução real de áudio.
	print("[AudioManager] tocaria som: ", nome)
