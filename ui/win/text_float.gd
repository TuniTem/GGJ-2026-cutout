extends RichTextEffect
class_name FloatEffect
var bbcode := "float"
# Use it in BBCode as: [spacefloat amp=8 rot_amp=6 min_speed=0.4 max_speed=1.2]
# You can also set a "seed" to reshuffle variation.

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	#if Engine.is_editor_hint():
		#return true
	var t: float = Util.TIME
	var idx: int = char_fx.relative_index

	# ---- Tunables (with user overrides via [spacefloat key=value]) ----
	var seed: int = int(char_fx.env.get("seed", 1337))
	var strength: float = float(char_fx.env.get("strength", 1.0)) # overall mix [0..1]
	var amp: float = float(char_fx.env.get("amp", 8.0)) * strength  # pixel displacement
	var rot_amp_deg: float = float(char_fx.env.get("rot_amp", 6.0)) * strength  # degrees
	var min_speed: float = float(char_fx.env.get("min_speed", 0.40))
	var max_speed: float = float(char_fx.env.get("max_speed", 1.20))
	var drift_scale: float = float(char_fx.env.get("drift", 0.5))  # 0..1, extra slow drift
	
	# ---- Per-glyph deterministic “random”s (stable across frames) ----
	var r1 := _rand01(idx * 92821 + seed)
	var r2 := _rand01(idx * 16361 + seed * 11)
	var r3 := _rand01(idx * 51349 + seed * 37)

	var sx := lerpf(min_speed, max_speed, r1)              # x “velocity”
	var sy := lerpf(min_speed, max_speed, r2)              # y “velocity”
	var ang_speed := lerpf(0.5, 1.5, r3)                   # rotation speed (rad/s-ish)

	var phase_x := r2 * TAU
	var phase_y := r3 * TAU
	var phase_rot := r1 * TAU

	# ---- Bounded, smooth motion (velocity-like but readable) ----
	# Lissajous path (independent x/y speeds) + slight elliptical coupling
	var x := sin(t * sx + phase_x)
	var y := sin(t * sy + phase_y)
	var orbit := Vector2(x, y) + Vector2(y, x) * 0.15     # subtle cross-coupling
	orbit *= amp                                          # amplitude in pixels

	# Slow global drift (feels like inertia in microgravity), very small
	var drift_speed := 0.15 + 0.35 * r3
	var drift_vec := Vector2(cos(t * drift_speed + phase_y), sin(t * drift_speed + phase_x)) * (amp * 0.20 * drift_scale)

	char_fx.offset = orbit + drift_vec

	# Gentle rotational wobble (keep small → readable)
	var rot := deg_to_rad(rot_amp_deg) * sin(t * ang_speed + phase_rot)
	char_fx.transform = char_fx.transform.rotated_local(rot)

	#char_fx.offset = Util.breathe(1, 10.0) * Vector2.ONE
	return true


func _rand01(n: int) -> float:
	var x = int(n * 1664525 + 1013904223) & 0x7fffffff
	return float(x) / 2147483647.0
