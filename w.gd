# rte_waviy.gd
# Effect: [waviy]
# Description: Recreates the "Waviy" CUSTOMSTYLE animation.
# Characters jump up sequentially in a wave pattern.
#
# CUSTOMSTYLE Logic:
# - Duration: 1s infinite
# - Delay: 0.1s * index
# - Keyframes: 0% (0px) -> 20% (-20px) -> 40% (0px) -> 100% (0px)
#
# Note: The CUSTOMSTYLE 'box-reflect' cannot be done by this script. 
# To replicate the reflection, duplicate your Label node, set Scale.y to -1, 
# and modulate it to be transparent/faded.
#
# Parameters:
# - span: The jump height in pixels (default 20.0).
# - speed: Cycle duration multiplier (default 1.0).

@tool
class_name RichTextFxWaviy
extends RichTextEffect

var bbcode: String = "waviy"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	# Parameters
	var jump_height: float = char_fx.env.get("span", 20.0)
	var speed: float = char_fx.env.get("speed", 1.0)
	
	# Calculate adjusted time based on character index (Stagger)
	# CUSTOMSTYLE: animation-delay: calc(.1s * var(--i))
	# We subtract the delay from time so the "wave" travels left-to-right.
	# Adding an arbitrary large offset (1000.0) ensures we don't handle negative numbers 
	# at the very start of the app execution.
	var adjusted_time: float = (char_fx.elapsed_time * speed) - (char_fx.relative_index * 0.1) + 1000.0
	
	# Cycle is 1.0 seconds
	var t: float = fmod(adjusted_time, 1.0)
	
	var offset_y: float = 0.0
	
	# Logic: 0.0 -> 0.4 is the Jump (0 -> -20 -> 0)
	# 0.4 -> 1.0 is Idle
	if t < 0.4:
		# Map t (0.0 to 0.4) to a generic 0.0 to 1.0 range for the sine wave
		var wave_phase: float = t / 0.4
		
		# sin(0) = 0, sin(PI/2) = 1, sin(PI) = 0
		# This creates a perfect smooth jump arc
		var intensity: float = sin(wave_phase * PI)
		
		offset_y = -jump_height * intensity
	
	char_fx.offset.y += offset_y
	return true
