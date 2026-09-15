extends SceneTree
## Local tests only. Run with Godot --headless --path . --script tests/acceptance.gd.
const Main = preload("res://scenes/main.tscn")
var game: Node
var checks := 0
var failures := 0


func _initialize() -> void:
	call_deferred("run")


func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("FAIL: " + description)


func fresh(state := "WALK") -> void:
	game.restart()
	game.resident.enter_state(state)
	game.refresh()


func press_key(key: Key, echo := false) -> void:
	var event := InputEventKey.new()
	event.keycode = key
	event.pressed = true
	event.echo = echo
	Input.parse_input_event(event)


func release_key(key: Key) -> void:
	var event := InputEventKey.new()
	event.keycode = key
	event.pressed = false
	Input.parse_input_event(event)


func run() -> void:
	game = Main.instantiate()
	root.add_child(game)
	game.set_process(false)
	await process_frame
	check(game.fear == 0 and game.time_remaining == 180.0, "initial fear/timer")
	for id in ["LIGHT", "SOUND", "SHADOW"]:
		check(game.actions.adaptation[id] == 0 and game.actions.cooldown[id] == 0.0, "initial " + id)
	# Independent expected rounded outcomes for every normal state/action pair.
	var expected := {
		"WATCH_TV": [13, 8, 18], "WALK": [10, 12, 27],
		"DRINK_WATER": [8, 14, 23], "SLEEP": [0, 20, 0],
		"SURPRISED": [8, 12, 18], "ALERT": [8, 12, 18],
	}
	var ids := ["LIGHT", "SOUND", "SHADOW"]
	var cooldowns := [8.0, 10.0, 15.0]
	var adaptations := [20, 22, 30]
	for state in expected:
		for i in ids.size():
			fresh(state)
			game.perform_action(ids[i])
			check(game.fear == expected[state][i], "rounded gain " + state + "/" + ids[i])
			check(game.actions.cooldown[ids[i]] == cooldowns[i], "cooldown on " + state + "/" + ids[i])
			var missed: bool = expected[state][i] == 0
			check(game.actions.adaptation[ids[i]] == (0 if missed else adaptations[i]), "adaptation " + state + "/" + ids[i])
			check(game.actions.miss_count[ids[i]] == (1 if missed else 0), "miss counter")
			check(game.ui.action_buttons[ids[i]].disabled, "button disabled during cooldown")
			if missed:
				check(game.resident.state == "SLEEP" and game.feedback.begins_with("気づかなかった"), "miss leaves resident asleep")
			var before: int = game.fear
			game.perform_action(ids[i])
			check(game.fear == before and game.actions.use_count[ids[i]] == 1, "cooldown rejects repeated action")
	# Diminishing returns uses pre-action adaptation, not the just-increased value.
	fresh("SLEEP")
	game.perform_action("SOUND")
	check(game.actions.last.gain == 20, "first SOUND at SLEEP = 20")
	game.actions.advance(10.0)
	game.resident.enter_state("SLEEP")
	game.perform_action("SOUND")
	check(game.actions.last.gain == 16 and game.actions.adaptation.SOUND == 44, "second SOUND at SLEEP = 16")
	check(game.feedback.contains("慣れてきた"), "adaptation feedback explains diminished effect")
	for id in ids:
		game.actions.reset()
		for i in 10:
			game.actions.advance(15.0)
			game.actions.execute(id, "WALK")
		check(game.actions.adaptation[id] == 80, "adaptation clamps at 80: " + id)
		check(is_equal_approx(game.actions.last.adaptation_multiplier, 0.2), "minimum multiplier 0.2")
		game.actions.advance(100.0)
		check(game.actions.adaptation[id] == 80, "adaptation never decays")
	game.actions.reset()
	game.actions.execute("LIGHT", "WALK")
	check(game.actions.cooldown.SOUND == 0.0 and game.actions.adaptation.SHADOW == 0, "action independence")
	game.actions.execute("SOUND", "SLEEP")
	game.actions.execute("SHADOW", "SLEEP")
	check(game.actions.total_gain == 30 and game.actions.max_gain == 20, "logging max/total include correct gains")
	check(is_equal_approx(game.actions.average_gain(), 10.0), "average includes misses")
	# AI durations, autonomous transitions, motion, and reaction restoration.
	fresh()
	var start: Vector2 = game.resident.position
	game.advance(0.5)
	check(game.resident.position != start, "WALK moves resident")
	var ranges := {"WALK": Vector2(4, 7), "WATCH_TV": Vector2(12, 20), "DRINK_WATER": Vector2(5, 8), "SLEEP": Vector2(20, 30)}
	for state in ranges:
		for i in 20:
			game.resident.enter_state(state)
			check(game.resident.remaining >= ranges[state].x and game.resident.remaining <= ranges[state].y, "duration " + state)
	var visits := {"WATCH_TV": 0, "DRINK_WATER": 0, "SLEEP": 0}
	game.resident.rng.seed = 8472
	for i in 10000:
		visits[game.resident.choose_activity()] += 1
	check(absf(visits.WATCH_TV / 10000.0 - 0.4) < 0.02, "TV probability 40%")
	check(absf(visits.DRINK_WATER / 10000.0 - 0.3) < 0.02, "water probability 30%")
	check(absf(visits.SLEEP / 10000.0 - 0.3) < 0.02, "sleep probability 30%")
	for i in 30:
		game.resident.enter_state("WALK")
		game.resident.advance(game.resident.remaining)
		check(game.resident.state in visits, "WALK autonomously chooses activity")
		game.resident.advance(game.resident.remaining)
		check(game.resident.state == "WALK", "activity returns to WALK")
	fresh("WATCH_TV")
	var saved: float = game.resident.remaining
	game.perform_action("LIGHT")
	check(game.resident.state == "SURPRISED", "recognized action triggers SURPRISED")
	game.advance(1.5)
	check(game.resident.state == "ALERT" and game.resident.remaining == 3.0, "SURPRISED 1.5 seconds then ALERT")
	game.advance(3.0)
	check(game.resident.state == "WATCH_TV" and is_equal_approx(game.resident.remaining, saved), "ALERT restores interrupted activity after 3 seconds")
	# Pause is a single simulation gate; input, feedback and every timer freeze.
	fresh("SLEEP")
	game.perform_action("LIGHT")
	game.toggle_pause()
	var snapshot := [game.time_remaining, game.resident.remaining, game.resident.position, game.actions.cooldown.duplicate(), game.feedback_remaining]
	game.advance(90.0)
	for id in ids: game.perform_action(id)
	press_key(KEY_2)
	await process_frame
	release_key(KEY_2)
	check(snapshot == [game.time_remaining, game.resident.remaining, game.resident.position, game.actions.cooldown, game.feedback_remaining], "pause freezes all simulation and feedback")
	check(game.actions.use_count.SOUND == 0, "pause rejects keyboard actions without queueing")
	check(game.ui.overlay.visible and game.ui.overlay.color.a == 1.0, "pause obscures board")
	press_key(KEY_F1)
	await process_frame
	release_key(KEY_F1)
	check(not game.ui.debug_panel.visible, "debug cannot expose paused board")
	game.toggle_pause()
	game.advance(0.5)
	check(is_equal_approx(game.feedback_remaining, 1.3) and game.actions.use_count.SOUND == 0, "resume timers without buffered action")
	# Feed the actual viewport keyboard input pipeline.
	fresh("SLEEP")
	press_key(KEY_2)
	await process_frame
	release_key(KEY_2)
	check(game.fear == 20 and game.actions.use_count.SOUND == 1, "keyboard 2 executes SOUND")
	press_key(KEY_3, true)
	await process_frame
	check(game.actions.use_count.SHADOW == 0, "keyboard repeat ignored")
	press_key(KEY_F1)
	await process_frame
	release_key(KEY_F1)
	check(game.ui.debug_panel.visible and game.ui.debug_panel.label.text.contains("LastFearGain: 20"), "F1 debug fields visible")
	press_key(KEY_F1)
	await process_frame
	release_key(KEY_F1)
	check(not game.ui.debug_panel.visible, "F1 hides debug")
	# Mouse and keyboard share the same execution path (button signal binding).
	fresh("WALK")
	game.ui.action_buttons.SHADOW.pressed.emit()
	check(game.fear == 27 and game.actions.use_count.SHADOW == 1, "button executes SHADOW")
	for entry in [[0, "平常"], [24, "平常"], [25, "少し不安"], [49, "少し不安"], [50, "警戒"], [74, "警戒"], [75, "かなり怯えている"], [99, "かなり怯えている"], [100, "限界"]]:
		game.fear = entry[0]
		check(game.fear_stage() == entry[1], "fear stage boundary")
	fresh("WALK")
	game.fear = 99
	game.perform_action("SHADOW")
	check(game.fear == 100 and game.result == "WIN", "fear clamps at 100 and wins")
	check(game.ui.overlay_message.text.begins_with("こんな家住めるか！"), "WIN feedback")
	var report: String = game.last_report
	game.advance(30.0)
	game.perform_action("SOUND")
	game.finish("LOSE")
	check(game.last_report == report and game.actions.use_count.SOUND == 0 and game.time_remaining == 180.0, "end stops simulation and logs only once")
	# Three complete losses and restarts: no pending effects, history, or timers leak.
	for play in 3:
		game.ui.restart_button.pressed.emit()
		check(game.result.is_empty() and game.fear == 0 and game.time_remaining == 180.0, "restart game state")
		check(game.actions.last.is_empty() and game.actions.average_gain() == 0 and game.feedback_remaining == 0.0, "restart counters and feedback")
		game.advance(179.0)
		check(game.result.is_empty() and game.time_remaining == 1.0, "still running at 179 seconds")
		game.advance(1.0)
		check(game.result == "LOSE" and game.time_remaining == 0.0, "LOSE at exactly 180 seconds")
		check(game.ui.overlay_message.text.begins_with("なんだ、気のせいか"), "LOSE feedback")
		for field in ["RESULT", "PLAY_TIME", "FINAL_FEAR", "LIGHT_USE_COUNT", "SOUND_USE_COUNT", "SHADOW_USE_COUNT", "LIGHT_MISS_COUNT", "SOUND_MISS_COUNT", "SHADOW_MISS_COUNT", "LIGHT_FINAL_ADAPTATION", "SOUND_FINAL_ADAPTATION", "SHADOW_FINAL_ADAPTATION", "MAX_FEAR_GAIN", "AVERAGE_FEAR_GAIN"]:
			check(game.last_report.contains(field + "="), "console field " + field)
	game.queue_free()
	await process_frame
	print("ACCEPTANCE: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
