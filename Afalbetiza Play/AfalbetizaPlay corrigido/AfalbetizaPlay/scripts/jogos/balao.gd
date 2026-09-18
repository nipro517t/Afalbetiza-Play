class_name Balao
extends Control
## Bolha com sílaba usada no minijogo Estourador de Sílabas.
##
## Este script só cuida da aparência (cor sorteada, animação) e do
## toque — quem sobe a bolha e decide quando ela morre é o script do
## minijogo (estourador_silabas.gd), que chama configurar() ao
## instanciar e escuta o sinal tocada().

## Emitido quando a criança toca na bolha. `eh_correta` diz se essa
## sílaba era a certa pra completar a palavra-alvo.
signal tocada(balao: Balao, eh_correta: bool)

@onready var _sprite: AnimatedSprite2D = $balao

@onready var _botao: Button = $Button

var _silaba: String = ""
var _eh_correta: bool = false

var _cores_disponiveis: Array = [
	Color(1, 1, 1),        # cor original (sem tingir)
	Color(1, 0.4, 0.4),    # vermelho
	Color(0.4, 0.6, 1),    # azul
	Color(0.4, 1, 0.5),    # verde
	Color(1, 0.9, 0.3),    # amarelo
]


func _ready() -> void:
	_sprite.modulate = _cores_disponiveis[randi() % _cores_disponiveis.size()]
	_sprite.play("default")
	if not _botao.pressed.is_connected(_on_button_pressed):
		_botao.pressed.connect(_on_button_pressed)
	_atualizar_texto()


## Chamado pelo minijogo logo após instanciar a bolha.
func configurar(silaba: String, eh_correta: bool) -> void:
	_silaba = silaba
	_eh_correta = eh_correta
	_atualizar_texto()


func _atualizar_texto() -> void:
	if _botao:
		_botao.text = _silaba


func _on_button_pressed() -> void:
	tocada.emit(self, _eh_correta)
