# rte_drop.gd
# Effect: [drop]
# Description: Recreates the "Dropping Texts" CUSTOMSTYLE animation.
# Words rotate in, hold, then either drop down or zoom into the screen.
#
# CUSTOMSTYLE Logic:
# - Cycle: 5.0 seconds total.
# - Animation 'roll' (Standard):
#   0-5%: Enter (Rotate -25deg -> 0, OffsetX -30 -> 0, Opacity 0->1)
#   5-20%: Hold
#   20-27%: Exit (Drop down, OffsetX +20, Opacity 0.5, Scale 0)
# - Animation 'roll2' (Zoom):
#   0-5%: Enter (Same)
#   5-30%: Hold
#   30-37%: Exit (Scale huge, Offset negative, Opacity 0)
#
# Parameters:
# - i: Index of the word (0, 1, 2, 3...). Determines delay (1s steps).
# - type: 0 = Standard Roll, 1 = Zoom Roll (roll2). Default 0.
# - speed: Global speed multiplier (default 1.0).
# - px: Pivot X offset (default 0.0). Set to approx width/2 for center rotation.
# - py: Pivot Y offset (default 0.0). Set to approx -height/2 for center rotation.

@tool
class_name RichTextFxDrop
extends RichTextEffect

var bbcode: String = "drop"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var idx: int = char_fx.env.get("i", 0)
	var anim_type: int = char_fx.env.get("type", 0)
	var speed: float = char_fx.env.get("speed", 1.0)
	
	# Pivot for rotation/scaling.
	# Defaulting to (0,0) ensures characters don't "stack" or drift if the font size mismatch is large.
	# To rotate around center, set these manually in BBCode (e.g. px=10 py=-10 for a 20px font).
	var px: float = char_fx.env.get("px", 0.0)
	var py: float = char_fx.env.get("py", 26.0)
	var pivot := Vector2(px, py)
	
	# Global cycle time (5 seconds in CUSTOMSTYLE)
	var cycle_len: float = 5.0
	var time: float = fmod(char_fx.elapsed_time * speed, cycle_len)
	
	# Start time for this specific word
	# CUSTOMSTYLE delays: 0s, 1s, 2s, 3s...
	var start_t: float = float(idx) * 1.0
	
	# Calculate local time relative to this word's start
	var t: float = time - start_t
	
	# Default state: Hidden
	char_fx.color.a = 0.0
	char_fx.transform = char_fx.transform.translated(Vector2(0,-idx*py))
	#char_fx.transform = Transform2D() # Reset
	
	# Check if we are inside the active window for this word
	# Max duration for 'roll' is ~27% of 5s = 1.35s
	# Max duration for 'roll2' is ~37% of 5s = 1.85s
	
	if t < 0.0:
		return true # Not started yet
		
	# --- Animation Logic ---
	
	# Common Entry Phase: 0% to 5% of cycle (0.0s to 0.25s)
	# CUSTOMSTYLE: 0% -> 3% (opacity/rot) -> 5% (margin/scale reset)
	if t < 0.25:
		var p: float = t / 0.25 # 0.0 to 1.0
		char_fx.color.a = p
		
		# Rotate -25deg to 0
		var angle: float = lerpf(deg_to_rad(-25.0), 0.0, p)
		var s: float = p # Scale 0 to 1
		
		# Transform: Translate Pivot -> Rotate -> Scale -> Translate Back
		if px != 0.0 or py != 0.0:
			char_fx.transform = char_fx.transform.translated(pivot)
			char_fx.transform = char_fx.transform.rotated(angle)
			char_fx.transform = char_fx.transform.scaled(Vector2(s, s))
			char_fx.transform = char_fx.transform.translated(-pivot)
		else:
			# Simple transform (Top-Left pivot) - Safer for layout
			char_fx.transform = char_fx.transform.rotated(angle)
			char_fx.transform = char_fx.transform.scaled(Vector2(s, s))
		
		# Margin Left: -30 to 0
		char_fx.offset.x = lerpf(-30.0, 0.0, p)
		
		return true

	# Hold Phase & Exit Phase differ by type
	
	if anim_type == 0: # Standard 'roll'
		# Hold: 5% (0.25s) -> 20% (1.0s)
		if t < 1.0:
			char_fx.color.a = 1.0
			# Static at origin
			return true
			
		# Exit: 20% (1.0s) -> 27% (1.35s)
		if t < 1.35:
			var p: float = (t - 1.0) / 0.35 # 0.0 to 1.0
			
			# Opacity: 1 -> 0.5 -> 0 (Simplified linear 1->0)
			char_fx.color.a = 1.0 - p
			
			# Margin Left: 0 -> 20
			char_fx.offset.x = lerpf(0.0, 20.0, p)
			
			# Margin Top: 0 -> 100
			char_fx.offset.y = lerpf(0.0, 100.0, p)
			
			# Font Size: inherit -> 0 (Scale 1 -> 0)
			var s: float = 1.0 - p
			
			# Transform
			if px != 0.0 or py != 0.0:
				char_fx.transform = char_fx.transform.translated(pivot)
				char_fx.transform = char_fx.transform.scaled(Vector2(s, s))
				char_fx.transform = char_fx.transform.translated(-pivot)
			else:
				char_fx.transform = char_fx.transform.scaled(Vector2(s, s))
				
			return true
			
	else: # Zoom 'roll2'
		# Hold: 5% (0.25s) -> 30% (1.5s)
		if t < 1.5:
			char_fx.color.a = 1.0
			return true
			
		# Exit: 30% (1.5s) -> 37% (1.85s)
		if t < 1.85:
			var p: float = (t - 1.5) / 0.35
			
			# Opacity: 1 -> 0
			char_fx.color.a = 1.0 - p
			
			# Margin Left: 0 -> -200 (Reduced to avoid extreme movement)
			char_fx.offset.x = lerpf(0.0, -200.0, p)
			
			# Margin Top: 0 -> -200 (Reduced)
			char_fx.offset.y = lerpf(0.0, -200.0, p)
			
			# Font Size: inherit -> 1500px (Huge scale)
			# Scale 1 -> 3.0 (Capped to prevent visual mess)
			var s: float = lerpf(1.0, 3.0, p)
			
			# Transform
			if px != 0.0 or py != 0.0:
				char_fx.transform = char_fx.transform.translated(pivot)
				char_fx.transform = char_fx.transform.scaled(Vector2(s, s))
				char_fx.transform = char_fx.transform.translated(-pivot)
			else:
				char_fx.transform = char_fx.transform.scaled(Vector2(s, s))
				
			return true

	return true
