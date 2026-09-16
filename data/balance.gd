extends RefCounted
## Stage 1 tuning values. Keep all gameplay numbers here.

const GAME_TIME := 180.0
const WIN_FEAR := 100
const ADAPTATION_MAX := 80
const ADAPTATION_MIN_MULTIPLIER := 0.2
const FEEDBACK_TIME := 1.8
const GOOD_TIMING_MULTIPLIER := 1.75
const MISTIMED_MULTIPLIER := 0.50
const LIGHT_WINDOW_SECONDS := 3.0
const SOUND_WINDOW_SECONDS := 4.0
const SHADOW_ZONE_X := Vector2(500, 640)
const STATE_DURATIONS := {
	"WALK": Vector2(3, 5),
	"WATCH_TV": Vector2(9, 14),
	"DRINK_WATER": Vector2(4, 6),
	"SLEEP": Vector2(12, 18),
	"SURPRISED": Vector2(1.5, 1.5),
	"ALERT": Vector2(3, 3),
}
const NEXT_ACTIVITIES := ["WATCH_TV", "DRINK_WATER", "SLEEP"]
const ACTIVITY_WEIGHTS := [0.4, 0.3, 0.3]
const ACTION_IDS := ["LIGHT", "SOUND", "SHADOW"]
const ACTIONS := {
	"LIGHT": {
		"label": "照明OFF", "base_fear": 8, "cooldown": 8.0, "adaptation_gain": 20,
		"multipliers": {"WATCH_TV": 1.6, "WALK": 1.2, "DRINK_WATER": 1.0, "SLEEP": 0.0},
	},
	"SOUND": {
		"label": "怪音", "base_fear": 12, "cooldown": 10.0, "adaptation_gain": 22,
		"multipliers": {"WATCH_TV": 0.7, "WALK": 1.0, "DRINK_WATER": 1.2, "SLEEP": 1.7},
	},
	"SHADOW": {
		"label": "人影", "base_fear": 18, "cooldown": 15.0, "adaptation_gain": 30,
		"multipliers": {"WATCH_TV": 1.0, "WALK": 1.5, "DRINK_WATER": 1.3, "SLEEP": 0.0},
	},
}
