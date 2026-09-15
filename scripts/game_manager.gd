extends Node
const Balance = preload("res://data/balance.gd")
const ActionManager = preload("res://scripts/ghost_action_manager.gd")

@onready var room = $Room
@onready var resident = $Room/Resident
@onready var ui = $UI
var actions = ActionManager.new()
var fear := 0
var time_remaining := Balance.GAME_TIME
var paused := false
var result := ""
var feedback := ""
var feedback_remaining := 0.0
var debug_visible := false
var last_report := ""


func _ready() -> void:
	ui.setup(self)
	restart()


func restart() -> void:
	fear = 0
	time_remaining = Balance.GAME_TIME
	paused = false
	result = ""
	feedback = ""
	feedback_remaining = 0.0
	debug_visible = false
	last_report = ""
	actions.reset()
	resident.reset()
	refresh()


func _process(delta: float) -> void:
	advance(delta)


func advance(delta: float) -> void:
	if paused or not result.is_empty():
		return
	var step := minf(delta, time_remaining)
	time_remaining = maxf(0.0, time_remaining - step)
	resident.advance(step)
	actions.advance(step)
	feedback_remaining = maxf(0.0, feedback_remaining - step)
	if time_remaining <= 0.0:
		finish("LOSE")
	refresh()


func perform_action(id: String) -> void:
	if paused or not result.is_empty():
		return
	var effect: Dictionary = actions.execute(id, resident.state)
	if effect.is_empty():
		return
	fear = clampi(fear + effect.gain, 0, Balance.WIN_FEAR)
	resident.fear = fear
	if effect.missed:
		feedback = "気づかなかった…\n眠っていて見えない"
	else:
		feedback = "恐怖 +%d！" % effect.gain
		if effect.adaptation_before > 0:
			feedback += " 慣れてきた…"
		feedback += "\n%s ×%.1f / 慣れ ×%.2f" % [
			resident.LABELS[effect.state], effect.state_multiplier, effect.adaptation_multiplier]
		resident.react()
	feedback_remaining = Balance.FEEDBACK_TIME
	if fear >= Balance.WIN_FEAR:
		finish("WIN")
	refresh()


func toggle_pause() -> void:
	if not result.is_empty():
		return
	paused = not paused
	refresh()


func _input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.keycode == KEY_F1:
		debug_visible = not debug_visible
		refresh()
		get_viewport().set_input_as_handled()
		return
	var index := [KEY_1, KEY_2, KEY_3].find(event.keycode)
	if index >= 0:
		perform_action(Balance.ACTION_IDS[index])
		get_viewport().set_input_as_handled()


func finish(outcome: String) -> void:
	if not result.is_empty():
		return
	result = outcome
	var lines: Array[String] = [
		"RESULT=%s" % result,
		"PLAY_TIME=%.3f" % (Balance.GAME_TIME - time_remaining),
		"FINAL_FEAR=%d" % fear,
	]
	for id in Balance.ACTION_IDS:
		lines.append("%s_USE_COUNT=%d" % [id, actions.use_count[id]])
	for id in Balance.ACTION_IDS:
		lines.append("%s_MISS_COUNT=%d" % [id, actions.miss_count[id]])
	for id in Balance.ACTION_IDS:
		lines.append("%s_FINAL_ADAPTATION=%d" % [id, actions.adaptation[id]])
	lines.append("MAX_FEAR_GAIN=%d" % actions.max_gain)
	lines.append("AVERAGE_FEAR_GAIN=%.3f" % actions.average_gain())
	last_report = "\n".join(lines)
	print(last_report)


func fear_stage() -> String:
	if fear >= 100: return "限界"
	if fear >= 75: return "かなり怯えている"
	if fear >= 50: return "警戒"
	if fear >= 25: return "少し不安"
	return "平常"


func refresh() -> void:
	room.update_view(self)
	ui.update_view(self)
