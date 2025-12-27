# rte_mythic.gd
# Effect: [mythic]
# Description: The ultimate effect. Rainbow cycling + Floating + Slight Scaling.
# Parameters:
# - freq: Rainbow speed (default 0.5)
# - sat: Saturation (default 0.8)
# - val: Value (default 1.0)

@tool
class_name RichTextMythic
extends RichTextEffect

var bbcode: String = "mythic"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var freq: float = char_fx.env.get("freq", 0.5)
	var sat: float = char_fx.env.get("sat", 0.8)
	var val: float = char_fx.env.get("val", 1.0)
	
	var time: float = char_fx.elapsed_time
	# FIXED: Changed absolute_index to relative_index for Godot 4.0/4.1 compatibility
	var idx: float = float(char_fx.relative_index)
	
	# 1. Rainbow Color
	var hue: float = fmod(time * freq + (idx * 0.05), 1.0)
	var rainbow: Color = Color.from_hsv(hue, sat, val)
	char_fx.color = rainbow
	
	# 2. Float Motion
	var float_y: float = sin(time * 3.0 + (idx * 0.2)) * 3.0
	char_fx.offset.y += float_y
	
	# 3. Scale Pulse
	var scale_pulse: float = (sin(time * 2.0 + (idx * 0.1)) + 1.0) * 0.5 # 0 to 1
	var s: float = 1.0 + (scale_pulse * 0.2)
	char_fx.transform = char_fx.transform.scaled_local(Vector2(s, s))
	
	return true
