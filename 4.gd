# rte_epic.gd
# Effect: [epic]
# Description: Heavy, slow "heartbeat" pulsing with a purple hue shift.
# Default Color: WoW Purple (#a335ee)
# Parameters:
# - freq: Pulse speed (default 1.0)
# - scale: Max scale size (default 1.25)
# - color: Override base color (default #a335ee)

@tool
class_name RichTextEpic
extends RichTextEffect

var bbcode: String = "epic"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var freq: float = char_fx.env.get("freq", 1.0)
	var max_scale: float = char_fx.env.get("scale", 1.25)
	
	# Apply WoW Epic Color (Purple) unless overridden
	var base_color: Color = char_fx.env.get("color", Color("a335ee"))
	
	var time: float = char_fx.elapsed_time
	
	# Heartbeat curve (sharp rise, slow fall)
	var t: float = fmod(time * freq, 1.0)
	
	# Smooth Sine alternatively for less "organic" feel, but let's stick to sine for readability
	var sine_pulse: float = (sin(time * freq * 5.0) + 1.0) * 0.5
	
	# Interpolate Scale
	var current_scale: float = lerp(1.0, max_scale, sine_pulse * 0.2) # Keeping it subtle
	
	# Apply Scale
	char_fx.transform = char_fx.transform.scaled_local(Vector2(current_scale, current_scale))
	
	# Pulse brightness slightly instead of drastic hue shift to maintain the "Epic Purple" look
	# Lighter purple at peak
	var light_purple: Color = base_color.lightened(0.3)
	char_fx.color = base_color.lerp(light_purple, sine_pulse * 0.5)
	
	return true
