# rte_marquee.gd
# Effect: [marquee]
# Description: Scrolls text horizontally to simulate a ticker/marquee.
# Recreates the "@keyframes move" CUSTOMSTYLE animation.
#
# CUSTOMSTYLE Logic: "left: 800px" to "left: -4800px" over 20s.
#
# Parameters:
# - start: Starting X offset in pixels (default 800.0).
# - end: Ending X offset in pixels (default -4800.0).
# - speed: Movement speed in pixels per second (default 280.0).
#          (Calculated from CUSTOMSTYLE: 5600px / 20s = 280).

@tool
class_name RichTextFxMarquee
extends RichTextEffect

var bbcode: String = "marquee"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	# Get parameters with CUSTOMSTYLE defaults
	var start: float = char_fx.env.get("start", 800.0)
	var end: float = char_fx.env.get("end", -4800.0)
	var speed: float = char_fx.env.get("speed", 280.0)
	
	# Calculate total travel distance
	var distance: float = start - end # e.g. 800 - (-4800) = 5600
	
	# Avoid division by zero
	if distance == 0:
		return true
		
	# Calculate current position in the loop
	# We use fmod to loop the time factor based on the distance/speed relationship
	var current_travel = fmod(char_fx.elapsed_time * speed, distance)
	
	# Apply offset
	# Moves from 'start' towards 'end'
	char_fx.offset.x += start - current_travel
	
	return true
