extends SceneTree
## Runs an unmodified 180-second game through the actual _process loop.
var game: Node
var started := 0


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	started = Time.get_ticks_msec()
	while game.result.is_empty():
		await process_frame
	var wall_seconds := (Time.get_ticks_msec() - started) / 1000.0
	var passed: bool = game.result == "LOSE" and game.time_remaining == 0.0 and wall_seconds >= 179.0 and wall_seconds < 185.0
	print("REALTIME_TIMEOUT: result=%s simulation=%.3f wall=%.3f PASS=%s" % [
		game.result, game.Balance.GAME_TIME - game.time_remaining, wall_seconds, passed])
	game.queue_free()
	await process_frame
	quit(0 if passed else 1)
