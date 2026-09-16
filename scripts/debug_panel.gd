extends PanelContainer
var label := Label.new()


func _ready() -> void:
	position = Vector2(820, 150)
	size = Vector2(420, 425)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.03, 0.05, 0.08, 0.97)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	add_theme_stylebox_override("panel", style)
	label.add_theme_font_size_override("font_size", 15)
	add_child(label)


func update_view(game: Node) -> void:
	visible = game.debug_visible and not game.paused
	# Keep the resident and nearby feedback readable while inspecting numbers.
	position.x = 40.0 if game.resident.position.x > 700.0 else 820.0
	var last: Dictionary = game.actions.last
	var lines: Array[String] = [
		"DEBUG  /  F1", "CurrentState: %s" % game.resident.state,
		"StateRemainingTime: %.2f" % game.resident.remaining,
		"Fear: %d" % game.fear,
		"EffectiveState: %s" % game.resident.effective_state(),
		"StateElapsedTime: %.2f" % game.resident.state_elapsed_time(),
		"CurrentOpportunityAction: %s" % game.resident.current_opportunity_action(),
		"IsOpportunityWindow: %s" % str(game.resident.current_opportunity_action() != "NONE"),
	]
	for id in game.Balance.ACTION_IDS:
		lines.append("%sAdaptation: %d" % [id.capitalize(), game.actions.adaptation[id]])
	for id in game.Balance.ACTION_IDS:
		lines.append("%sCooldown: %.2f" % [id.capitalize(), game.actions.cooldown[id]])
	lines.append("LastGhostAction: %s" % last.get("action", "—"))
	lines.append("LastBaseFear: %s" % str(last.get("base_fear", "—")))
	lines.append("LastStateMultiplier: %s" % str(last.get("state_multiplier", "—")))
	lines.append("LastAdaptationMultiplier: %s" % str(last.get("adaptation_multiplier", "—")))
	lines.append("LastFearGain: %s" % str(last.get("gain", "—")))
	lines.append("LastTimingMultiplier: %s" % str(last.get("timing_multiplier", "—")))
	label.text = "\n".join(lines)
