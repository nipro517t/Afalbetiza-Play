extends Control
## HUD de vidas (canto superior DIREITO): corações pixel art.
## Coração cheio = vida; coração vazio = vida perdida (errou, perdeu 1).
## Montado por código — o MinigameBase faz add_child(HudVidas) sozinho.
##
## Usa a spritesheet 32x32 (3 quadros lado a lado: cheio, metade, vazio).
## Aqui só usamos o quadro 0 (cheio) e o 2 (vazio).
## Arte: Nicole Marie T (pede crédito — ver README do pacote).

const SHEET: Texture2D = preload("res://assets/imagens/coracao_32.png")
const TAMANHO := 64

@export var total: int = 3

var _cheio := AtlasTexture.new()
var _vazio := AtlasTexture.new()
var _coracoes: Array[TextureRect] = []


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	_cheio.atlas = SHEET
	_cheio.region = Rect2(0, 0, 32, 32)
	_vazio.atlas = SHEET
	_vazio.region = Rect2(64, 0, 32, 32)

	var caixa := HBoxContainer.new()
	caixa.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	caixa.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	caixa.offset_right = -20.0
	caixa.offset_top = 12.0
	caixa.add_theme_constant_override("separation", 6)
	caixa.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(caixa)

	for i in total:
		var c := TextureRect.new()
		c.custom_minimum_size = Vector2(TAMANHO, TAMANHO)
		c.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		c.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		c.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST # pixel art nítida
		c.mouse_filter = Control.MOUSE_FILTER_IGNORE
		caixa.add_child(c)
		_coracoes.append(c)

	definir(total)


## restantes = quantas vidas ainda tem (0 a total).
func definir(restantes: int) -> void:
	for i in _coracoes.size():
		_coracoes[i].texture = _cheio if i < restantes else _vazio
