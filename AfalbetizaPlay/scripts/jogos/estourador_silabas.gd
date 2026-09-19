extends MinigameBase
## MIN-02 (versão base): Estourador de Sílabas.
##
## Bolhas com sílabas sobem pela tela; a criança toca na sílaba certa
## pra completar a palavra-alvo. Errar tira uma "vida"; ao perder as
## 3 vidas, o jogo vai direto pra tela de recompensa (com resultado
## de derrota). Vencer (completar todas as palavras) também leva pra
## tela de recompensa, com estrelas conforme as vidas restantes.
##
## As palavras são sorteadas aleatoriamente e sem repetição: o jogo
## passa por todas as palavras do banco antes de terminar a rodada.
##
## Imagens: preencha "Imagens Das Palavras" no Inspector (lista de
## Texture2D). O item na posição N da lista é a imagem da palavra na
## posição N de _banco_palavras (GATO=0, BOLA=1, FOCA=2...) — igual ao
## Construtor de Palavras. Slot vazio = sem imagem pra aquela palavra.

const BALAO_CENA := preload("res://scenes/jogos/Balao.tscn")
const VELOCIDADE_SUBIDA := 60.0

@export var imagens_das_palavras: Array[Texture2D] = []

@onready var _label_meta: Label = $LabelMeta
@onready var _imagem_palavra: TextureRect = $ImagemPalavra
@onready var _label_pontos: Label = $LabelPontos
@onready var _vidas: Array = [$Vidas/Vida1, $Vidas/Vida2, $Vidas/Vida3]
@onready var _area_baloes: Node2D = $AreaBaloes
@onready var _timer_spawn: Timer = $TimerSpawn

var _banco_palavras: Array = [
	{"palavra": "GATO", "prefixo": "__ TO", "correta": "GA", "erradas": ["LA", "DO", "MA"]},
	{"palavra": "BOLA", "prefixo": "__ LA", "correta": "BO", "erradas": ["FA", "TI", "DO"]},
	{"palavra": "FOCA", "prefixo": "__ CA", "correta": "FO", "erradas": ["MU", "RE", "FA"]},
	{"palavra": "AMOR", "prefixo": "__ MOR", "correta": "A", "erradas": ["MU", "RE", "TI"]},
	{"palavra": "PATO", "prefixo": "__ TO", "correta": "PA", "erradas": ["BE", "LU", "SO"]},
	{"palavra": "SAPO", "prefixo": "__ PO", "correta": "SA", "erradas": ["RI", "TO", "NU"]},
	{"palavra": "MALA", "prefixo": "__ LA", "correta": "MA", "erradas": ["BO", "VI", "DU"]},
	{"palavra": "VACA", "prefixo": "__ CA", "correta": "VA", "erradas": ["FO", "PI", "LE"]},
	{"palavra": "DEDO", "prefixo": "__ DO", "correta": "DE", "erradas": ["TA", "MO", "RU"]},
	{"palavra": "MESA", "prefixo": "__ SA", "correta": "ME", "erradas": ["LI", "CO", "PA"]},
	{"palavra": "FADA", "prefixo": "__ DA", "correta": "FA", "erradas": ["BO", "TU", "RI"]},
	{"palavra": "LUA", "prefixo": "__ A", "correta": "LU", "erradas": ["VI", "PE", "SO"]},
	{"palavra": "CASA", "prefixo": "__ SA", "correta": "CA", "erradas": ["ME", "TI", "BO"]},
	{"palavra": "PIPA", "prefixo": "__ PA", "correta": "PI", "erradas": ["LU", "RE", "TO"]},
	{"palavra": "RATO", "prefixo": "__ TO", "correta": "RA", "erradas": ["GA", "PA", "SU"]},
]

var _ordem_indices: Array = []
var _indice_atual: int = 0
var _vidas_restantes: int = 3
var _baloes_ativos: Array = []


func _iniciar() -> void:
	_gerar_ordem_sorteada()
	_indice_atual = 0
	_vidas_restantes = 3
	_atualizar_vidas()
	_label_pontos.text = "PONTOS: 0"
	_timer_spawn.timeout.connect(_spawnar_balao)
	_carregar_palavra()


func _gerar_ordem_sorteada() -> void:
	_ordem_indices.clear()
	for i in _banco_palavras.size():
		_ordem_indices.append(i)
	_ordem_indices.shuffle()


func _indice_banco_atual() -> int:
	return _ordem_indices[_indice_atual]


func _item_atual() -> Dictionary:
	return _banco_palavras[_indice_banco_atual()]


func _carregar_palavra() -> void:
	var item: Dictionary = _item_atual()
	_label_meta.text = item["prefixo"]
	_atualizar_imagem(_indice_banco_atual())
	AudioManager.tocar_locucao("estourar_silaba_" + item["palavra"])
	_timer_spawn.start()


## Mostra a imagem correspondente ao índice do banco de palavras (não ao
## índice sorteado). Sem imagem preenchida no Inspector pra esse índice,
## o TextureRect fica invisível em vez de mostrar um quadrado vazio.
func _atualizar_imagem(indice_banco: int) -> void:
	if not _imagem_palavra:
		return
	var textura: Texture2D = null
	if indice_banco >= 0 and indice_banco < imagens_das_palavras.size():
		textura = imagens_das_palavras[indice_banco]
	_imagem_palavra.texture = textura
	_imagem_palavra.visible = textura != null


func _spawnar_balao() -> void:
	var item: Dictionary = _item_atual()
	var opcoes: Array = [item["correta"]] + item["erradas"]
	opcoes.shuffle()
	var silaba: String = opcoes[0]
	var eh_correta: bool = silaba == item["correta"]

	var balao = BALAO_CENA.instantiate()
	_area_baloes.add_child(balao)
	balao.configurar(silaba, eh_correta)
	balao.position = Vector2(randf_range(80, 1080), 760)
	balao.tocada.connect(_on_balao_tocada)
	_baloes_ativos.append(balao)


func _process(delta: float) -> void:
	for balao in _baloes_ativos.duplicate():
		if not is_instance_valid(balao):
			_baloes_ativos.erase(balao)
			continue
		balao.position.y -= VELOCIDADE_SUBIDA * delta
		if balao.position.y < -100:
			balao.queue_free()
			_baloes_ativos.erase(balao)


func _on_balao_tocada(balao: Balao, correta: bool) -> void:
	_baloes_ativos.erase(balao)
	balao.queue_free()

	if correta:
		registrar_acerto()
		_label_pontos.text = "PONTOS: %d" % pontos
		_indice_atual += 1
		if _indice_atual >= _ordem_indices.size():
			_timer_spawn.stop()
			var estrelas_ganhas := 3 if _vidas_restantes == 3 else (2 if _vidas_restantes == 2 else 1)
			concluir(estrelas_ganhas)
		else:
			_carregar_palavra()
	else:
		registrar_erro()
		_vidas_restantes -= 1
		_atualizar_vidas()
		if _vidas_restantes <= 0:
			_finalizar_por_derrota()


func _finalizar_por_derrota() -> void:
	_timer_spawn.stop()
	for balao in _baloes_ativos.duplicate():
		if is_instance_valid(balao):
			balao.queue_free()
	_baloes_ativos.clear()
	concluir(1)


func _atualizar_vidas() -> void:
	for i in _vidas.size():
		_vidas[i].color = Color(1, 0.85, 0.2) if i < _vidas_restantes else Color(0.3, 0.3, 0.3, 0.4)
