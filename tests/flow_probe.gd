extends SceneTree
const Resident = preload("res://scripts/resident.gd")
const Actions = preload("res://scripts/ghost_action_manager.gd")


func _initialize() -> void:
	call_deferred("run")


func streak_probe(weighted: bool) -> Dictionary:
	var resident = Resident.new()
	resident.rng.seed = 903
	resident.reset()
	var histogram := {}
	var counts := {"WATCH_TV": 0, "DRINK_WATER": 0, "SLEEP": 0}
	var last := ""
	var streak := 0
	var maximum := 0
	var repetitions := 0
	for sample in 10000:
		if not weighted:
			# Empty history uses the production selector's unchanged base weights.
			resident.last_non_walk_activity = ""
			resident.previous_non_walk_activity = ""
		var activity: String = resident.choose_activity()
		resident.enter_state(activity)
		resident.enter_state("WALK")
		counts[activity] += 1
		if activity == last:
			streak += 1
			repetitions += 1
		else:
			if streak > 0: histogram[str(streak)] = histogram.get(str(streak), 0) + 1
			streak = 1
		last = activity
		maximum = maxi(maximum, streak)
	histogram[str(streak)] = histogram.get(str(streak), 0) + 1
	resident.free()
	return {"activities": 10000, "counts": counts, "run_length_histogram": histogram,
		"max_same_activity_streak": maximum, "consecutive_repeats": repetitions}


func recovery_snapshot(actions: RefCounted, time: float, event: String) -> Dictionary:
	return {"time": time, "event": event, "adaptation": actions.adaptation.duplicate(),
		"wait": actions.recovery_wait.duplicate(), "recovered_total": actions.recovered_total.duplicate()}


func recovery_probe() -> Array[Dictionary]:
	# Controlled starting adaptation=60 each, last recognition t=0; no Fear tuning.
	var actions = Actions.new()
	actions.reset()
	for id in ["LIGHT", "SOUND", "SHADOW"]: actions.adaptation[id] = 60.0
	var resident = Resident.new()
	resident.reset()
	var snapshots: Array[Dictionary] = [recovery_snapshot(actions, 0.0, "controlled initial adaptation 60 each")]
	actions.advance(19.999)
	snapshots.append(recovery_snapshot(actions, 19.999, "before threshold"))
	actions.advance(0.001)
	snapshots.append(recovery_snapshot(actions, 20.0, "recovery starts, no instantaneous decrement"))
	actions.advance(1.0)
	snapshots.append(recovery_snapshot(actions, 21.0, "one full second recovered"))
	resident.enter_state("SLEEP")
	actions.execute("LIGHT", resident)
	snapshots.append(recovery_snapshot(actions, 21.0, "LIGHT Miss leaves its wait unchanged"))
	actions.execute("SOUND", resident)
	snapshots.append(recovery_snapshot(actions, 21.0, "SOUND recognized resets SOUND only"))
	actions.advance(5.0)
	snapshots.append(recovery_snapshot(actions, 26.0, "LIGHT/SHADOW recover while SOUND rests"))
	resident.enter_state("WALK")
	resident.position.x = 570.0
	actions.execute("SHADOW", resident)
	snapshots.append(recovery_snapshot(actions, 26.0, "SHADOW recognized resets SHADOW only"))
	actions.advance(20.0)
	snapshots.append(recovery_snapshot(actions, 46.0, "independent recovery windows"))
	resident.free()
	return snapshots


func run() -> void:
	var report := {"seed": 903, "base_weights": streak_probe(false), "anti_streak": streak_probe(true),
		"recovery_timeline": recovery_probe(), "human_core_fun": "NOT VERIFIED"}
	DirAccess.make_dir_recursive_absolute("res://test-output")
	var file := FileAccess.open("res://test-output/flow_probe_v03.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t"))
	print("STREAK_BASE: " + JSON.stringify(report.base_weights))
	print("STREAK_WEIGHTED: " + JSON.stringify(report.anti_streak))
	print("RECOVERY_PROBE: " + JSON.stringify(report.recovery_timeline))
	quit()
