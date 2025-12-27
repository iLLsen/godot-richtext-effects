# rte_poor.gd
# Effect: [poor]
# Description: Simulates low quality/damaged items. Text flickers slightly in opacity and looks desaturated.
# Default Color: WoW Gray (#9d9d9d)
# Parameters: 
# - freq: Speed of the flicker (default 2.0)
# - dim: How dim the text gets (0.0 to 1.0, default 0.5)
# - color: Override color (default #9d9d9d)

@tool
class_name RichTextPoor
extends RichTextEffect

# Define the tag name
var bbcode: String = "poor"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	# Get parameters or defaults
	var freq: float = char_fx.env.get("freq", 2.0)
	var dim_level: float = char_fx.env.get("dim", 0.5)
	
	# Apply WoW Poor Color (Gray) unless overridden
	var base_color: Color = char_fx.env.get("color", Color("9d9d9d"))
	char_fx.color = base_color
	
	# Create a noise-like value based on time and character index
	# using sin() product to create irregular flickering
	var time: float = char_fx.elapsed_time
	# FIXED: Use range.x for Godot 4.5+ compatibility
	var idx: int = char_fx.range.x
	
	var noise: float = sin(time * freq * 10.0 + float(idx) * 13.0) * sin(time * freq * 3.7)
	
	# If noise is negative, dim the character
	if noise < 0.0:
		var alpha_mod: float = map_range(noise, -1.0, 0.0, dim_level, 1.0)
		char_fx.color.a *= alpha_mod
		
		# Slight desaturation (graying out) when dim to look "rusty"
		var gray: float = (char_fx.color.r + char_fx.color.g + char_fx.color.b) / 3.0
		char_fx.color = char_fx.color.lerp(Color(gray, gray, gray, char_fx.color.a), 0.5)
		
	return true

# Helper to map ranges
func map_range(val: float, in_min: float, in_max: float, out_min: float, out_max: float) -> float:
	return (val - in_min) / (in_max - in_min) * (out_max - out_min) + out_min
