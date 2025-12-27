# rte_disappear.gd
# Effect: [disappear]
# Description: Recreates the "Disappear" CUSTOMSTYLE animation.
# Characters ghost upwards, skewing left or right, and fading out.
#
# CUSTOMSTYLE Logic:
# - Cycle: 3.0 seconds, infinite.
# - Keyframes:
#   0%: Origin, Opacity 1.
#   50%: TranslateY -200%, Skew +/- 50deg, Opacity 0.
#   100%: Origin, Opacity 1.
# - Direction: Mixed Left/Right skew (randomized by index).
#
# Parameters:
# - height: Vertical travel distance in pixels (default 50.0).
# - speed: Cycle speed multiplier (default 1.0).

@tool
class_name RichTextFxDisappear
extends RichTextEffect

var bbcode: String = "disappear"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var height: float = char_fx.env.get("height", 30.0)
	var speed: float = char_fx.env.get("speed", 1.5)
	
	# CUSTOMSTYLE Delay approximation: ~0.3s per character
	# We subtract delay to stagger the start times
	var delay: float = char_fx.relative_index * 0.3
	var time: float = (char_fx.elapsed_time * speed) - delay
	
	# Cycle is 3.0 seconds
	# Normalize to 0.0 - 1.0
	var t: float = fmod(time + 1000.0, 3.0) / 3.0
	
	# Determine direction (Left vs Right skew) based on pseudo-random index hash
	# sin(index) gives deterministic +/- values
	var skew_dir: float = sign(sin(float(char_fx.relative_index) * 12.34))
	if skew_dir == 0: skew_dir = 1.0
	
	# Animation Loop (Ping-Pong 0 -> 1 -> 0)
	# We only care about the 0% -> 50% part for the "Disappearing" motion.
	# The CUSTOMSTYLE goes 0% (visible) -> 50% (gone) -> 100% (visible).
	# t goes 0.0 -> 1.0. 
	# We map 0.0-0.5 to "Going Up" and 0.5-1.0 to "Coming Down".
	
	var progress: float = 0.0
	
	if t < 0.5:
		# Going Up (0.0 to 1.0)
		progress = t / 0.5
	else:
		# Coming Down (1.0 to 0.0)
		progress = 1.0 - ((t - 0.5) / 0.5)
		
	# Apply Transforms based on progress (Ease In/Out)
	# Ideally use smoothstep for nicer motion
	var eased_p: float = smoothstep(0.0, 1.0, progress)
	
	# 1. Translate Y (Upwards is negative)
	char_fx.offset.y -= eased_p * height
	
	# 2. Opacity (Fades out as it goes up)
	char_fx.color.a = 1.0 - eased_p
	
	# 3. Skew (Shear X)
	# CUSTOMSTYLE skew(50deg) ~= 1.19 radians transform
	# We skew proportional to height progress
	var skew_amount: float = 1.2 * eased_p * skew_dir
	char_fx.transform.x.y = skew_amount
	
	# Note: RichTextEffect doesn't support Blur (text-shadow), so we rely on Opacity.
	
	return true
