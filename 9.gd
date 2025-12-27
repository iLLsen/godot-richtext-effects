# rte_frozen.gd
# Effect: [ice]
# Description: Static, cold blue text that shivers rigidly.
# Parameters:
# - span: Offset span (default 2.0)

@tool
class_name RichTextFrozen
extends RichTextEffect

var bbcode: String = "ice"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var span: float = char_fx.env.get("span", 1.0)
	
	var time: float = char_fx.elapsed_time
	# FIXED: Changed absolute_index to relative_index for Godot 4.0/4.1 compatibility
	var idx: int = char_fx.relative_index
	
	# Constant Blue Tint
	char_fx.color = char_fx.color.lerp(Color(0.5, 0.8, 1.0), 0.8)
	
	# Rigid Shiver
	# Only moves occasionally, very fast
	var shiver_timer: float = fmod(time, 2.0) # Every 2 seconds
	
	if shiver_timer > 1.8: # Last 0.2 seconds
		var noise: float = sin(time * 50.0 + float(idx))
		char_fx.offset.x += noise * span
	
	return true
