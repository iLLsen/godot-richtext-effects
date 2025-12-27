# rte_loading.gd
# Effect: [loading]
# Description: Recreates the "Loading Data" CUSTOMSTYLE text animation.
# Characters float up, fade out, and reappear.
#
# CUSTOMSTYLE Logic:
# - Cycle: 2.0 seconds, infinite.
# - Stagger: 1st char 0.9s delay, +0.1s per subsequent char.
# - Keyframes:
#   0-20%: Rise to -60% height (Opacity 1)
#   20-40%: Rise to -100% height (Opacity 1->0)
#   40-80%: Hidden (Opacity 0)
#   80-100%: Fade In at origin (Opacity 0->1)
#
# Parameters:
# - height: The reference height for 100% movement in pixels (default 40.0).
# - speed: Cycle speed multiplier (default 1.0).

@tool
class_name RichTextFxLoading
extends RichTextEffect

var bbcode: String = "loading"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var height: float = char_fx.env.get("height", 40.0)
	var speed: float = char_fx.env.get("speed", 1.0)
	
	# CUSTOMSTYLE Delay: 0.9s base + 0.1s per index.
	# We subtract delay from elapsed time so the animation starts "later" for higher indices.
	var delay: float = 0.9 + (char_fx.relative_index * 0.1)
	var time: float = (char_fx.elapsed_time * speed) - delay
	
	# Normalize to 0.0 - 1.0 loop (Cycle is 2.0 seconds)
	# Adding arbitrary offset to handle negative start times smoothly
	var t: float = fmod(time + 1000.0, 2.0) / 2.0
	
	var offset_y: float = 0.0
	var opacity: float = 1.0
	
	if t < 0.2:
		# 0% - 20%: Rise to 60% height
		# Map t (0.0-0.2) to (0.0-1.0)
		var step: float = t / 0.2
		# Ease-in-out approximation or linear
		offset_y = lerpf(0.0, -height * 0.6, step)
		opacity = 1.0
		
	elif t < 0.4:
		# 20% - 40%: Rise to 100% height, Fade Out
		# Map t (0.2-0.4) to (0.0-1.0)
		var step: float = (t - 0.2) / 0.2
		offset_y = lerpf(-height * 0.6, -height, step)
		opacity = lerpf(1.0, 0.0, step)
		
	elif t < 0.8:
		# 40% - 80%: Hidden
		opacity = 0.0
		offset_y = 0.0 # Reset position for reappearance
		
	else:
		# 80% - 100%: Fade In at Origin
		# Map t (0.8-1.0) to (0.0-1.0)
		var step: float = (t - 0.8) / 0.2
		opacity = lerpf(0.0, 1.0, step)
		offset_y = 0.0
		
	char_fx.offset.y += offset_y
	char_fx.color.a = opacity
	
	return true
