extends Control
## Tela de fim de minijogo: estrelas ganhas + "jogar de novo" / "voltar
## ao menu". Instanciada automaticamente pelo MinigameBase.concluir() —
## nenhum minijogo precisa criar essa tela na mão.

const HUD_ESTRELAS := preload("res://scripts/ui/hud_estrelas.gd")

const SHEET_CORACAO: Texture2D = preload("res://assets/imagens/coracao_32.png")

@onready var _titulo: Label = $Painel/Caixa/Titulo
@onready var _estrelas: Array = [
	$Painel/Caixa/Estrelas/Estrela1,
	$Painel/Caixa/Estrelas/Estrela2,
	$Painel/Caixa/Estrelas/Estrela3,
]


## venceu = false (acabaram as vidas): título "Não foi dessa vez!" e 3
## corações vazios no lugar das estrelas.
func configurar(qtd_estrelas: int, venceu: bool = true) -> void:
	get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	_titulo.text = "MUITO BEM!" if venceu else "NÃO FOI DESSA VEZ!"
	for i in _estrelas.size():
		# Os quadrados da cena ficam transparentes e viram estrelas desenhadas.
		var quadrado: ColorRect = _estrelas[i]
		quadrado.color = Color(0, 0, 0, 0)
		var icone: Control
		if venceu:
			var estrela := HUD_ESTRELAS.IconeEstrela.new()
			estrela.ativa = i < qtd_estrelas
			icone = estrela
		else:
			var coracao := TextureRect.new()
			var vazio := AtlasTexture.new()
			vazio.atlas = SHEET_CORACAO
			vazio.region = Rect2(64, 0, 32, 32)
			coracao.texture = vazio
			coracao.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			coracao.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			coracao.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			icone = coracao
		icone.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		icone.mouse_filter = Control.MOUSE_FILTER_IGNORE
		quadrado.add_child(icone)


func _on_jogar_novamente_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_voltar_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/MenuPrincipal.tscn")
