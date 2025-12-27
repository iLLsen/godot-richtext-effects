# rte_noise.gd
# Effect: [noise speed=0.5 intensity=0.2]
# Description: Replicates a CUSTOMSTYLE 'Noise + Shimmer + Tilt' effect.
# Note: Since RichTextEffect works on Glyphs (not pixels), the "Noise" is simulated 
# via rapid character flickering rather than an SVG texture mask.
#
# Parameters:
# - speed: Animation speed multiplier (default 1.0)
# - intensity: Noise intensity (0.0 to 1.0, default 0.5)

@tool
class_name RichTextNoise
extends RichTextEffect

var bbcode: String = "noise"

# CUSTOMSTYLE Base Color: CornflowerBlue
var COL_BASE: Color = Color("6495ED")
# Shimmer Target: Brightness 500% (White/Overexposed)
var COL_HIGHLIGHT: Color = Color(1.5, 1.5, 2.0) # Values > 1.0 work in HDR, or clamp to White for SDR

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var speed: float = char_fx.env.get("speed", 1.0)
	var noise_amt: float = char_fx.env.get("intensity", 0.5)
	
	var time: float = char_fx.elapsed_time * speed
	# Use range.x for Godot 4.5+ compatibility
	var idx: int = int(char_fx.range.x)
	
	# --- 1. Shimmer Animation (2s loop) ---
	# CUSTOMSTYLE: filter: contrast(190%) brightness(500%) -> brightness(130%)
	# We simulate this by pulsing from Base Color to Highlight Color
	var shimmer_phase: float = (sin(time * PI) + 1.0) * 0.5 # 0.0 to 1.0 sine wave
	
	# Sharpen the curve to mimic the high contrast look
	shimmer_phase = pow(shimmer_phase, 3.0) 
	
	var final_color: Color = COL_BASE.lerp(COL_HIGHLIGHT, shimmer_phase * 0.7)
	
	# --- 2. Noise Simulation ---
	# CUSTOMSTYLE uses SVG turbulence. We approximate by jittering value/alpha per frame.
	# We use a pseudo-random hash based on time (floored to frames) and index.
	var noise_time: float = floor(time * 30.0) # 30 FPS noise update
	var rand_hash: float = sin(float(idx) * 12.9898 + noise_time * 78.233) * 43758.5453
	var noise_val: float = fmod(abs(rand_hash), 1.0) # 0.0 to 1.0
	
	if noise_val < noise_amt:
		# Randomly dim or lighten to create "grain"
		var grain: float = 1.0 - (noise_val * 0.5)
		final_color.a *= grain
		final_color.r *= grain
		final_color.g *= grain
		final_color.b *= grain
	
	char_fx.color = final_color
	
	# --- 3. Perspective Tilt (Cube Rotate) ---
	# CUSTOMSTYLE: rotate3d(0.6, 0.05, 0.2, 0deg -> 20deg)
	# We approximate this with a Skew Transform (Shear)
	var tilt_phase: float = sin(time * PI) # -1.0 to 1.0
	var skew_angle: float = tilt_phase * 0.1 # Gentle tilt
	
	# Apply Skew Matrix
	# [ 1, tan(skew), 0 ]
	# [ 0, 1, 0 ]
	var skew_x: float = tan(skew_angle)
	
	# Apply skew to the transform
	char_fx.transform.x.y += skew_x
	
	# Add slight vertical offset to simulate the "lift" of rotation
	char_fx.offset.y += abs(tilt_phase) * 2.0
	
	return true
