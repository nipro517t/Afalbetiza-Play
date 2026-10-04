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
##
## CORREÇÃO IMPORTANTE (balão "certo por engano"): o balão em si não
## sabe mais se é "a resposta certa" — ele só carrega a sílaba escrita
## nele (Balao.obter_silaba()). Certo/errado é decidido AQUI, no
## momento do toque, comparando a sílaba do balão com a palavra que
## está valendo agora (_item_atual()). Antes, essa decisão ficava
## gravada no balão desde que ele nascia; se a palavra mudasse enquanto
## ele ainda estava subindo, ele continuava valendo (ou não) ponto pra
## uma palavra que já nem estava mais na tela — esse era o bug.

const BALAO_CENA := preload("res://scenes/jogos/Balao.tscn")
const VELOCIDADE_SUBIDA := 120.0 # dobrado (era 60.0)

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

## Fica true assim que o jogo acaba (vitória ou derrota), pra ignorar
## qualquer toque tardio num balão que ainda esteja subindo/pendurado
## na hora em que a tela de recompensa aparece.
var _jogo_ativo: bool = true


func _iniciar() -> void:
	_gerar_ordem_sorteada()
	_indice_atual = 0
	_vidas_restantes = 3
	_jogo_ativo = true
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


## Sorteia qual sílaba esse balão vai mostrar (a certa ou uma das 3
## erradas do banco de palavras — todas ligadas à palavra que está
## valendo agora, no momento em que o balão nasce). Repare que o balão
## só recebe o TEXTO da sílaba (configurar(silaba)); ele não sabe se
## isso é "certo" ou "errado" — quem confere isso é _on_balao_tocada(),
## no momento do toque, contra a palavra que estiver valendo NAQUELE
## instante (que pode já ser outra, se esse balão demorou a ser tocado).
func _spawnar_balao() -> void:
	var item: Dictionary = _item_atual()
	var opcoes: Array = [item["correta"]] + item["erradas"]
	opcoes.shuffle()
	var silaba: String = opcoes[0]

	var balao = BALAO_CENA.instantiate()
	_area_baloes.add_child(balao)
	balao.configurar(silaba)
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


## Certo/errado é decidido AQUI, comparando a sílaba escrita no balão
## (balao.obter_silaba()) com a palavra que está valendo agora
## (_item_atual()["correta"]) — não com o que a palavra era quando o
## balão nasceu. Se, no momento do toque, o jogo já tiver acabado
## (_jogo_ativo == false), ignora — evita checar contra um índice que
## já passou do fim da lista sorteada.
func _on_balao_tocada(balao: Balao) -> void:
	if not _jogo_ativo:
		return

	AudioManager.tocar_estouro()
	var silaba_tocada := balao.obter_silaba()
	var eh_correta: bool = silaba_tocada == _item_atual()["correta"]

	_baloes_ativos.erase(balao)
	balao.queue_free()

	if eh_correta:
		registrar_acerto()
		_label_pontos.text = "PONTOS: %d" % pontos
		_indice_atual += 1
		if _indice_atual >= _ordem_indices.size():
			_finalizar_por_vitoria()
		else:
			_carregar_palavra()
	else:
		registrar_erro()
		_vidas_restantes -= 1
		_atualizar_vidas()
		if _vidas_restantes <= 0:
			_finalizar_por_derrota()


func _finalizar_por_vitoria() -> void:
	var estrelas_ganhas := 3 if _vidas_restantes == 3 else (2 if _vidas_restantes == 2 else 1)
	_encerrar_rodada()
	concluir(estrelas_ganhas)


func _finalizar_por_derrota() -> void:
	_encerrar_rodada()
	concluir(1, false)


## Comum aos dois finais: para de spawnar e tira da tela qualquer balão
## que ainda esteja subindo. Isso é o que garante que _jogo_ativo vira
## false ANTES de sobrar balão tocável por aí — sem isso, um balão
## sobrevivente podia ser tocado depois do jogo já ter acabado.
func _encerrar_rodada() -> void:
	_jogo_ativo = false
	_timer_spawn.stop()
	for balao in _baloes_ativos.duplicate():
		if is_instance_valid(balao):
			balao.queue_free()
	_baloes_ativos.clear()


func _atualizar_vidas() -> void:
	for i in _vidas.size():
		_vidas[i].color = Color(1, 0.85, 0.2) if i < _vidas_restantes else Color(0.3, 0.3, 0.3, 0.4)
