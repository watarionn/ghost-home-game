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
var feedback_kind := ""
var feedback_reason := ""
var feedback_gain := 0


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
	feedback_kind = ""
	feedback_reason = ""
	feedback_gain = 0
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
	var effect: Dictionary = actions.execute(id, resident)
	if effect.is_empty():
		return
	fear = clampi(fear + effect.gain, 0, Balance.WIN_FEAR)
	resident.fear = fear
	feedback_gain = effect.gain
	feedback_kind = "MISS" if effect.missed else ("GOOD" if effect.opportunity else "MISTIMED")
	feedback_reason = outcome_reason(effect)
	if effect.missed:
		feedback = "気づかなかった…"
	else:
		feedback = "大成功！" if effect.opportunity else "効いたが弱い…"
		feedback += "\n恐怖 +%d" % effect.gain
		if effect.adaptation_before > 0:
			feedback_reason += "\n慣れてきた…"
		resident.react(effect.opportunity)
	feedback += "\n" + feedback_reason
	feedback_remaining = Balance.FEEDBACK_TIME
	if fear >= Balance.WIN_FEAR:
		finish("WIN")
	refresh()


func outcome_reason(effect: Dictionary) -> String:
	if effect.missed:
		return "眠っていて人影が見えない" if effect.action == "SHADOW" else "眠っていて暗さに気づかない"
	if effect.opportunity:
		return {"LIGHT": "テレビをつけた直後だった！", "SOUND": "寝入りばなに音が響いた！", "SHADOW": "通路を横切った瞬間に見えた！"}[effect.action]
	if effect.current_state in ["SURPRISED", "ALERT"]:
		return "まだ驚きへの反応が続いている…"
	match effect.action:
		"LIGHT": return "テレビに慣れて落ち着いている…" if effect.state == "WATCH_TV" else "テレビをつけた直後ではなかった"
		"SOUND": return "眠りが安定している…" if effect.state == "SLEEP" else "寝入りばなではなかった"
		_: return "人影を見せる位置が悪かった…"


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
		lines.append("%s_FINAL_ADAPTATION=%.3f" % [id, actions.adaptation[id]])
	lines.append("MAX_FEAR_GAIN=%d" % actions.max_gain)
	lines.append("AVERAGE_FEAR_GAIN=%.3f" % actions.average_gain())
	lines.append("OPPORTUNITY_SUCCESS_COUNT=%d" % actions.opportunity_count)
	lines.append("MISTIMED_ACTION_COUNT=%d" % actions.mistimed_count)
	for id in Balance.ACTION_IDS:
		lines.append("%s_RECOVERED_TOTAL=%.3f" % [id, actions.recovered_total[id]])
	lines.append("MAX_SAME_ACTIVITY_STREAK=%d" % resident.max_same_activity_streak)
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
