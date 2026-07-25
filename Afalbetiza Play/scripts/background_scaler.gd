extends Node

func _ready():
	get_tree().node_added.connect(_on_node_added)

func _on_node_added(node):
	if node is Sprite2D and node.is_in_group("fundo_sprite"):
		call_deferred("_scale_to_cover", node)

func _scale_to_cover(sprite: Sprite2D):
	if sprite.texture == null:
		return
	var tex_size = sprite.texture.get_size()
	var vp_size = get_viewport().get_visible_rect().size
	var scale_factor = max(vp_size.x / tex_size.x, vp_size.y / tex_size.y)
	sprite.scale = Vector2(scale_factor, scale_factor)
	sprite.position = vp_size / 2
