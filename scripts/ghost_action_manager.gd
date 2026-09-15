extends RefCounted
const Balance = preload("res://data/balance.gd")

var adaptation: Dictionary = {}
var cooldown: Dictionary = {}
var use_count: Dictionary = {}
var miss_count: Dictionary = {}
var last: Dictionary = {}
var total_gain := 0
var max_gain := 0


func reset() -> void:
	for id in Balance.ACTION_IDS:
		adaptation[id] = 0
		cooldown[id] = 0.0
		use_count[id] = 0
		miss_count[id] = 0
	last = {}
	total_gain = 0
	max_gain = 0


func advance(delta: float) -> void:
	for id in Balance.ACTION_IDS:
		cooldown[id] = maxf(0.0, cooldown[id] - delta)


func execute(id: String, state: String) -> Dictionary:
	if not Balance.ACTIONS.has(id) or cooldown[id] > 0.0:
		return {}
	var data: Dictionary = Balance.ACTIONS[id]
	# SURPRISED / ALERT have no numerical modifier in v0.1: neutral 1.0.
	var state_multiplier: float = data.multipliers.get(state, 1.0)
	var adaptation_before: int = adaptation[id]
	var adaptation_multiplier := maxf(
		Balance.ADAPTATION_MIN_MULTIPLIER, 1.0 - adaptation_before / 100.0)
	var gain := roundi(data.base_fear * state_multiplier * adaptation_multiplier)
	var missed := is_zero_approx(state_multiplier)
	cooldown[id] = data.cooldown
	use_count[id] += 1
	if missed:
		miss_count[id] += 1
	else:
		adaptation[id] = mini(Balance.ADAPTATION_MAX, adaptation_before + data.adaptation_gain)
	total_gain += gain
	max_gain = maxi(max_gain, gain)
	last = {
		"action": id, "state": state, "base_fear": data.base_fear,
		"state_multiplier": state_multiplier, "adaptation_multiplier": adaptation_multiplier,
		"gain": gain, "missed": missed, "adaptation_before": adaptation_before,
	}
	return last


func average_gain() -> float:
	var count := 0
	for value in use_count.values():
		count += value
	return float(total_gain) / count if count > 0 else 0.0
