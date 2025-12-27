# rte_scroll.gd
# Effect: [scroll]
# Description: Replicates a CUSTOMSTYLE vertical scroll animation (marquee).
# Useful for "Slot Machine" or "Greeting List" effects.
#
# Parameters:
# - speed: Scroll speed in pixels per second (default 50.0).
# - height: Total height of the scroll loop in pixels (default 200.0).
#           Should match (LineHeight * LineCount).
# - pause: If > 0, creates a "step" effect where it pauses at intervals. 
#          (CUSTOMSTYLE 'move' is continuous, but step is often desired).

@tool
class_name RichTextScroll
extends RichTextEffect

var bbcode: String = "scroll"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var speed: float = char_fx.env.get("speed", 50.0)
	var loop_height: float = char_fx.env.get("height", 200.0)
	
	# Calculate global scroll offset based on time
	var time: float = char_fx.elapsed_time
	var total_scroll: float = time * speed
	
	# Create the loop
	var mod_scroll: float = fmod(total_scroll, loop_height)
	
	# Apply negative Y offset to move text UP
	char_fx.offset.y -= mod_scroll
	
	# --- Visibility Logic ---
	# Since we can't easily mask via shader here without layout Y-coords,
	# we rely on the RichTextLabel's 'clip_contents' property or a parent Container 
	# to hide the text as it scrolls out of the viewable area.
	
	# However, to prevent the text from "snapping" visually when the loop resets,
	# usually one duplicates the list: Item1\nItem2\nItem3\nItem1...
	# This effect simply handles the translation.
	
	return true
