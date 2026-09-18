extends MinigameBase
## MIN-03 (versão base): Construtor de Palavras.
##
## A criança toca nas sílabas embaralhadas na ordem certa pra formar a
## palavra-alvo. Errar a ordem só limpa os espaços de novo — sem
## punição, sem perder vida.
##
## Versão base: todas as palavras do banco têm 2 sílabas (2 espaços
## fixos). Pra aceitar palavras com mais sílabas, ajuste o número de
## Labels dentro de $Slots na cena.
##
## Sorteio: a cada rodada, _gerar_ordem_sorteada() embaralha os índices
## do banco inteiro (igual ao Estourador de Sílabas) e o jogo percorre
## essa ordem — passa por todas as palavras antes de repetir, nunca
## sequencial.
##
## Imagens: preencha "Imagens Das Palavras" no Inspector (aparece como
## uma lista de Texture2D). O item na posição N da lista é a imagem da
## palavra na posição N de _banco_palavras (GATO=0, BOLA=1, FOCA=2...).
## Se deixar um slot vazio, a imagem simplesmente não aparece pra
## aquela palavra.

@export var imagens_das_palavras: Array[Texture2D] = []

@onready var _label_objeto: Label = $LabelObjeto
@onready var _imagem_objeto: TextureRect = $ImagemObjeto
@onready var _slots_container: HBoxContainer = $Slots
@onready var _opcoes_container: HBoxContainer = $Opcoes

var _banco_palavras: Array = [
	{"palavra": "GATO", "silabas": ["GA", "TO"]},
	{"palavra": "BOLA", "silabas": ["BO", "LA"]},
	{"palavra": "FOCA", "silabas": ["FO", "CA"]},
	{"palavra": "AMOR", "silabas": ["A", "MOR"]},
	{"palavra": "PATO", "silabas": ["PA", "TO"]},
	{"palavra": "SAPO", "silabas": ["SA", "PO"]},
	{"palavra": "MALA", "silabas": ["MA", "LA"]},
	{"palavra": "VACA", "silabas": ["VA", "CA"]},
	{"palavra": "DEDO", "silabas": ["DE", "DO"]},
	{"palavra": "MESA", "silabas": ["ME", "SA"]},
	{"palavra": "FADA", "silabas": ["FA", "DA"]},
	{"palavra": "LUA", "silabas": ["LU", "A"]},
	{"palavra": "CASA", "silabas": ["CA", "SA"]},
	{"palavra": "PIPA", "silabas": ["PI", "PA"]},
	{"palavra": "RATO", "silabas": ["RA", "TO"]},
]

var _ordem_indices: Array = []
var _indice_atual: int = 0
var _resposta_atual: Array = []


func _iniciar() -> void:
	_gerar_ordem_sorteada()
	_indice_atual = 0
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
	_resposta_atual.clear()
	var item: Dictionary = _item_atual()
	_label_objeto.text = item["palavra"]
	_atualizar_imagem(_indice_banco_atual())
	AudioManager.tocar_locucao("construir_palavra_" + item["palavra"])

	for slot in _slots_container.get_children():
		slot.text = "_"

	for botao in _opcoes_container.get_children():
		botao.queue_free()

	var silabas: Array = item["silabas"].duplicate()
	silabas.shuffle()
	for silaba in silabas:
		var botao := Button.new()
		botao.text = silaba
		botao.custom_minimum_size = Vector2(120, 120)
		botao.pressed.connect(_on_silaba_pressed.bind(botao, silaba))
		_opcoes_container.add_child(botao)


func _on_silaba_pressed(botao: Button, silaba: String) -> void:
	if _resposta_atual.size() >= _slots_container.get_child_count():
		return
	_resposta_atual.append(silaba)
	_slots_container.get_child(_resposta_atual.size() -1).text = silaba
	botao.disabled = true

	if _resposta_atual.size() == _slots_container.get_child_count():
		_conferir_resposta()


func _conferir_resposta() -> void:
	var item: Dictionary = _item_atual()
	var formada: String = "".join(_resposta_atual)
	if formada == item["palavra"]:
		registrar_acerto()
		_indice_atual += 1
		if _indice_atual >= _ordem_indices.size():
			concluir(3)
		else:
			await get_tree().create_timer(0.6).timeout
			_carregar_palavra()
	else:
		registrar_erro()
		await get_tree().create_timer(0.6).timeout
		_carregar_palavra()


## Mostra a imagem correspondente ao índice do banco de palavras (não ao
## índice sorteado). Se não houver imagem preenchida pra esse índice no
## Inspector, o TextureRect fica invisível em vez de mostrar um quadrado
## vazio.
func _atualizar_imagem(indice_banco: int) -> void:
	if not _imagem_objeto:
		return
	var textura: Texture2D = null
	if indice_banco >= 0 and indice_banco < imagens_das_palavras.size():
		textura = imagens_das_palavras[indice_banco]
	_imagem_objeto.texture = textura
	_imagem_objeto.visible = textura != null
