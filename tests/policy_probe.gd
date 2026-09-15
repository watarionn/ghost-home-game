extends SceneTree
## Deterministic local design probe, not a human Core Fun evaluation.
const Main = preload("res://scenes/main.tscn")
var game: Node


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	game = Main.instantiate()
	root.add_child(game)
	game.set_process(false)
	await process_frame
	var summary := {}
	for policy in ["cooldown_order", "observe", "light_only"]:
		var wins := 0
		var total_time := 0.0
		var total_fear := 0
		for seed_value in range(20):
			game.resident.rng.seed = seed_value
			game.restart()
			while game.result.is_empty():
				if policy == "cooldown_order":
					for id in ["LIGHT", "SOUND", "SHADOW"]:
						game.perform_action(id)
				elif policy == "light_only":
					game.perform_action("LIGHT")
				else:
					match game.resident.state:
						"WATCH_TV": game.perform_action("LIGHT")
						"DRINK_WATER": game.perform_action("SHADOW")
						"WALK": game.perform_action("SHADOW")
						"SLEEP": game.perform_action("SOUND")
				game.advance(0.1)
			wins += int(game.result == "WIN")
			total_time += 180.0 - game.time_remaining
			total_fear += game.fear
		summary[policy] = {"games": 20, "wins": wins, "mean_seconds": total_time / 20, "mean_fear": total_fear / 20.0}
	DirAccess.make_dir_recursive_absolute("res://test-output")
	var file := FileAccess.open("res://test-output/policy_probe.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(summary, "\t"))
	print("POLICY_PROBE: " + JSON.stringify(summary))
	game.queue_free()
	await process_frame
	quit()
