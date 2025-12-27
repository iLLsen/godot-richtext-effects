# rte_neon.gd
# Effect: [neon]
# Description: Simulates a faulty neon sign with flickering opacity and color shifting.
# Recreates the CUSTOMSTYLE "flicker" (opacity) and "blink" (color) animations.
#
# Note: RichTextEffect cannot render the complex CUSTOMSTYLE 'text-shadow' glow layers.
# To achieve the full glow, use a WorldEnvironment with Glow/Bloom enabled in your scene,
# which will react to the high-brightness colors used here.
#
# Parameters:
# - speed: Global speed multiplier for the loop (default 1.0).

@tool
class_name RichTextFxNeon
extends RichTextEffect

var bbcode: String = "neon"

# Colors from CUSTOMSTYLE
const COL_BASE = Color("#ff2483") # White/Pinkish
const COL_BLINK_1 = Color("#ff65bd") # Hot Pink
const COL_BLINK_2 = Color("#ffe6ff") # Deep Pink

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var speed: float = char_fx.env.get("speed", 0.2)
	
	# Create a unique offset for each character to desynchronize the effect.
	# We use a pseudo-random constant derived from the index.
	# This ensures every letter flickers independently.
	var char_seed: float = float(char_fx.relative_index) * 33.12345 
	
	var time: float = (char_fx.elapsed_time * speed) + char_seed
	
	# --- 1. Opacity Flicker (CUSTOMSTYLE .flicker) ---
	# The CUSTOMSTYLE uses specific percentages for drops in opacity.
	# We simulate this using high-frequency noise.
	# We use a pseudo-random hash of time to ensure it looks random but is consistent.
	
	var flicker_noise: float = sin(time * 50.0) * sin(time * 23.0 + 45.0)
	var opacity: float = 1.0
	
	# Randomly drop opacity based on noise thresholds, mimicking the CUSTOMSTYLE keyframes
	if flicker_noise > 0.90:
		opacity = 0.5 # Big drop (CUSTOMSTYLE 38%)
	elif flicker_noise > 0.75:
		opacity = 0.85 # Small drop
	elif flicker_noise > 0.60:
		opacity = 0.92 # Tiny jitter
	
	# --- 2. Color Blink (CUSTOMSTYLE @keyframes blink) ---
	# 0-22%: Base
	# 28-33%: Blink 1
	# 36-75%: Base
	# 82-97%: Blink 2
	
	# We normalize time into a 0.0-1.0 loop (approx 10s cycle in fast-flicker, 3s in normal)
	# Using a 5.0s loop for a balanced default.
	var loop_t: float = fmod(time / 5.0, 1.0)
	var color: Color = COL_BASE
	
	if loop_t > 0.28 and loop_t < 0.33:
		color = COL_BLINK_1
	elif loop_t > 0.82 and loop_t < 0.97:
		color = COL_BLINK_2
		
	# Apply changes
	char_fx.color = color
	char_fx.color.a = opacity
	
	return true
