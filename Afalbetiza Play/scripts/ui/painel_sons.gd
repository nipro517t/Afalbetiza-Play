extends Control
## Botão de sons do menu principal (canto superior direito) + painel
## com os dois interruptores: "Som de fundo" e "Efeitos sonoros".
##
## Tudo é montado por código aqui dentro, então o menu só precisa fazer
## add_child(PainelSons.new()) — veja MenuPrincipal.gd. O estado real
## (ligado/desligado) mora no autoload AudioManager e é salvo em disco
## por ele; este script só mostra e muda.


## Ícone de alto-falante desenhado por código (não depende de fonte
## nem de imagem). Com tudo desligado, troca as ondinhas por um "X".
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
var _painel: Control
var _check_fundo: CheckButton
var _check_efeitos: CheckButton


func _ready() -> void:
	# Ocupa a tela toda mas não rouba toque de ninguém (só os filhos
	# interativos pegam toque).
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_montar_botao()
	_montar_painel()
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


func _montar_painel() -> void:
	# Fundo escuro que cobre o menu e bloqueia toque no que está atrás.
	_painel = ColorRect.new()
	_painel.color = Color(0, 0, 0, 0.6)
	_painel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_painel.mouse_filter = Control.MOUSE_FILTER_STOP
	_painel.visible = false
	add_child(_painel)

	var centro := CenterContainer.new()
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_painel.add_child(centro)

	var caixa := PanelContainer.new()
	caixa.custom_minimum_size = Vector2(560, 0)
	centro.add_child(caixa)

	var margem := MarginContainer.new()
	for lado in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		margem.add_theme_constant_override(lado, 28)
	caixa.add_child(margem)

	var coluna := VBoxContainer.new()
	coluna.add_theme_constant_override("separation", 18)
	margem.add_child(coluna)

	var titulo := Label.new()
	titulo.text = "SONS"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_font_size_override("font_size", 44)
	coluna.add_child(titulo)

	_check_fundo = _criar_interruptor("Som de fundo", AudioManager.musica_ativa)
	_check_fundo.toggled.connect(_on_fundo_toggled)
	coluna.add_child(_check_fundo)

	_check_efeitos = _criar_interruptor("Efeitos sonoros", AudioManager.efeitos_ativos)
	_check_efeitos.toggled.connect(_on_efeitos_toggled)
	coluna.add_child(_check_efeitos)

	var fechar := Button.new()
	fechar.text = "FECHAR"
	fechar.custom_minimum_size = Vector2(0, 56)
	fechar.add_theme_font_size_override("font_size", 28)
	fechar.pressed.connect(_on_fechar_pressed)
	coluna.add_child(fechar)


## Importante: button_pressed é definido ANTES de conectar o sinal
## toggled, pra abrir o painel não disparar uma troca sem querer.
func _criar_interruptor(texto: String, ligado: bool) -> CheckButton:
	var check := CheckButton.new()
	check.text = texto
	check.button_pressed = ligado
	check.custom_minimum_size = Vector2(0, 64)
	check.add_theme_font_size_override("font_size", 32)
	return check


func _atualizar_icone() -> void:
	_icone.atualizar(not AudioManager.musica_ativa and not AudioManager.efeitos_ativos)


func _on_botao_sons_pressed() -> void:
	_check_fundo.set_pressed_no_signal(AudioManager.musica_ativa)
	_check_efeitos.set_pressed_no_signal(AudioManager.efeitos_ativos)
	_painel.visible = true


func _on_fundo_toggled(ligado: bool) -> void:
	AudioManager.definir_musica_ativa(ligado)
	_atualizar_icone()


func _on_efeitos_toggled(ligados: bool) -> void:
	AudioManager.definir_efeitos_ativos(ligados)
	_atualizar_icone()


func _on_fechar_pressed() -> void:
	_painel.visible = false
