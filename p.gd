# rte_press.gd
# Effect: [press]
# Description: Simulates the specific "CUSTOMSTYLE Key Press" animation.
# Mimics 8 independent tracks with different durations and trigger times.
#
# Parameters:
# - scale: Vertical offset amount in pixels (default 10.0).

@tool
class_name RichTextFxPress
extends RichTextEffect

var bbcode: String = "press"

# CUSTOMSTYLE Replication Data: [Duration (s), Peak Percentage (0.0-1.0)]
# Based on the user's provided CUSTOMSTYLE keyframes.
const PRESETS = [
	{ "dur": 2.0, "peak": 0.35 },  # nth-child(1): 2s, 30-40%
	{ "dur": 3.0, "peak": 0.75 },  # nth-child(2): 3s, 70-80%
	{ "dur": 4.0, "peak": 0.35 },  # nth-child(3): 4s, 30-40%
	{ "dur": 2.5, "peak": 0.45 },  # nth-child(4): 2.5s, 40-50%
	{ "dur": 2.5, "peak": 0.25 },  # nth-child(5): 2.5s, 20-30%
	{ "dur": 3.5, "peak": 0.65 },  # nth-child(6): 3.5s, 60-70%
	{ "dur": 2.2, "peak": 0.15 },  # nth-child(7): 2.2s, 10-20%
	{ "dur": 3.2, "peak": 0.40 }   # nth-child(8): 3.2s, 35-45%
]

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var scale_y: float = char_fx.env.get("scale", 10.0)
	
	# Map character index to one of the 8 CUSTOMSTYLE presets
	var preset_idx: int = char_fx.relative_index % PRESETS.size()
	var p: Dictionary = PRESETS[preset_idx]
	
	var duration: float = p["dur"]
	var peak: float = p["peak"]
	
	# Normalized time in the cycle (0.0 to 1.0)
	var t: float = fmod(char_fx.elapsed_time, duration) / duration
	
	# The CUSTOMSTYLE animation window is generally 10% of the total duration 
	# (e.g., 30% to 40% is a 0.1 spread).
	# We calculate a triangular spike centered at 'peak'.
	
	var half_width: float = 0.05 # 5% either side of peak
	var dist: float = abs(t - peak)
	
	var offset_y: float = 0.0
	
	if dist < half_width:
		# Map distance (0 to 0.05) to Intensity (1.0 to 0.0)
		var intensity: float = 1.0 - (dist / half_width)
		# Apply smoothstep for a nicer "press" curve, or linear for raw CUSTOMSTYLE feel.
		# CUSTOMSTYLE 'ease' is roughly cubic, but linear is safer for glitch-free loops.
		offset_y = intensity * scale_y
	
	char_fx.offset.y += offset_y
	
	return true
