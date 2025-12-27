# rte_flip.gd
# Effect: [flip]
# Description: Recreates the "Waviy Flip" CUSTOMSTYLE animation.
# Simulates a 3D Y-axis rotation using 2D scaling.
#
# CUSTOMSTYLE Logic:
# - Cycle: 2.0 seconds, infinite.
# - Stagger: 0.2s per character index.
# - Keyframes:
#   0% to 80%: Hold at 360deg (Visually static/flat).
#   80% to 100%: Rotate from 360deg to 0deg (Fast spin).
#
# Parameters:
# - speed: Cycle speed multiplier (default 1.0).

@tool
class_name RichTextFxFlip
extends RichTextEffect

var bbcode: String = "flip"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var speed: float = char_fx.env.get("speed", 1.0)
	
	# CUSTOMSTYLE Delay: 0.2s per index.
	# We subtract delay so higher indices are "behind" in the timeline.
	var delay: float = char_fx.relative_index * 0.2
	var time: float = (char_fx.elapsed_time * speed) - delay
	
	# Cycle is 2.0 seconds
	# Add offset to ensure positive time start
	var t: float = fmod(time + 1000.0, 2.0) / 2.0 # Normalized 0.0 - 1.0
	
	var angle_rad: float = 0.0
	
	# Logic:
	# 0.0 - 0.8: Hold at 360 degrees (2 * PI)
	# 0.8 - 1.0: Interpolate 360 -> 0 degrees
	if t < 0.8:
		angle_rad = TAU # 360 degrees
	else:
		# Map t (0.8-1.0) to (0.0-1.0)
		var step: float = (t - 0.8) / 0.2
		# Interpolate 360 (TAU) down to 0
		angle_rad = lerpf(TAU, 0.0, step)
	
	# Simulate Y-Rotation by scaling X width based on Cosine of angle.
	# cos(0) = 1 (Full width)
	# cos(PI/2) = 0 (Invisible slice)
	# cos(PI) = -1 (Mirrored back)
	char_fx.transform.x.x = cos(angle_rad)
	
	# Optional: Offset pivot to center of character to flip in place
	# However, RichTextEffect transform pivot is usually bottom-left or baseline.
	# To flip around center, we need to offset position based on width change.
	# Since we don't know the exact pixel width of the glyph easily in CharFX,
	# we rely on the standard transform behavior which often pivots correctly for monospaced
	# or centered fonts, but might look left-aligned on others.
	# For a pure effect without font metrics, this is the standard approach.
	
	return true
