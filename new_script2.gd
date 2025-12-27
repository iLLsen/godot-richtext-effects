# rte_uncommon.gd
# Effect: [uncommon]
# Description: A gentle, fluid floating motion for magical but standard items.
# Default Color: WoW Green (#1eff00)
# Parameters:
# - freq: Speed of the wave (default 2.0)
# - span: Distance between wave peaks (default 10.0)
# - amp: Height of the float (default 4.0)
# - color: Override color (default #1eff00)

@tool
class_name RichTextUncommon
extends RichTextEffect

var bbcode: String = "uncommon"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var freq: float = char_fx.env.get("freq", 2.0)
	var span: float = char_fx.env.get("span", 10.0)
	var amp: float = char_fx.env.get("amp", 4.0)
	
	# Apply WoW Uncommon Color (Green) unless overridden
	var base_color: Color = char_fx.env.get("color", Color("1eff00"))
	char_fx.color = base_color
	
	var time: float = char_fx.elapsed_time
	# FIXED: Use range.x for Godot 4.5+ compatibility
	var idx: float = float(char_fx.range.x)
	
	# Simple Sine Wave offset
	var y_offset: float = sin(time * freq + (idx / span)) * amp
	
	char_fx.offset.y += y_offset
	
	return true
