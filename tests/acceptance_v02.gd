extends "res://tests/acceptance.gd"
## v0.2 regression tests run against the real resident, action path and UI.


func at_time(state: String, elapsed: float) -> void:
	fresh(state)
	game.resident.duration = 15.0
	game.resident.remaining = 15.0 - elapsed
	game.refresh()


func run() -> void:
	game = Main.instantiate()
	root.add_child(game)
	game.set_process(false)
	await process_frame
	# Half-open time windows: [0,3) / [0,4), including the exact edges.
	for spec in [["WATCH_TV", "LIGHT", 3.0, 22, 6, 20], ["SLEEP", "SOUND", 4.0, 36, 10, 22]]:
		for elapsed in [0.0, spec[2] - 0.001, spec[2], spec[2] + 0.001]:
			at_time(spec[0], elapsed)
			var inside: bool = elapsed < spec[2]
			check(game.resident.current_opportunity_action() == (spec[1] if inside else "NONE"), "time window edge %s %.3f" % [spec[0], elapsed])
			game.perform_action(spec[1])
			check(game.fear == (spec[3] if inside else spec[4]), "rounded timing result")
			check(game.actions.last.timing_multiplier == (1.75 if inside else 0.50), "timing multiplier")
			check(game.actions.adaptation[spec[1]] == spec[5], "both timings increase adaptation equally")
			check(game.actions.opportunity_count == int(inside) and game.actions.mistimed_count == int(not inside), "disjoint timing counters")
			check(game.feedback.contains("GOOD TIMING" if inside else "タイミングが悪い"), "feedback explains timing after action")
	# Fixed room-local X interval with inclusive endpoints; Y is irrelevant.
	for x in [499.999, 500.0, 570.0, 640.0, 640.001]:
		for y in [200.0, 330.0, 380.0]:
			fresh("WALK")
			game.resident.position = Vector2(x, y)
			var inside: bool = x >= 500 and x <= 640
			check(game.resident.current_opportunity_action() == ("SHADOW" if inside else "NONE"), "shadow position edge %s" % str(Vector2(x, y)))
			game.perform_action("SHADOW")
			check(game.fear == (47 if inside else 14), "shadow timing gain")
			check(game.actions.adaptation.SHADOW == 30, "shadow recognized adaptation")
	for state in ["WATCH_TV", "DRINK_WATER", "SLEEP"]:
		at_time(state, 5.0)
		game.resident.position.x = 570.0
		check(game.resident.current_opportunity_action() == "NONE", "zone alone does not grant opportunity outside WALK")
	# The zone opportunity applies only to SHADOW, not the other two actions.
	for spec in [["LIGHT", 5], ["SOUND", 6]]:
		fresh("WALK")
		game.resident.position.x = 570.0
		game.perform_action(spec[0])
		check(game.fear == spec[1] and not game.actions.last.opportunity, "opportunity must match action")
	# All effective normal contexts survive both reaction states, with no GOOD TIMING.
	var expected := {
		"WATCH_TV": [6, 4, 9], "DRINK_WATER": [4, 7, 12],
		"WALK": [5, 6, 14], "SLEEP": [0, 10, 0],
	}
	var ids := ["LIGHT", "SOUND", "SHADOW"]
	for state in expected:
		for reaction in ["SURPRISED", "ALERT"]:
			for i in ids.size():
				at_time(state, 0.5)
				game.resident.position.x = 570.0
				game.resident.react()
				if reaction == "ALERT": game.advance(1.5)
				check(game.resident.state == reaction and game.resident.effective_state() == state, "effective state in " + reaction)
				check(is_equal_approx(game.resident.normal_elapsed_time(), 0.5), "normal context elapsed preserved")
				check(game.resident.current_opportunity_action() == "NONE", "reactions suppress all opportunities")
				game.perform_action(ids[i])
				check(game.fear == expected[state][i], "effective context fear " + state + "/" + ids[i])
				var missed: bool = expected[state][i] == 0
				check(game.actions.last.timing_multiplier == (0.0 if missed else 0.5), "miss precedence over mistimed")
				check(game.actions.opportunity_count == 0 and game.actions.mistimed_count == int(not missed), "reaction counters exclude misses")
				check(game.resident.effective_state() == state, "chained reaction keeps original context")
	# Reported v0.1 exploit: real SOUND followed by repeated SHADOW keyboard input.
	at_time("SLEEP", 0.5)
	game.perform_action("SOUND")
	check(game.fear == 36 and game.resident.state == "SURPRISED", "SLEEP SOUND setup")
	for i in 5:
		press_key(KEY_3)
		await process_frame
		release_key(KEY_3)
	check(game.fear == 36 and game.actions.miss_count.SHADOW == 1, "SLEEP SOUND SURPRISED SHADOW spam misses once")
	check(game.actions.adaptation.SHADOW == 0 and game.actions.cooldown.SHADOW == 15.0, "reaction miss preserves adaptation but costs cooldown")
	check(game.resident.remaining == 1.5, "miss does not extend reaction")
	game.advance(1.5)
	game.perform_action("LIGHT")
	check(game.resident.state == "ALERT" and game.actions.miss_count.LIGHT == 1, "SLEEP context also misses in ALERT")
	game.advance(3.0)
	check(game.resident.state == "SLEEP" and is_equal_approx(game.resident.state_elapsed_time(), 0.5), "normal elapsed resumes instead of resetting")
	game.advance(3.5)
	check(game.resident.current_opportunity_action() == "NONE", "resumed window closes at total normal elapsed 4 seconds")
	# Actual second recognized action during reaction retains the original TV clock.
	at_time("WATCH_TV", 2.0)
	game.perform_action("LIGHT")
	game.advance(0.5)
	game.perform_action("SOUND")
	check(game.actions.last.state == "WATCH_TV" and game.actions.last.gain == 4, "second reaction uses TV rather than neutral state")
	game.advance(4.5)
	check(game.resident.state == "WATCH_TV" and is_equal_approx(game.resident.state_elapsed_time(), 2.0), "nested reaction restores first snapshot")
	game.advance(1.0)
	check(game.resident.current_opportunity_action() == "NONE", "nested reaction does not reset opportunity clock")
	# Pause freezes opportunity, position, context, feedback and all timing counters.
	at_time("WATCH_TV", 2.999)
	game.toggle_pause()
	game.advance(30.0)
	game.perform_action("LIGHT")
	check(game.resident.current_opportunity_action() == "LIGHT" and game.actions.use_count.LIGHT == 0, "pause freezes window and blocks action")
	game.toggle_pause()
	game.advance(0.002)
	check(game.resident.current_opportunity_action() == "NONE", "window expires on resumed clock")
	at_time("SLEEP", 1.0)
	game.perform_action("SOUND")
	game.toggle_pause()
	game.advance(15.0)
	game.perform_action("SHADOW")
	check(game.resident.state == "SURPRISED" and game.resident.effective_state() == "SLEEP", "pause preserves reaction context")
	check(game.resident.normal_elapsed_time() == 1.0 and game.resident.remaining == 1.5, "pause freezes both normal and reaction clocks")
	check(game.actions.opportunity_count == 1 and game.actions.mistimed_count == 0 and game.actions.use_count.SHADOW == 0, "pause leaves timing counters unchanged")
	game.toggle_pause()
	game.advance(4.5)
	check(game.resident.state == "SLEEP" and game.resident.state_elapsed_time() == 1.0, "paused reaction resumes original clock")
	# A Miss never increases even pre-existing adaptation and is not mistimed.
	at_time("SLEEP", 1.0)
	game.actions.adaptation.LIGHT = 40
	game.perform_action("LIGHT")
	check(game.actions.adaptation.LIGHT == 40 and game.actions.mistimed_count == 0, "miss leaves pre-existing adaptation unchanged")
	# A natural WALK crosses into the corridor; no hidden hint is added to buttons.
	fresh("WALK")
	game.resident.walk_from = Vector2(490, 330)
	game.resident.walk_to = Vector2(650, 330)
	game.resident.position = game.resident.walk_from
	game.resident.duration = 4.0
	game.resident.remaining = 4.0
	game.refresh()
	var button_text: String = game.ui.action_buttons.SHADOW.text
	game.advance(0.25)
	check(game.resident.position.x == 500 and game.resident.current_opportunity_action() == "SHADOW", "movement enters corridor opportunity")
	check(game.ui.action_buttons.SHADOW.text == button_text, "opportunity does not change normal action button")
	game.advance(3.5)
	check(game.resident.position.x == 640 and game.resident.current_opportunity_action() == "SHADOW", "last zone edge inclusive during movement")
	game.advance(0.025)
	check(game.resident.current_opportunity_action() == "NONE", "movement exits corridor")
	# New debug values, logging counts and restarts.
	at_time("WATCH_TV", 0.5)
	game.debug_visible = true
	game.refresh()
	for field in ["EffectiveState: WATCH_TV", "StateElapsedTime: 0.50", "CurrentOpportunityAction: LIGHT", "IsOpportunityWindow: true", "LastTimingMultiplier:"]:
		check(game.ui.debug_panel.label.text.contains(field), "debug " + field)
	game.perform_action("LIGHT")
	game.perform_action("SOUND")
	game.refresh()
	check(game.ui.debug_panel.label.text.contains("CurrentOpportunityAction: NONE") and game.ui.debug_panel.label.text.contains("LastTimingMultiplier: 0.5"), "reaction debug reports context and mistimed value")
	game.finish("LOSE")
	check(game.last_report.contains("OPPORTUNITY_SUCCESS_COUNT=1") and game.last_report.contains("MISTIMED_ACTION_COUNT=1"), "end log timing counters")
	game.restart()
	check(game.actions.opportunity_count == 0 and game.actions.mistimed_count == 0, "restart timing counters")
	check(game.resident.state == "WALK" and game.resident.state_elapsed_time() == 0.0, "restart normal clock")
	check(game.resident.suspended_remaining == 0.0 and game.actions.last.is_empty(), "restart context and last timing")
	game.queue_free()
	await process_frame
	print("ACCEPTANCE_V02: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
