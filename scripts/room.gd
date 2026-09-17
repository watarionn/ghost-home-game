extends Node2D
const Balance = preload("res://data/balance.gd")
var current_action := ""
var effect_remaining := 0.0
var state_label: Label
var feedback_label: Label
var feedback_panel: PanelContainer
var feedback_gain_label: Label
var feedback_reason_label: Label
var feedback_kind := ""
var tv_startup_elapsed := -1.0


func _ready() -> void:
	add_caption("TV", Vector2(25, 45), Vector2(90, 38))
	add_caption("水場", Vector2(715, 45), Vector2(90, 38))
	add_caption("ベッド", Vector2(1060, 180), Vector2(90, 38))
	add_caption("通路", Vector2(440, 405), Vector2(260, 36))
	state_label = add_caption("", Vector2.ZERO, Vector2(260, 38))
	feedback_panel = PanelContainer.new()
	feedback_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	feedback_panel.custom_minimum_size = Vector2(460, 0)
	add_child(feedback_panel)
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", 2)
	feedback_panel.add_child(rows)
	feedback_label = Label.new()
	feedback_gain_label = Label.new()
	feedback_reason_label = Label.new()
	for label in [feedback_label, feedback_gain_label, feedback_reason_label]:
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rows.add_child(label)
	feedback_reason_label.add_theme_font_size_override("font_size", 18)


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
	feedback_kind = game.feedback_kind
	feedback_label.text = {"GOOD": "大成功！", "MISTIMED": "効いたが弱い…", "MISS": "気づかなかった…"}.get(feedback_kind, "")
	feedback_gain_label.text = "恐怖 +%d" % game.feedback_gain if feedback_kind != "MISS" else ""
	feedback_gain_label.visible = feedback_kind != "MISS"
	feedback_reason_label.text = game.feedback_reason
	feedback_label.add_theme_font_size_override("font_size", 32 if feedback_kind == "GOOD" else 23)
	feedback_gain_label.add_theme_font_size_override("font_size", 30 if feedback_kind == "GOOD" else 20)
	var color: Color = {"GOOD": Color("ffe29a"), "MISTIMED": Color("dec5a4"), "MISS": Color("b1c1d4")}.get(feedback_kind, Color.WHITE)
	feedback_label.add_theme_color_override("font_color", color)
	feedback_gain_label.add_theme_color_override("font_color", color)
	var box := StyleBoxFlat.new()
	box.bg_color = Color("121b28")
	box.border_color = color
	box.set_border_width_all(3 if feedback_kind == "GOOD" else 1)
	box.set_corner_radius_all(10)
	box.content_margin_top = 8
	box.content_margin_bottom = 8
	box.content_margin_left = 12
	box.content_margin_right = 12
	feedback_panel.add_theme_stylebox_override("panel", box)
	feedback_panel.size = Vector2(460, 0)
	feedback_panel.position = Vector2(
		clampf(resident.position.x - 230, 8, 732), maxf(4, resident.position.y - 185))
	feedback_panel.visible = game.feedback_remaining > 0.0
	effect_remaining = game.feedback_remaining
	current_action = game.actions.last.get("action", "")
	tv_startup_elapsed = resident.state_elapsed_time() if resident.state == "WATCH_TV" else -1.0
	queue_redraw()
	resident.queue_redraw()


func tv_brightness() -> float:
	if tv_startup_elapsed >= 0.0 and tv_startup_elapsed < Balance.TV_STARTUP_CUE_SECONDS:
		return 0.55 + 0.45 * (0.5 + 0.5 * sin(tv_startup_elapsed * 4.0 - PI / 2.0))
	return 0.55


func pulse_alpha() -> float:
	if feedback_kind != "GOOD" or effect_remaining <= 0.0:
		return 0.0
	var elapsed := Balance.FEEDBACK_TIME - effect_remaining
	return 0.12 * maxf(0.0, 1.0 - elapsed / Balance.GOOD_PULSE_SECONDS)


func _draw() -> void:
	draw_style_box(room_style(), Rect2(0, 0, 1200, 450))
	for x in range(30, 1200, 60):
		draw_line(Vector2(x, 290), Vector2(x, 430), Color("344149"), 1)
	# Architecture, not a colored gameplay-zone rectangle: open door, jamb, threshold.
	var zone := Balance.SHADOW_ZONE_X
	draw_rect(Rect2(zone.x - 14, 255, 168, 152), Color("171f29"))
	draw_line(Vector2(450, 262), Vector2(zone.x - 10, 262), Color("667078"), 12)
	draw_line(Vector2(zone.y + 10, 262), Vector2(710, 262), Color("667078"), 12)
	draw_rect(Rect2(zone.x - 14, 251, 14, 157), Color("907965"))
	draw_rect(Rect2(zone.y, 251, 14, 157), Color("907965"))
	draw_rect(Rect2(zone.x - 14, 246, 168, 13), Color("ab947b"))
	draw_colored_polygon(PackedVector2Array([Vector2(500, 258), Vector2(460, 280), Vector2(460, 420), Vector2(500, 400)]), Color("6a584c"))
	draw_circle(Vector2(470, 347), 4, Color("d0b88c"))
	draw_line(Vector2(zone.x, 406), Vector2(zone.y, 406), Color("978778"), 7)
	# TV and sofa: standard shapes only.
	draw_rect(Rect2(130, 25, 170, 88), Color("131b28"))
	draw_rect(Rect2(140, 35, 150, 64), Color("b0e8fa") * Color(tv_brightness(), tv_brightness(), tv_brightness(), 1))
	draw_line(Vector2(170, 65), Vector2(260, 65), Color("bedde2"), 5)
	draw_rect(Rect2(175, 235, 100, 30), Color("657e8d"))
	# Sink and glass.
	draw_rect(Rect2(525, 32, 160, 80), Color("778f9f"))
	draw_rect(Rect2(540, 47, 90, 47), Color("314b5e"))
	draw_arc(Vector2(610, 45), 18, PI, TAU, 16, Color("cadce6"), 5)
	draw_rect(Rect2(650, 60, 15, 27), Color("9bcddd"))
	# Bed and pillow.
	draw_rect(Rect2(880, 165, 180, 98), Color("9c7996"))
	draw_rect(Rect2(972, 175, 72, 70), Color("dedbe7"))
	draw_rect(Rect2(890, 175, 77, 70), Color("b499b4"))
	if effect_remaining > 0.0:
		match current_action:
			"LIGHT": draw_rect(Rect2(0, 0, 1200, 450), Color(0.01, 0.02, 0.05, 0.48))
			"SOUND":
				for radius in [35.0, 55.0, 75.0]:
					draw_arc(Vector2(700, 310), radius, -1.0, 1.0, 28, Color("edd294"), 4)
			"SHADOW":
				draw_circle(Vector2(zone.y - 22, 302), 20, Color("101522"))
				draw_rect(Rect2(zone.y - 42, 307, 40, 60), Color("101522"))
	if pulse_alpha() > 0.0:
		draw_rect(Rect2(0, 0, 1200, 450), Color(1.0, 0.86, 0.55, pulse_alpha()))


func room_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("2b373f")
	style.border_color = Color("506170")
	style.set_border_width_all(3)
	style.set_corner_radius_all(14)
	return style
