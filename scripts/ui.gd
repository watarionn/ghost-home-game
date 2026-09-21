extends CanvasLayer
const Balance = preload("res://data/balance.gd")
const DebugPanel = preload("res://scripts/debug_panel.gd")
var root: Control
var fear_label: Label
var timer_label: Label
var fear_gauge: ProgressBar
var pause_button: Button
var action_buttons: Dictionary = {}
var debug_panel: PanelContainer
var overlay: ColorRect
var overlay_title: Label
var overlay_message: Label
var resume_button: Button
var restart_button: Button


func setup(game: Node) -> void:
	root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	var theme := Theme.new()
	theme.default_font_size = 20
	# Use the OS Japanese font; no redistributed font or other external assets.
	var font := SystemFont.new()
	font.font_names = PackedStringArray(["Yu Gothic UI", "Meiryo", "Noto Sans CJK JP"])
	theme.default_font = font
	root.theme = theme
	# Room Labels share the same system font.
	for child in game.room.get_children():
		if child is Control: child.theme = theme
	make_label("GHOST HOME", Rect2(40, 14, 360, 40), 30)
	make_label("CORE PROTOTYPE v0.3", Rect2(330, 22, 360, 32), 17)
	fear_label = make_label("", Rect2(40, 66, 630, 38), 22)
	fear_gauge = ProgressBar.new()
	fear_gauge.position = Vector2(40, 111)
	fear_gauge.size = Vector2(700, 16)
	fear_gauge.max_value = Balance.WIN_FEAR
	fear_gauge.show_percentage = false
	var gauge_background := StyleBoxFlat.new()
	gauge_background.bg_color = Color("273440")
	gauge_background.set_corner_radius_all(6)
	fear_gauge.add_theme_stylebox_override("background", gauge_background)
	var gauge_fill := StyleBoxFlat.new()
	gauge_fill.bg_color = Color("e8b98a")
	gauge_fill.set_corner_radius_all(6)
	fear_gauge.add_theme_stylebox_override("fill", gauge_fill)
	root.add_child(fear_gauge)
	timer_label = make_label("", Rect2(780, 70, 250, 38), 25)
	pause_button = make_button("一時停止", Rect2(1080, 65, 160, 52), game.toggle_pause)
	make_label("住人を観察して、怪奇現象を仕掛けよう。", Rect2(40, 613, 750, 32), 19)
	if not OS.has_feature("stage2_playtest"):
		make_label("F1 : Debug", Rect2(1080, 613, 170, 32), 18)
	for i in Balance.ACTION_IDS.size():
		var id: String = Balance.ACTION_IDS[i]
		action_buttons[id] = make_button("", Rect2(40 + i * 406, 658, 388, 104), game.perform_action.bind(id))
	debug_panel = DebugPanel.new()
	root.add_child(debug_panel)
	overlay = ColorRect.new()
	overlay.color = Color("101722")
	overlay.position = Vector2(0, 54)
	overlay.size = Vector2(1280, 746)
	root.add_child(overlay)
	overlay_title = Label.new()
	overlay_title.position = Vector2(190, 160)
	overlay_title.size = Vector2(900, 95)
	overlay_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay_title.add_theme_font_size_override("font_size", 64)
	overlay.add_child(overlay_title)
	overlay_message = Label.new()
	overlay_message.position = Vector2(190, 280)
	overlay_message.size = Vector2(900, 110)
	overlay_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay_message.add_theme_font_size_override("font_size", 28)
	overlay.add_child(overlay_message)
	resume_button = Button.new()
	resume_button.text = "再開"
	resume_button.position = Vector2(485, 440)
	resume_button.size = Vector2(310, 66)
	resume_button.focus_mode = Control.FOCUS_NONE
	resume_button.pressed.connect(game.toggle_pause)
	overlay.add_child(resume_button)
	restart_button = Button.new()
	restart_button.text = "Restart / もう一度"
	restart_button.position = Vector2(485, 440)
	restart_button.size = Vector2(310, 66)
	restart_button.focus_mode = Control.FOCUS_NONE
	restart_button.pressed.connect(game.restart)
	overlay.add_child(restart_button)


func make_label(text: String, rect: Rect2, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.position = rect.position
	label.size = rect.size
	label.add_theme_font_size_override("font_size", font_size)
	root.add_child(label)
	return label


func make_button(text: String, rect: Rect2, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.position = rect.position
	button.size = rect.size
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(callback)
	root.add_child(button)
	return button


func update_view(game: Node) -> void:
	fear_label.text = "FEAR   %d / %d     %s" % [game.fear, Balance.WIN_FEAR, game.fear_stage()]
	fear_gauge.value = game.fear
	timer_label.text = "残り  %03d 秒" % ceili(game.time_remaining)
	for i in Balance.ACTION_IDS.size():
		var id: String = Balance.ACTION_IDS[i]
		var cd: float = game.actions.cooldown[id]
		var status := "発動可能" if cd <= 0 else "あと %.1f 秒" % cd
		action_buttons[id].text = "%d  %s / %s\n%s     慣れ %.1f / %d" % [
			i + 1, id, Balance.ACTIONS[id].label, status, game.actions.adaptation[id], Balance.ADAPTATION_MAX]
		action_buttons[id].disabled = cd > 0 or game.paused or not game.result.is_empty()
	pause_button.disabled = not game.result.is_empty()
	debug_panel.update_view(game)
	overlay.visible = game.paused or not game.result.is_empty()
	resume_button.visible = game.paused
	restart_button.visible = not game.result.is_empty()
	if game.paused:
		overlay_title.text = "PAUSED"
		overlay_message.text = "一時停止中"
	elif not game.result.is_empty():
		overlay_title.text = game.result
		var message := "こんな家住めるか！" if game.result == "WIN" else "なんだ、気のせいか"
		overlay_message.text = "%s\nFear %d / 100    プレイ時間 %.1f 秒" % [
			message, game.fear, Balance.GAME_TIME - game.time_remaining]
