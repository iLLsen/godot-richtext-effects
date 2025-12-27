# rte_legendary.gd
# Effect: [legendary]
# Description: A bright sheen wipes across the text periodically.
# Default Color: WoW Orange (#ff8000)
# Parameters:
# - speed: Speed of the wipe (default 3.0)
# - width: Width of the shine band (default 10.0)
# - color: Override base color (default #ff8000)
# - shine_color: Color of the shine (default pale yellow/gold)

@tool
class_name RichTextLegendary
extends RichTextEffect

var bbcode: String = "legendary"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var speed: float = char_fx.env.get("speed", 3.0)
	var width: float = char_fx.env.get("width", 10.0)
	var shine_color: Color = char_fx.env.get("shine_color", Color(1.0, 1.0, 0.8)) # Pale Gold
	
	# Apply WoW Legendary Color (Orange) unless overridden
	var base_color: Color = char_fx.env.get("color", Color("ff8000"))
	char_fx.color = base_color
	
	var time: float = char_fx.elapsed_time
	# FIXED: Use range.x for Godot 4.5+ compatibility
	var idx: float = float(char_fx.range.x)
	
	# Logic Fixed: Use a relative offset to support any absolute index position.
	# The gap between shines is set arbitrarily to 80.0 units to ensure separation.
	var gap_size: float = 80.0
	var move_offset: float = time * speed * 20.0
	
	# We calculate the position of the wave relative to this specific character index
	# fmod creates the repeating pattern. We add gap_size to handle negative results from fmod logic.
	var phase: float = fmod(idx - move_offset, gap_size)
	if phase < 0.0:
		phase += gap_size
		
	# Check distance to the "start" of the phase loop (the shine band)
	# Center the shine at 0 in this new phase space
	var dist: float = phase
	
	# If the character is within the 'width' of the start of the loop
	if dist < width:
		# Calculate intensity (1.0 at start, 0.0 at width edge)
		var intensity: float = 1.0 - (dist / width)
		intensity = pow(intensity, 2.0) # Smooth falloff
		
		# Apply bright color addition
		char_fx.color = char_fx.color.lerp(shine_color, intensity)
		
		# Slight lift
		char_fx.offset.y -= intensity * 2.0
		
	return true
