# rte_typewriter.gd
# Effect: [typewriter]
# Description: Reveals text character-by-character over time.
# Recreates the "typing" portion of the CUSTOMSTYLE animation using a RichTextEffect.
#
# Limitation: The 'blinking block cursor' from the CUSTOMSTYLE cannot be drawn
# by a RichTextEffect, as effects only manipulate existing character glyphs.
#
# Parameters:
# - speed: Seconds per character (default 0.05).
# - delay: Initial delay in seconds before typing starts (default 0.0).
# - repeat: If set to true/yes/1, the animation loops (requires 'cycle').
# - cycle: Total duration in seconds for one loop iteration (required if repeat is true).

@tool
class_name RichTextFxTypewriter
extends RichTextEffect

var bbcode: String = "typewriter"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	# Parameters
	var speed: float = char_fx.env.get("speed", 0.05)
	var delay: float = char_fx.env.get("delay", 0.0)
	
	# Repeat Logic
	# Parse various truthy values for the repeat parameter
	var repeat_raw: Variant = char_fx.env.get("repeat", false)
	var is_repeating: bool = str(repeat_raw).to_lower() in ["true", "yes", "1"]
	
	var current_time: float = char_fx.elapsed_time
	
	if is_repeating:
		# If repeating, we need a cycle duration to know when to loop.
		# Without 'cycle', we cannot determine the text end.
		var cycle: float = char_fx.env.get("cycle", 0.0)
		if cycle > 0.0:
			current_time = fmod(char_fx.elapsed_time, cycle)

	# Calculate the timestamp when this specific character should become visible
	var activation_time: float = delay + (float(char_fx.relative_index) * speed)
	
	# Check visibility status
	if current_time < activation_time:
		# Character is in the "future" -> Hide it
		char_fx.color.a = 0
	else:
		# Character is "past" -> Show it
		# (We leave color as-is, defaulting to visible)
		pass
		
	return true
