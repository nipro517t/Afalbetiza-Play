extends MinigameBase
## MIN-01 (versão base): Pista das Letras.
##
## A criança arrasta o carrinho pela pista até a marca de "FIM". Puxar
## pra trás não faz o carrinho recuar (ele só avança) — soltar antes de
## chegar ao fim faz ele voltar pro início suavemente, sem punição,
## incentivando a tentar de novo (como pede o GDD).
##
## Versão base: a pista é uma curva simples (formato de "tenda") feita
## por código — troque os pontos por outros mais parecidos com a letra
## de verdade quando a arte final estiver pronta.

@onready var _pista: Path2D = $Pista
@onready var _seguidor: PathFollow2D = $Pista/Seguidor
@onready var _carro: Button = $Pista/Seguidor/Carro
@onready var _instrucao: Label = $Instrucao

var _arrastando: bool = false
var _ultimo_x_mouse: float = 0.0


func _iniciar() -> void:
	var curva := Curve2D.new()
	curva.add_point(Vector2(60, 260))
	curva.add_point(Vector2(360, 40))
	curva.add_point(Vector2(660, 260))
	_pista.curve = curva
	_seguidor.progress_ratio = 0.0

	_instrucao.text = "ARRASTE O CARRINHO ATÉ O FIM!"
	AudioManager.tocar_locucao("pista_letras_intro")

	_carro.button_down.connect(_on_carro_button_down)
	_carro.button_up.connect(_on_carro_button_up)


func _on_carro_button_down() -> void:
	_arrastando = true
	_ultimo_x_mouse = get_viewport().get_mouse_position().x


func _on_carro_button_up() -> void:
	_arrastando = false
	if _seguidor.progress_ratio < 0.98:
		var tween := create_tween()
		tween.tween_property(_seguidor, "progress_ratio", 0.0, 0.3)


func _process(_delta: float) -> void:
	if not _arrastando:
		return
	var x_atual := get_viewport().get_mouse_position().x
	var dx := x_atual - _ultimo_x_mouse
	_ultimo_x_mouse = x_atual
	if dx > 0.0:
		_seguidor.progress_ratio = clamp(_seguidor.progress_ratio + dx / 600.0, 0.0, 1.0)
	if _seguidor.progress_ratio >= 1.0:
		_arrastando = false
		_chegou_ao_fim()


func _chegou_ao_fim() -> void:
	_instrucao.text = "ISSO AÍ!"
	registrar_acerto()
	concluir(3)
