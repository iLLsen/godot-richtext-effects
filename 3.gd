# rte_rare.gd
# Effect: [rare]
# Description: Occasional sparkles on random characters.
# Default Color: WoW Blue (#0070dd)
# Parameters:
# - freq: How often sparkles occur (default 1.0)
# - color: Override base color (default #0070dd)
# - sparkle_color: Color of the flash (default White)

@tool
class_name RichTextRare
extends RichTextEffect

var bbcode: String = "rare"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var freq: float = char_fx.env.get("freq", 1.0)
	var flash_color: Color = char_fx.env.get("sparkle_color", Color.WHITE)
	
	# Apply WoW Rare Color (Blue) unless overridden
	var base_color: Color = char_fx.env.get("color", Color("0070dd"))
	char_fx.color = base_color
	
	var time: float = char_fx.elapsed_time
	# FIXED: Use range.x for Godot 4.5+ compatibility
	var idx: int = char_fx.range.x
	
	# Pseudo-random generator for this character's sparkle timing
	# We use a large prime number multiplier to scatter the phases
	var phase: float = fmod(float(idx) * 12.9898, 10.0) 
	
	# Calculate a sharp sine peak for the flash
	var cycle: float = time * freq + phase
	var flash: float = sin(cycle)
	
	# Only apply if we are at the very peak of the sine wave (creating a brief flash)
	if flash > 0.9:
		# Remap 0.9-1.0 to 0.0-1.0 for intensity
		var intensity: float = (flash - 0.9) * 10.0
		char_fx.color = char_fx.color.lerp(flash_color, intensity)
		
		# Slight scale up during sparkle
		var scale_mod: float = 1.0 + (intensity * 0.2)
		char_fx.transform = char_fx.transform.scaled_local(Vector2(scale_mod, scale_mod))
		
	return true
