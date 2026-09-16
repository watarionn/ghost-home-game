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
	var trials: Array[Dictionary] = []
	var failures := 0
	for policy in ["cooldown_order", "opportunity_aware", "light_only"]:
		var wins := 0
		var total_time := 0.0
		var total_fear := 0
		var total_opportunity := 0
		var total_mistimed := 0
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
					var id: String = game.resident.current_opportunity_action()
					if id != "NONE":
						game.perform_action(id)
				game.advance(0.1)
			wins += int(game.result == "WIN")
			total_time += 180.0 - game.time_remaining
			total_fear += game.fear
			total_opportunity += game.actions.opportunity_count
			total_mistimed += game.actions.mistimed_count
			var uses := 0
			var misses := 0
			for id in ["LIGHT", "SOUND", "SHADOW"]:
				uses += game.actions.use_count[id]
				misses += game.actions.miss_count[id]
			if uses != misses + game.actions.opportunity_count + game.actions.mistimed_count:
				failures += 1
			if policy == "opportunity_aware" and (misses > 0 or game.actions.mistimed_count > 0):
				failures += 1
			trials.append({
				"policy": policy, "seed": seed_value, "result": game.result,
				"seconds": 180.0 - game.time_remaining, "final_fear": game.fear,
				"opportunity_successes": game.actions.opportunity_count,
				"mistimed_actions": game.actions.mistimed_count, "misses": misses,
				"uses": game.actions.use_count.duplicate(),
			})
		summary[policy] = {
			"games": 20, "wins": wins, "win_rate": wins / 20.0,
			"mean_seconds": total_time / 20, "mean_fear": total_fear / 20.0,
			"mean_opportunity_successes": total_opportunity / 20.0,
			"mean_mistimed_actions": total_mistimed / 20.0,
		}
	DirAccess.make_dir_recursive_absolute("res://test-output")
	var file := FileAccess.open("res://test-output/policy_probe_v02.json", FileAccess.WRITE)
	file.store_string(JSON.stringify({"version": "0.2", "step_seconds": 0.1,
		"seeds": "0..19", "summary": summary, "trials": trials, "failures": failures}, "\t"))
	print("POLICY_PROBE: " + JSON.stringify(summary))
	print("POLICY_PROBE_VALIDATION: 60 games, %d failures; human Core Fun NOT VERIFIED" % failures)
	game.queue_free()
	await process_frame
	quit(0 if failures == 0 else 1)
