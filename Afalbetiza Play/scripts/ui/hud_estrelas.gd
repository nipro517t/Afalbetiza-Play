extends Control
## HUD de estrelas (canto superior ESQUERDO): uma estrela ao lado do
## número. Substitui o antigo "PONTOS: N". Montado todo por código —
## o MinigameBase faz add_child(HudEstrelas) sozinho, não precisa de cena.
##
## A estrela é desenhada por código (sem imagem), igual ao ícone de som.


class IconeEstrela extends Control:
	## false = estrela apagada (cinza), usada na tela de recompensa.
	var ativa: bool = true:
		set(v):
			ativa = v
			queue_redraw()

	func _draw() -> void:
		var centro := size * 0.5
		var raio_externo := minf(size.x, size.y) * 0.5
		var raio_interno := raio_externo * 0.42
		var pontos := PackedVector2Array()
		for i in 10:
			var angulo := -PI / 2.0 + i * PI / 5.0
			var raio := raio_externo if i % 2 == 0 else raio_interno
			pontos.append(centro + Vector2(cos(angulo), sin(angulo)) * raio)
		draw_colored_polygon(pontos, Color(1, 0.85, 0.2) if ativa else Color(0.4, 0.4, 0.4, 0.6))
		var contorno := pontos.duplicate()
		contorno.append(pontos[0])
		draw_polyline(contorno, Color(0.85, 0.5, 0.05) if ativa else Color(0.25, 0.25, 0.25, 0.8), 3.0, true)


var _label: Label


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var caixa := HBoxContainer.new()
	caixa.position = Vector2(20, 16)
	caixa.add_theme_constant_override("separation", 10)
	caixa.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(caixa)

	var icone := IconeEstrela.new()
	icone.custom_minimum_size = Vector2(56, 56)
	icone.mouse_filter = Control.MOUSE_FILTER_IGNORE
	caixa.add_child(icone)

	_label = Label.new()
	_label.add_theme_font_size_override("font_size", 44)
	_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	_label.add_theme_constant_override("outline_size", 8)
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	caixa.add_child(_label)

	definir(0)


func definir(valor: int) -> void:
	if _label:
		_label.text = str(valor)
