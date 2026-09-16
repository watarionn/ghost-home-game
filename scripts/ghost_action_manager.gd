extends RefCounted
const Balance = preload("res://data/balance.gd")

var adaptation: Dictionary = {}
var cooldown: Dictionary = {}
var use_count: Dictionary = {}
var miss_count: Dictionary = {}
var last: Dictionary = {}
var total_gain := 0
var max_gain := 0
var opportunity_count := 0
var mistimed_count := 0
var recovery_wait: Dictionary = {}
var recovered_total: Dictionary = {}


func reset() -> void:
	for id in Balance.ACTION_IDS:
		adaptation[id] = 0.0
		recovery_wait[id] = 0.0
		recovered_total[id] = 0.0
		cooldown[id] = 0.0
		use_count[id] = 0
		miss_count[id] = 0
	last = {}
	total_gain = 0
	max_gain = 0
	opportunity_count = 0
	mistimed_count = 0


func advance(delta: float) -> void:
	for id in Balance.ACTION_IDS:
		cooldown[id] = maxf(0.0, cooldown[id] - delta)
		# Integrate only the part of this interval at/after the 20s boundary.
		var wait_left := maxf(0.0, Balance.RECOVERY_DELAY - recovery_wait[id])
		var recovery_seconds := maxf(0.0, delta - wait_left)
		recovery_wait[id] += delta
		var recovered := minf(adaptation[id], recovery_seconds * Balance.RECOVERY_RATE)
		adaptation[id] = maxf(0.0, adaptation[id] - recovered)
		recovered_total[id] += recovered


func is_recovering(id: String) -> bool:
	return recovery_wait[id] >= Balance.RECOVERY_DELAY and adaptation[id] > 0.0


func execute(id: String, resident: Node) -> Dictionary:
	if not Balance.ACTIONS.has(id) or cooldown[id] > 0.0:
		return {}
	var data: Dictionary = Balance.ACTIONS[id]
	var state: String = resident.effective_state()
	var state_multiplier: float = data.multipliers[state]
	var missed := is_zero_approx(state_multiplier)
	var opportunity: bool = not missed and resident.current_opportunity_action() == id
	# 0.0 is the debug sentinel for a Miss: no timing multiplier is applied.
	var timing_multiplier := 0.0 if missed else (
		Balance.GOOD_TIMING_MULTIPLIER if opportunity else Balance.MISTIMED_MULTIPLIER)
	var adaptation_before: float = adaptation[id]
	var adaptation_multiplier := maxf(
		Balance.ADAPTATION_MIN_MULTIPLIER, 1.0 - adaptation_before / 100.0)
	var gain := 0 if missed else roundi(data.base_fear * state_multiplier * timing_multiplier * adaptation_multiplier)
	cooldown[id] = data.cooldown
	use_count[id] += 1
	if missed:
		miss_count[id] += 1
	else:
		recovery_wait[id] = 0.0
		adaptation[id] = minf(Balance.ADAPTATION_MAX, adaptation_before + data.adaptation_gain)
		if opportunity:
			opportunity_count += 1
		else:
			mistimed_count += 1
	total_gain += gain
	max_gain = maxi(max_gain, gain)
	last = {
		"action": id, "state": state, "current_state": resident.state, "base_fear": data.base_fear,
		"state_multiplier": state_multiplier, "adaptation_multiplier": adaptation_multiplier,
		"timing_multiplier": timing_multiplier, "opportunity": opportunity,
		"gain": gain, "missed": missed, "adaptation_before": adaptation_before,
	}
	return last


func average_gain() -> float:
	var count := 0
	for value in use_count.values():
		count += value
	return float(total_gain) / count if count > 0 else 0.0
