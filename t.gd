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

@tool
class_name RichTextFxTypewriter
extends RichTextEffect

var bbcode: String = "typewriter"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	# Parameters
	var speed: float = char_fx.env.get("speed", 0.05)
	var delay: float = char_fx.env.get("delay", 0.0)
	
	# Calculate the timestamp when this specific character should become visible
	var activation_time: float = delay + (float(char_fx.relative_index) * speed)
	
	# Check visibility status
	if char_fx.elapsed_time < activation_time:
		# Character is in the "future" -> Hide it
		char_fx.color.a = 0
	else:
		# Character is "past" -> Show it
		# (We leave color as-is, defaulting to visible)
		pass
		
	return true
