class_name Balao
extends Control
## Bolha com sílaba usada no minijogo Estourador de Sílabas.
##
## Este script só cuida da aparência (cor sorteada, animação) e do
## toque — quem sobe a bolha e decide quando ela morre é o script do
## minijogo (estourador_silabas.gd), que chama configurar() ao
## instanciar e escuta o sinal tocada().
##
## IMPORTANTE: o balão NÃO decide mais se é "certo" ou "errado" — ele
## só guarda a sílaba que está escrita nele (obter_silaba()). Quem
## decide se aquilo é a resposta certa é sempre estourador_silabas.gd,
## comparando com a palavra que está valendo NO MOMENTO DO TOQUE. Isso
## corrige o bug de balão "certo por engano": antes, um balão guardava
## pra sempre se era certo ou errado com base na palavra que estava
## sendo jogada quando ele nasceu — se a palavra mudasse enquanto ele
## ainda estava subindo, ele continuava valendo ponto (ou não) pra uma
## palavra que já nem estava mais na tela.

## Emitido quando a criança toca na bolha. Só avisa QUAL balão foi
## tocado — a checagem de certo/errado é feita por quem escuta.
signal tocada(balao: Balao)

@onready var _sprite: AnimatedSprite2D = $balao

@onready var _botao: Button = $Button

var _silaba: String = ""

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


## Chamado pelo minijogo logo após instanciar a bolha. Só define qual
## sílaba aparece escrita nela — não guarda mais se é "a certa".
func configurar(silaba: String) -> void:
	_silaba = silaba
	_atualizar_texto()


## Pra quem escuta tocada() checar contra a palavra atual.
func obter_silaba() -> String:
	return _silaba


func _atualizar_texto() -> void:
	if _botao:
		_botao.text = _silaba


func _on_button_pressed() -> void:
	tocada.emit(self)
