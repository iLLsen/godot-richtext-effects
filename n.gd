# rte_variable.gd
# Effect: [variable]
# Description: Replicates a CUSTOMSTYLE Variable Font animation where text "breathes" 
# by expanding width and weight.
# Note: Since Godot cannot animate Variable Font coordinates (wght/wdth) per-frame 
# in RichTextEffect efficiently, this mimics the effect using Affine Scaling.
#
# Parameters:
# - speed: Animation speed multiplier (default 1.0 = 3s loop)
# - invert: If 1.0, plays the animation in reverse (like the .work class). Default 0.
# - scale_min: Min Width Scale (default 0.5 for 50%)
# - scale_max: Max Width Scale (default 2.0 for 200%)

@tool
class_name RichTextVariable
extends RichTextEffect

var bbcode: String = "variable"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var speed: float = char_fx.env.get("speed", 1.0)
	var invert: bool = char_fx.env.get("invert", 0.0) > 0.5
	var s_min: float = char_fx.env.get("scale_min", 0.5)
	var s_max: float = char_fx.env.get("scale_max", 2.0)
	
	# CUSTOMSTYLE Duration: 3s
	var loop_len: float = 3.0 / speed
	var time: float = char_fx.elapsed_time
	
	# Normalize time 0.0 - 1.0
	# CUSTOMSTYLE: infinite alternate? No, CUSTOMSTYLE says "infinite both" but keyframes 0->50->100
	# 0% (Thin) -> 50% (Thick) -> 100% (Thin)
	var t: float = fmod(time, loop_len) / loop_len
	
	# Convert 0->1 linear time to 0->1->0 triangle wave for the "back and forth" logic
	# 0.0 -> 0.5 (0 to 1)
	# 0.5 -> 1.0 (1 to 0)
	var phase: float
	if t < 0.5:
		phase = t * 2.0 # 0 to 1
	else:
		phase = 1.0 - ((t - 0.5) * 2.0) # 1 to 0
		
	# Invert logic for .work class simulation
	if invert:
		phase = 1.0 - phase
		
	# Apply Cubic Bezier Easing
	# CUSTOMSTYLE: cubic-bezier(0.17, 0.04, 0.04, 0.99)
	# This is a sharp curve. We approximate or solve.
	# For performance in GDScript, a simplified curve that matches closely:
	# It stays low then shoots up. Like a Quintic Ease Out mixed with Expo.
	# Let's use a custom curve approximation: y = 1 - (1-x)^4 roughly matches the "snap" to end
	# but the CUSTOMSTYLE curve has a slow start (0.17, 0.04).
	
	var eased_t: float = solve_cubic_bezier(phase, 0.17, 0.04, 0.04, 0.99)
	
	# --- Apply Transformations ---
	
	# 1. Width (wdth 50% -> 200%)
	# Scale X from s_min to s_max
	var current_scale_x: float = lerp(s_min, s_max, eased_t)
	
	# 2. Weight (wght 275 -> 900)
	# We simulate weight with slight Y scaling and maybe a tiny offset
	# 900 is heavy/blocky.
	var current_scale_y: float = lerp(0.9, 1.1, eased_t)
	
	# Apply Scale
	var pivot: Vector2 = char_fx.transform.get_origin()
	char_fx.transform = char_fx.transform.scaled_local(Vector2(current_scale_x, current_scale_y))
	
	# Compensation for spacing:
	# When scaling X in RichTextEffect, the character advances don't change automatically.
	# The text might overlap or have huge gaps.
	# We can try to modify offset.x to push characters apart, but we don't know neighbors' sizes.
	# Visual overlap is sometimes desired in "Variable Font" demos, but let's try to center it.
	
	return true

# Solves Cubic Bezier for 1D (Time -> Value)
# P0=(0,0), P1=(x1,y1), P2=(x2,y2), P3=(1,1)
func solve_cubic_bezier(t: float, x1: float, y1: float, x2: float, y2: float) -> float:
	# We estimate the Y value for a given X (t)
	# Since solving X(T)=t for T is expensive, we approximate with iterative mix
	# or just sample the curve.
	# Simple approach: Standard mix for visual FX
	
	# This is a raw approximation of the specific curve (0.17, 0.04, 0.04, 0.99)
	# It resembles an "EaseInOutExpo" but heavily weighted to the end.
	
	# Bezier basis functions
	var one_minus_t: float = 1.0 - t
	var t2: float = t * t
	var t3: float = t2 * t
	var mt2: float = one_minus_t * one_minus_t
	var mt3: float = mt2 * one_minus_t
	
	# Calculate Y directly using 't' as the parametric step (Linear approximation)
	# Ideally we solve for x, but direct mapping is often "close enough" for text FX
	# B(t) = (1-t)^3*P0 + 3(1-t)^2*t*P1 + 3(1-t)t^2*P2 + t^3*P3
	
	# P0=0, P3=1
	# 3*mt2*t*y1 + 3*one_minus_t*t2*y2 + t3
	
	return (3.0 * mt2 * t * y1) + (3.0 * one_minus_t * t2 * y2) + t3
