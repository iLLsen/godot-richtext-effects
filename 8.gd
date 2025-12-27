# rte_radioactive.gd
# Effect: [rad]
# Description: Neon green glow, throbbing size, and random twitching.
# Parameters:
# - freq: Pulse speed (default 5.0)

@tool
class_name RichTextRadioactive
extends RichTextEffect

var bbcode: String = "rad"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var freq: float = char_fx.env.get("freq", 5.0)
	
	var time: float = char_fx.elapsed_time
	# FIXED: Changed absolute_index to relative_index for Godot 4.0/4.1 compatibility
	var idx: float = float(char_fx.relative_index)
	
	# Sickly Green Color Base
	var neon_green: Color = Color(0.2, 1.0, 0.2)
	var dim_green: Color = Color(0.1, 0.5, 0.1)
	
	# Pulsing color
	var pulse: float = (sin(time * freq + idx) + 1.0) * 0.5
	char_fx.color = dim_green.lerp(neon_green, pulse)
	
	# Occasional Twitch (Scale distortion)
	var twitch_noise: float = sin(time * 20.0 + idx * 50.0)
	if twitch_noise > 0.9:
		# Sharp scale change
		char_fx.transform = char_fx.transform.scaled_local(Vector2(1.2, 0.8))
		char_fx.offset.x += 1.0
	
	return true
