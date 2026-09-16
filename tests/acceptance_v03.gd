extends "res://tests/acceptance.gd"
const Actions = preload("res://scripts/ghost_action_manager.gd")


func seed_recovery(value := 60.0) -> void:
	fresh("WALK")
	for id in ["LIGHT", "SOUND", "SHADOW"]:
		game.actions.adaptation[id] = value


func run() -> void:
	game = Main.instantiate()
	root.add_child(game)
	game.set_process(false)
	await process_frame
	var ids := ["WATCH_TV", "DRINK_WATER", "SLEEP"]
	var base := [0.4, 0.3, 0.3]
	fresh()
	for i in 3:
		check(is_equal_approx(game.resident.activity_weights()[ids[i]], base[i]), "base weights unchanged")
	# Test all penalty targets, replacement (not product), and normalization.
	for target in 3:
		for count in [1, 2, 3]:
			fresh()
			for n in count:
				game.resident.enter_state(ids[target])
				game.resident.enter_state("WALK")
			var weights: Dictionary = game.resident.activity_weights()
			var penalty := 0.35 if count == 1 else 0.15
			var denominator: float = 1.0 - base[target] + base[target] * penalty
			var sum := 0.0
			for candidate in 3:
				var expected: float = base[candidate] * (penalty if candidate == target else 1.0) / denominator
				check(is_equal_approx(weights[ids[candidate]], expected), "normalized repeat weights %s/%d/%s" % [ids[target], count, ids[candidate]])
				check(weights[ids[candidate]] > 0.0, "no activity is forbidden")
				sum += weights[ids[candidate]]
			check(is_equal_approx(sum, 1.0), "weight sum is one")
			check(game.resident.last_non_walk_activity == ids[target], "WALK excluded from history")
			check(game.resident.max_same_activity_streak == count, "max streak counts activities only")
			game.resident.rng.seed = 390 + target
			var repeated := false
			for sample in 500:
				if game.resident.choose_activity() == ids[target]: repeated = true
			check(repeated, "same activity can actually be sampled after streak")
	# Actual normal->reaction->restore must not become an extra activity/history entry.
	fresh("WATCH_TV")
	game.resident.enter_state("WALK")
	game.resident.enter_state("SLEEP")
	check(game.resident.previous_non_walk_activity == "WATCH_TV", "previous records non-WALK activity")
	game.perform_action("SOUND")
	game.advance(4.5)
	check(game.resident.last_non_walk_activity == "SLEEP" and game.resident.previous_non_walk_activity == "WATCH_TV", "reaction restoration is not a new activity")
	check(game.resident.same_activity_streak == 1, "different activity breaks streak")
	# Continuous integration: at t=20 recovering begins, without an instant -1 jump.
	for id in ["LIGHT", "SOUND", "SHADOW"]:
		seed_recovery()
		game.actions.advance(19.999)
		check(game.actions.adaptation[id] == 60.0 and not game.actions.is_recovering(id), "19.999 no recovery " + id)
		game.actions.advance(0.001)
		check(is_equal_approx(game.actions.recovery_wait[id], 20.0) and game.actions.is_recovering(id), "20.000 recovery active " + id)
		check(is_equal_approx(game.actions.adaptation[id], 60.0), "20.000 has zero elapsed recovering time")
		game.actions.advance(1.0)
		check(is_equal_approx(game.actions.adaptation[id], 59.0), "one second recovers one unit")
		game.actions.advance(0.25)
		check(is_equal_approx(game.actions.adaptation[id], 58.75), "fractional adaptation preserved")
		game.actions.advance(100.0)
		check(game.actions.adaptation[id] == 0.0 and not game.actions.is_recovering(id), "floor zero and recovering false")
		check(is_equal_approx(game.actions.recovered_total[id], 60.0), "recovered total never exceeds available adaptation")
	seed_recovery()
	game.actions.advance(19.75)
	game.actions.advance(0.5)
	check(is_equal_approx(game.actions.adaptation.LIGHT, 59.75), "straddling frame integrates only .25s")
	var partitioned = Actions.new()
	partitioned.reset()
	partitioned.adaptation.LIGHT = 60.0
	for n in 405: partitioned.advance(0.05)
	check(is_equal_approx(partitioned.adaptation.LIGHT, game.actions.adaptation.LIGHT), "recovery independent of frame partition")
	# Recognized GOOD and MISTIMED reset only the used action.
	for good in [true, false]:
		for id in ["LIGHT", "SOUND", "SHADOW"]:
			seed_recovery(20.0)
			game.actions.advance(25.0)
			var state: String = {"LIGHT": "WATCH_TV", "SOUND": "SLEEP", "SHADOW": "WALK"}[id]
			game.resident.enter_state(state)
			if not good and id != "SHADOW": game.resident.remaining = game.resident.duration - 5.0
			game.resident.position.x = 570.0 if good else 700.0
			game.perform_action(id)
			check(game.feedback_kind == ("GOOD" if good else "MISTIMED"), "recognized setup")
			check(game.actions.recovery_wait[id] == 0.0, "recognized action resets own wait")
			check(game.actions.adaptation[id] == 15.0 + game.Balance.ACTIONS[id].adaptation_gain, "recognized gain applied after fractional recovery")
			for other in ["LIGHT", "SOUND", "SHADOW"]:
				if other != id:
					check(game.actions.recovery_wait[other] == 25.0 and game.actions.adaptation[other] == 15.0, "other-action independence")
	# Both zero recognition actions preserve wait, recovery and reaction.
	for id in ["LIGHT", "SHADOW"]:
		seed_recovery()
		game.actions.advance(21.0)
		game.resident.enter_state("SLEEP")
		game.perform_action(id)
		check(game.actions.recovery_wait[id] == 21.0 and game.actions.adaptation[id] == 59.0, "Miss does not reset wait or add adaptation")
		check(game.resident.state == "SLEEP" and game.resident.reaction_strength == 0.0, "Miss does not start reaction")
		check(game.actions.cooldown[id] == game.Balance.ACTIONS[id].cooldown, "Miss still starts cooldown")
		game.advance(1.0)
		check(is_equal_approx(game.actions.adaptation[id], 58.0), "recovery continues through miss cooldown")
	seed_recovery()
	game.actions.advance(21.0)
	game.toggle_pause()
	game.advance(100.0)
	game.perform_action("LIGHT")
	check(game.actions.adaptation.LIGHT == 59.0 and game.actions.recovery_wait.LIGHT == 21.0, "pause freezes recovery and wait")
	game.toggle_pause()
	game.advance(1.0)
	check(is_equal_approx(game.actions.adaptation.LIGHT, 58.0), "resume recovery")
	for outcome in ["WIN", "LOSE"]:
		seed_recovery()
		game.actions.advance(21.0)
		if outcome == "WIN":
			game.fear = 99
			game.perform_action("SHADOW")
		else:
			game.time_remaining = 0.0
			game.advance(0.0)
		check(game.result == outcome, "end setup")
		game.advance(100.0)
		check(game.actions.adaptation.LIGHT == 59.0 and game.actions.recovery_wait.LIGHT == 21.0, "result freezes recovery")
		check(game.last_report.contains("LIGHT_RECOVERED_TOTAL=1.000") and game.last_report.contains("MAX_SAME_ACTIVITY_STREAK="), "logging additions")
	# F1 OFF: outcome is communicated by words, separate number, pose and pulse.
	var good_size := 0
	for category in ["GOOD", "MISTIMED", "MISS"]:
		fresh("WATCH_TV" if category != "MISS" else "SLEEP")
		if category == "MISTIMED": game.resident.remaining = game.resident.duration - 4.0
		game.perform_action("LIGHT")
		check(not game.ui.debug_panel.visible and game.feedback_kind == category, "category visible without Debug")
		var expected: String = {"GOOD": "大成功！", "MISTIMED": "効いたが弱い…", "MISS": "気づかなかった…"}[category]
		check(game.room.feedback_label.text == expected, "different outcome wording")
		check(not game.feedback.contains("×") and not game.feedback_reason.is_empty(), "result/reason replace numerical multipliers")
		if category == "GOOD":
			good_size = game.room.feedback_gain_label.get_theme_font_size("font_size")
			check(game.resident.reaction_strength == 1.0 and game.room.pulse_alpha() > 0.0, "GOOD strongest reaction and pulse")
		elif category == "MISTIMED":
			check(game.resident.reaction_strength == 0.3 and game.room.pulse_alpha() == 0.0, "MISTIMED weaker reaction no pulse")
			check(game.room.feedback_gain_label.get_theme_font_size("font_size") < good_size, "MISTIMED smaller fear number")
		else:
			check(not game.room.feedback_gain_label.visible and game.room.feedback_gain_label.text.is_empty(), "MISS hides fear number")
			check(game.resident.state == "SLEEP" and game.room.pulse_alpha() == 0.0, "MISS no surprise or pulse")
	# Preserve fractional adaptation in the next fear calculation, not integer truncation.
	fresh("SLEEP")
	game.actions.adaptation.SOUND = 20.75
	game.perform_action("SOUND")
	check(is_equal_approx(game.actions.last.adaptation_multiplier, 0.7925), "fear uses fractional adaptation")
	game.debug_visible = true
	game.refresh()
	for field in ["LastNonWalkActivity", "PreviousNonWalkActivity", "CurrentActivityWeights", "LightRecoveryWait", "SoundRecoveryWait", "ShadowRecoveryWait", "LightRecovering", "SoundRecovering", "ShadowRecovering"]:
		check(game.ui.debug_panel.flow_label.text.contains(field), "debug field " + field)
	game.restart()
	check(game.resident.last_non_walk_activity.is_empty() and game.resident.previous_non_walk_activity.is_empty() and game.resident.max_same_activity_streak == 0, "restart history")
	for id in ["LIGHT", "SOUND", "SHADOW"]:
		check(game.actions.recovery_wait[id] == 0.0 and game.actions.recovered_total[id] == 0.0, "restart recovery counters")
	game.queue_free()
	await process_frame
	print("ACCEPTANCE_V03: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
