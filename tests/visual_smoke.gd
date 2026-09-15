extends SceneTree
## Render actual game frames and exercise viewport mouse events locally.
const Main = preload("res://scenes/main.tscn")
var game: Node
var failures := 0


func _initialize() -> void:
	call_deferred("run")


func capture(filename: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	var error := root.get_texture().get_image().save_png("res://test-output/" + filename + ".png")
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
	game.restart()
	game.resident.enter_state("SLEEP")
	game.refresh()
	await click_at(Vector2(200, 710))
	verify(game.actions.use_count.LIGHT == 1 and game.fear == 0, "Mouse LIGHT misses sleeping resident")
	await capture("miss")
	await click_at(Vector2(600, 710))
	verify(game.actions.use_count.SOUND == 1 and game.fear == 20, "Mouse SOUND causes 20 fear")
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
	print("VISUAL_SMOKE: 12 screenshots, viewport mouse tests, %d failures" % failures)
	quit(0 if failures == 0 else 1)
