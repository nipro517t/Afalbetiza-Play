extends Node

@export var escala_minima: Vector2 = Vector2(1.0, 1.0)
@export var escala_maxima: Vector2 = Vector2(1.1, 1.1)
@export var velocidade: float = 2.5

var pai: Control
var tempo: float = 0.0


func _ready() -> void:
	pai = get_parent() as Control


func _process(delta: float) -> void:
	if pai == null:
		return

	tempo += delta * velocidade

	var t: float = (sin(tempo) + 0.08) / 2.0

	pai.scale = escala_minima.lerp(escala_maxima, t)
