extends Node2D
const Balance = preload("res://data/balance.gd")
var current_action := ""
var effect_remaining := 0.0
var state_label: Label
var feedback_label: Label


func _ready() -> void:
	add_caption("TV", Vector2(125, 3), Vector2(180, 38))
	add_caption("水場", Vector2(515, 3), Vector2(180, 38))
	add_caption("ベッド", Vector2(880, 3), Vector2(180, 38))
	add_caption("通路", Vector2(440, 405), Vector2(260, 36))
	state_label = add_caption("", Vector2.ZERO, Vector2(260, 38))
	feedback_label = add_caption("", Vector2.ZERO, Vector2(430, 70))
	feedback_label.add_theme_color_override("font_color", Color("ffe4a0"))
	feedback_label.add_theme_color_override("font_shadow_color", Color("121a26"))
	feedback_label.add_theme_constant_override("shadow_offset_x", 2)
	feedback_label.add_theme_constant_override("shadow_offset_y", 2)


func add_caption(text: String, pos: Vector2, dimensions: Vector2) -> Label:
	var label := Label.new()
	label.text = text
	label.position = pos
	label.size = dimensions
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 20)
	add_child(label)
	return label


func update_view(game: Node) -> void:
	var resident = $Resident
	state_label.text = resident.LABELS[resident.state]
	if resident.state == "WATCH_TV" and resident.state_elapsed_time() < 0.8:
		state_label.text = "テレビをつけた"
	if resident.state == "SLEEP": state_label.text = "Z z z   " + state_label.text
	if resident.state == "SLEEP" and resident.state_elapsed_time() < 0.8:
		state_label.text = "ふぁ… うとうと"
	if resident.state == "SURPRISED": state_label.text = "!!   " + state_label.text
	state_label.position = resident.position + Vector2(-130, 45)
	feedback_label.text = game.feedback
	feedback_label.position = Vector2(
		clampf(resident.position.x - 215, 8, 762), maxf(5, resident.position.y - 115))
	feedback_label.visible = game.feedback_remaining > 0.0
	effect_remaining = game.feedback_remaining
	current_action = game.actions.last.get("action", "")
	queue_redraw()
	resident.queue_redraw()


func _draw() -> void:
	draw_style_box(room_style(), Rect2(0, 0, 1200, 450))
	for x in range(30, 1200, 60):
		draw_line(Vector2(x, 290), Vector2(x, 430), Color("344149"), 1)
	# A fixed doorway and runner identify the shadow corridor without a hint light.
	var zone := Balance.SHADOW_ZONE_X
	draw_rect(Rect2(zone.x, 285, zone.y - zone.x, 123), Color("46505a"))
	draw_line(Vector2(zone.x, 285), Vector2(zone.x, 405), Color("7e8790"), 6)
	draw_line(Vector2(zone.y, 285), Vector2(zone.y, 405), Color("7e8790"), 6)
	draw_line(Vector2(zone.x, 285), Vector2(zone.y, 285), Color("7e8790"), 6)
	draw_line(Vector2(zone.x + 8, 396), Vector2(zone.y - 8, 396), Color("a4a098"), 3)
	# TV and sofa: standard shapes only.
	draw_rect(Rect2(130, 25, 170, 88), Color("131b28"))
	draw_rect(Rect2(140, 35, 150, 64), Color("78b6c9"))
	draw_line(Vector2(170, 65), Vector2(260, 65), Color("bedde2"), 5)
	draw_rect(Rect2(175, 235, 100, 30), Color("657e8d"))
	# Sink and glass.
	draw_rect(Rect2(525, 32, 160, 80), Color("778f9f"))
	draw_rect(Rect2(540, 47, 90, 47), Color("314b5e"))
	draw_arc(Vector2(610, 45), 18, PI, TAU, 16, Color("cadce6"), 5)
	draw_rect(Rect2(650, 60, 15, 27), Color("9bcddd"))
	# Bed and pillow.
	draw_rect(Rect2(880, 20, 170, 95), Color("9c7996"))
	draw_rect(Rect2(889, 30, 45, 70), Color("dedbe7"))
	draw_rect(Rect2(942, 30, 97, 70), Color("b499b4"))
	if effect_remaining > 0.0:
		match current_action:
			"LIGHT": draw_rect(Rect2(0, 0, 1200, 450), Color(0.01, 0.02, 0.05, 0.48))
			"SOUND":
				for radius in [35.0, 55.0, 75.0]:
					draw_arc(Vector2(700, 310), radius, -1.0, 1.0, 28, Color("edd294"), 4)
			"SHADOW":
				draw_circle(Vector2(zone.y - 22, 302), 20, Color("101522"))
				draw_rect(Rect2(zone.y - 42, 307, 40, 60), Color("101522"))


func room_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("2b373f")
	style.border_color = Color("506170")
	style.set_border_width_all(3)
	style.set_corner_radius_all(14)
	return style
