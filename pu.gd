@tool
class_name SlideRevealEffect
extends RichTextEffect

# syntax: [reveal dist=200.0 angle=-20.0 duration=1.2 delay=0.0 repeat=yes]Content[/reveal]

# The tag name used in the BBCode.
var bbcode: String = "reveal"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	# Retrieve custom parameters to match the CUSTOMSTYLE specification.
	# dist: Initial offset in pixels (CUSTOMSTYLE: translateX(200px)). 
	#       Use negative values for slideRight behavior.
	# angle: Skew angle in degrees (CUSTOMSTYLE: skewX(20deg)).
	# duration: Time in seconds for the animation to complete.
	# delay: Optional delay before starting.
	var dist: float = char_fx.env.get("dist", 200.0)
	var angle_deg: float = char_fx.env.get("angle", -20.0)
	var duration: float = char_fx.env.get("duration", 1.2)
	var delay: float = char_fx.env.get("delay", 0.0)
	
	# Check for repeat parameter. Supports "yes", "true", "1".
	var repeat_raw = char_fx.env.get("repeat", "no")
	var repeat: bool = str(repeat_raw).to_lower() in ["yes", "true", "1"]
	
	var t_abs: float = 0.0
	
	if repeat:
		# Cycle includes the delay: Delay -> Animation -> Delay -> ...
		var total_cycle: float = duration + delay
		# Modulo elapsed time by the total cycle to loop.
		# Subtracting delay shifts the cycle so 0 to delay is negative (waiting).
		if total_cycle > 0.0:
			t_abs = fmod(char_fx.elapsed_time, total_cycle) - delay
		else:
			t_abs = 0.0
	else:
		# Standard behavior: Wait delay once, then animate.
		t_abs = char_fx.elapsed_time - delay
	
	# Calculate normalized time (0.0 to 1.0)
	# If t_abs < 0 (during delay), t becomes negative, clamped to 0.0 below.
	var t: float = t_abs / duration
	t = clampf(t, 0.0, 1.0)
	
	# --- CUBIC BEZIER EASING ---
	# CUSTOMSTYLE: cubic-bezier(0.68, -0.55, 0.265, 1.10)
	# Since RichTextEffect gives us linear time, we can approximate the Bezier curve
	# by evaluating the Y component (Output Value) using the polynomial directly.
	# P0=0, P1=-0.55, P2=1.10, P3=1.0
	# Formula: B(t) = (1-t)^3*P0 + 3(1-t)^2*t*P1 + 3(1-t)*t^2*P2 + t^3*P3
	
	var one_minus_t: float = 1.0 - t
	var t2: float = t * t
	var one_minus_t2: float = one_minus_t * one_minus_t
	
	# P0 is 0, so first term is 0.
	# P3 is 1, so last term is t^3.
	var p1: float = -0.55
	var p2: float = 1.10
	
	var eased_progress: float = 3.0 * one_minus_t2 * t * p1 + 3.0 * one_minus_t * t2 * p2 + (t * t * t)
	
	# --- TRANSFORM LOGIC ---
	
	# 1. Skew
	# Godot Transform2D skew is applied to the Y component of the X axis (shear).
	# Skew angle in radians.
	var skew_rad: float = deg_to_rad(angle_deg)
	
	# Apply skew to the existing transform.
	# Matrix multiplication: [1, tan(skew), 0, 1]
	# However, CharFXTransform exposes the transform directly.
	# Modifying x.y creates a horizontal skew (shear along X based on Y).
	var skew_transform: Transform2D = Transform2D()
	skew_transform.x.y = tan(skew_rad)
	
	char_fx.transform = char_fx.transform * skew_transform
	
	# 2. Translation (Slide)
	# We interpolate from 'dist' to 0 based on the eased progress.
	# When eased_progress is 0 (start), offset is dist.
	# When eased_progress is 1 (end), offset is 0.
	# Note: The CUSTOMSTYLE curve goes negative (-0.55), meaning eased_progress will dip.
	# So (1.0 - -0.55) * dist = 1.55 * dist. The text will pull back further than dist initially.
	var current_offset_x: float = dist * (1.0 - eased_progress)
	
	char_fx.offset.x += current_offset_x
	
	# 3. Alpha (Optional but recommended for "Reveal")
	# CUSTOMSTYLE slides span in. If delay is active (t_abs < 0), hide it.
	if t_abs < 0.0:
		char_fx.color.a = 0.0
	
	return true
