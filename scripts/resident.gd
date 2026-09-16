extends Node2D
## Simulation is advanced only by GameManager, so pause freezes every timer.
const Balance = preload("res://data/balance.gd")
const POSITIONS := {
	"WATCH_TV": Vector2(220, 200),
	"DRINK_WATER": Vector2(600, 200),
	"SLEEP": Vector2(950, 210),
}
const LABELS := {
	"WALK": "散歩中", "WATCH_TV": "テレビを見ている", "DRINK_WATER": "水を飲んでいる",
	"SLEEP": "眠っている", "SURPRISED": "びっくり！", "ALERT": "あたりを警戒中",
}

var rng := RandomNumberGenerator.new()
var state := "WALK"
var remaining := 0.0
var duration := 0.0
var walk_from := Vector2.ZERO
var walk_to := Vector2.ZERO
var suspended_state := "WALK"
var suspended_remaining := 0.0
var suspended_duration := 0.0
var fear := 0


func is_reacting() -> bool:
	return state in ["SURPRISED", "ALERT"]


func effective_state() -> String:
	return suspended_state if is_reacting() else state


func state_elapsed_time() -> float:
	return duration - remaining


func normal_elapsed_time() -> float:
	return suspended_duration - suspended_remaining if is_reacting() else state_elapsed_time()


func current_opportunity_action() -> String:
	# Reactions preserve normal context but can never grant GOOD TIMING.
	if is_reacting():
		return "NONE"
	match state:
		"WATCH_TV":
			if state_elapsed_time() < Balance.LIGHT_WINDOW_SECONDS:
				return "LIGHT"
		"SLEEP":
			if state_elapsed_time() < Balance.SOUND_WINDOW_SECONDS:
				return "SOUND"
		"WALK":
			# Room-local X, inclusive endpoints. Y intentionally does not participate.
			if position.x >= Balance.SHADOW_ZONE_X.x and position.x <= Balance.SHADOW_ZONE_X.y:
				return "SHADOW"
	return "NONE"


func reset() -> void:
	position = Vector2(430, 330)
	fear = 0
	suspended_state = "WALK"
	suspended_remaining = 0.0
	suspended_duration = 0.0
	enter_state("WALK")


func enter_state(next_state: String) -> void:
	state = next_state
	var limits: Vector2 = Balance.STATE_DURATIONS[state]
	duration = rng.randf_range(limits.x, limits.y)
	remaining = duration
	if state == "WALK":
		walk_from = position
		walk_to = Vector2(rng.randf_range(270, 810), rng.randf_range(310, 380))
	elif POSITIONS.has(state):
		position = POSITIONS[state]
	queue_redraw()


func choose_activity() -> String:
	var roll := rng.randf()
	var cumulative := 0.0
	for i in Balance.NEXT_ACTIVITIES.size():
		cumulative += Balance.ACTIVITY_WEIGHTS[i]
		if roll < cumulative:
			return Balance.NEXT_ACTIVITIES[i]
	return "SLEEP"


func react() -> void:
	# Preserve the interrupted activity only on the first reaction.
	if not is_reacting():
		suspended_state = state
		suspended_remaining = remaining
		suspended_duration = duration
	enter_state("SURPRISED")


func advance(delta: float) -> void:
	var left := delta
	while left > 0.0:
		var step := minf(left, remaining)
		remaining = maxf(0.0, remaining - step)
		left -= step
		if state == "WALK":
			position = walk_from.lerp(walk_to, 1.0 - remaining / duration)
		if remaining <= 0.000001:
			match state:
				"WALK": enter_state(choose_activity())
				"SURPRISED": enter_state("ALERT")
				"ALERT":
					state = suspended_state
					remaining = suspended_remaining
					duration = suspended_duration
				_: enter_state("WALK")
	queue_redraw()


func _draw() -> void:
	var body_color := Color("a4d7d2")
	if fear >= 75:
		body_color = Color("f89997")
	elif fear >= 50:
		body_color = Color("eaba8e")
	elif fear >= 25:
		body_color = Color("e3d59e")
	draw_ellipse_body(body_color)
	if state == "SLEEP":
		draw_line(Vector2(-13, -10), Vector2(-5, -10), Color("17212c"), 3)
		draw_line(Vector2(5, -10), Vector2(13, -10), Color("17212c"), 3)
	else:
		draw_circle(Vector2(-9, -11), 3, Color("17212c"))
		draw_circle(Vector2(9, -11), 3, Color("17212c"))
	if state == "SURPRISED" or fear >= 75 or (state == "SLEEP" and state_elapsed_time() < 0.8):
		draw_circle(Vector2(0, 3), 6, Color("17212c"))
	else:
		draw_line(Vector2(-5, 4), Vector2(5, 4), Color("17212c"), 2)
	if state == "DRINK_WATER":
		draw_rect(Rect2(20, -6, 16, 22), Color("7fcbf2"))
	if state == "WATCH_TV":
		var remote_y := -16.0 if state_elapsed_time() < 0.8 else 8.0
		draw_rect(Rect2(22, remote_y, 10, 18), Color("273444"))
	if state == "ALERT":
		draw_arc(Vector2.ZERO, 43, -2.8, -0.3, 24, Color("f0c16c"), 3)
	if state == "WALK":
		var stride := sin(remaining * 9) * 9
		draw_line(Vector2(-10, 20), Vector2(-14 + stride, 37), body_color, 7)
		draw_line(Vector2(10, 20), Vector2(14 - stride, 37), body_color, 7)


func draw_ellipse_body(color: Color) -> void:
	draw_circle(Vector2.ZERO, 28, color)
	draw_rect(Rect2(-21, 4, 42, 23), color)
