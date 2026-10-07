extends Control
## Botão de som do menu principal (canto superior direito).
## Um toque liga ou desliga TODOS os sons (música + efeitos) — sem painel,
## sem escolher qual som. O estado real mora no autoload AudioManager e é
## salvo em disco por ele; este script só mostra e muda.
##
## Continua sendo usado como antes: add_child(PainelSons.new()) no menu.


class IconeSom extends Control:
	var mudo: bool = false

	func atualizar(novo_mudo: bool) -> void:
		mudo = novo_mudo
		queue_redraw()

	func _draw() -> void:
		var u: float = minf(size.x, size.y) / 100.0
		var c := Vector2(size.x * 0.5, size.y * 0.5)
		var branco := Color(1, 1, 1)
		draw_colored_polygon(PackedVector2Array([
			c + Vector2(-34, -13) * u,
			c + Vector2(-18, -13) * u,
			c + Vector2(2, -32) * u,
			c + Vector2(2, 32) * u,
			c + Vector2(-18, 13) * u,
			c + Vector2(-34, 13) * u,
		]), branco)
		if mudo:
			var vermelho := Color(1, 0.35, 0.35)
			draw_line(c + Vector2(12, -16) * u, c + Vector2(38, 16) * u, vermelho, 7.0 * u)
			draw_line(c + Vector2(12, 16) * u, c + Vector2(38, -16) * u, vermelho, 7.0 * u)
		else:
			draw_arc(c + Vector2(2, 0) * u, 20.0 * u, -0.8, 0.8, 16, branco, 6.0 * u, true)
			draw_arc(c + Vector2(2, 0) * u, 36.0 * u, -0.8, 0.8, 16, branco, 6.0 * u, true)



var _icone: IconeSom


func _ready() -> void:
	# Ocupa a tela toda mas não rouba toque de ninguém (só o botão pega toque).
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_montar_botao()
	_atualizar_icone()


func _montar_botao() -> void:
	var botao := Button.new()
	botao.custom_minimum_size = Vector2(80, 80)
	botao.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	botao.offset_left = -96.0
	botao.offset_right = -16.0
	botao.offset_top = 16.0
	botao.offset_bottom = 96.0
	botao.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	botao.pressed.connect(_on_botao_sons_pressed)
	add_child(botao)

	_icone = IconeSom.new()
	_icone.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_icone.mouse_filter = Control.MOUSE_FILTER_IGNORE
	botao.add_child(_icone)


func _atualizar_icone() -> void:
	_icone.atualizar(not AudioManager.som_ativo)


func _on_botao_sons_pressed() -> void:
	AudioManager.definir_som_ativo(not AudioManager.som_ativo)
	_atualizar_icone()
