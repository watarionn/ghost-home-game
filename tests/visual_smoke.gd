extends SceneTree
## Render actual game frames and exercise viewport mouse events locally.
const Main = preload("res://scenes/main.tscn")
var game: Node
var failures := 0
var screenshot_count := 0


func _initialize() -> void:
	call_deferred("run")


func capture(filename: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	var error := root.get_texture().get_image().save_png("res://test-output/v03_" + filename + ".png")
	screenshot_count += 1
	if error != OK:
		failures += 1
		push_error("Screenshot failed: " + filename)


func click_at(pos: Vector2) -> void:
	var motion := InputEventMouseMotion.new()
	motion.position = pos
	Input.parse_input_event(motion)
	for down in [true, false]:
		var event := InputEventMouseButton.new()
		event.position = pos
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = down
		Input.parse_input_event(event)
		await process_frame


func verify(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)


func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://test-output")
	game = Main.instantiate()
	root.add_child(game)
	game.set_process(false)
	await process_frame
	for state in ["WALK", "WATCH_TV", "DRINK_WATER", "SLEEP", "SURPRISED", "ALERT"]:
		game.restart()
		game.resident.enter_state(state)
		game.refresh()
		await capture(state.to_lower())
	for state in ["WATCH_TV", "SLEEP"]:
		game.restart()
		game.resident.enter_state(state)
		game.advance(1.0)
		await capture(state.to_lower() + "_settled")
	for sample in [["WATCH_TV", 0.25], ["WATCH_TV", 1.5], ["WATCH_TV", 3.1], ["SLEEP", 0.7], ["SLEEP", 2.0], ["SLEEP", 4.1]]:
		game.restart()
		game.resident.enter_state(sample[0])
		game.advance(sample[1])
		await capture("cue_%s_%.2f" % [sample[0].to_lower(), sample[1]])
	# Mouse-triggered GOOD TIMING and mistimed feedback for each of the three actions.
	for example in [["LIGHT", "WATCH_TV", 0.0, 220, 200, 22],
		["SOUND", "SLEEP", 0.0, 950, 600, 36],
		["SHADOW", "WALK", 0.0, 570, 1060, 47],
		["LIGHT", "WATCH_TV", 3.0, 220, 200, 6],
		["SOUND", "SLEEP", 4.0, 950, 600, 10],
		["SHADOW", "WALK", 0.0, 700, 1060, 14]]:
		game.restart()
		game.resident.enter_state(example[1])
		game.resident.remaining = game.resident.duration - example[2]
		game.resident.position.x = example[3]
		game.refresh()
		await click_at(Vector2(example[4], 710))
		verify(game.fear == example[5], "Mouse timing result " + example[0])
		await capture(example[0].to_lower() + ("_good" if game.actions.last.opportunity else "_mistimed"))
		game.advance(0.25)
		await capture(example[0].to_lower() + ("_good_reaction" if game.actions.last.opportunity else "_mistimed_reaction"))
	game.restart()
	game.resident.enter_state("WATCH_TV")
	game.actions.adaptation.LIGHT = 40.0
	game.perform_action("LIGHT")
	game.advance(0.25)
	await capture("habituated_good")
	game.restart()
	game.resident.enter_state("SLEEP")
	game.advance(5.0)
	game.perform_action("SHADOW")
	await capture("shadow_miss_settled")
	game.restart()
	game.resident.enter_state("WATCH_TV")
	game.debug_visible = true
	game.refresh()
	await capture("opportunity_debug")
	game.restart()
	game.resident.enter_state("SLEEP")
	game.refresh()
	await click_at(Vector2(200, 710))
	verify(game.actions.use_count.LIGHT == 1 and game.fear == 0, "Mouse LIGHT misses sleeping resident")
	await capture("miss")
	await click_at(Vector2(600, 710))
	verify(game.actions.use_count.SOUND == 1 and game.fear == 36, "Mouse SOUND causes 36 fear")
	game.debug_visible = true
	game.refresh()
	verify(game.ui.debug_panel.position.x == 40.0, "Debug avoids resident and feedback on right")
	await capture("feedback_debug")
	await click_at(Vector2(1150, 90))
	verify(game.paused and game.ui.overlay.visible, "Mouse Pause")
	await capture("pause")
	await click_at(Vector2(600, 710))
	verify(game.actions.use_count.SOUND == 1, "Pause blocks underlying button")
	await click_at(Vector2(640, 520))
	verify(not game.paused, "Mouse Resume")
	game.resident.enter_state("WALK")
	game.fear = 90
	await click_at(Vector2(1060, 710))
	verify(game.result == "WIN", "Mouse SHADOW wins")
	await capture("win")
	await click_at(Vector2(640, 520))
	verify(game.result.is_empty() and game.fear == 0, "Mouse Restart")
	game.advance(180.0)
	await capture("lose")
	await click_at(Vector2(640, 520))
	verify(game.result.is_empty() and game.time_remaining == 180.0, "Mouse second Restart")
	await capture("restart")
	game.queue_free()
	await process_frame
	print("VISUAL_SMOKE: %d screenshots, viewport mouse tests, %d failures" % [screenshot_count, failures])
	quit(0 if failures == 0 else 1)
