# rte_shake_css.gd
# Effect: [cshake]
# Description: Recreates the specific 11-step CUSTOMSTYLE "Shake" animation.
# A jittery, rotational shake often used for error states or impact.
#
# CUSTOMSTYLE Logic:
# - Cycle: 0.5 seconds.
# - Keyframes (Translate X, Translate Y, Rotate Deg):
#   0%:   (1, -2, -1)
#   10%:  (-1, 2, -1)
#   20%:  (1, 2, 0)
#   30%:  (3, 2, 0)
#   40%:  (1, -1, 1)
#   50%:  (-1, -2, -1)
#   60%:  (-3, 1, 0)
#   70%:  (3, 1, -1)
#   80%:  (-1, -1, 1)
#   90%:  (-3, 0, 1)
#   100%: (1, 1, 0)
#
# Parameters:
# - speed: Speed multiplier (default 1.0).
# - px: Pivot X offset for rotation (default 0.0).
# - py: Pivot Y offset for rotation (default 0.0).
#
# Usage Example:
# [cshake speed=1.0 px=0.0 py=0.0]WRONG PASSWORD[/cshake]

@tool
class_name RichTextFxCUSTOMSTYLEShake
extends RichTextEffect

var bbcode: String = "cshake"

# Keyframes: [Vector2(x, y), float(rotation_deg)]
# Times are 0.0, 0.1, 0.2 ... 1.0 (normalized)
const KEYFRAMES = [
	{ "pos": Vector2(1, -2),  "rot": -1.0 }, # 0%
	{ "pos": Vector2(-1, 2),  "rot": -1.0 }, # 10%
	{ "pos": Vector2(1, 2),   "rot": 0.0  }, # 20%
	{ "pos": Vector2(3, 2),   "rot": 0.0  }, # 30%
	{ "pos": Vector2(1, -1),  "rot": 1.0  }, # 40%
	{ "pos": Vector2(-1, -2), "rot": -1.0 }, # 50%
	{ "pos": Vector2(-3, 1),  "rot": 0.0  }, # 60%
	{ "pos": Vector2(3, 1),   "rot": -1.0 }, # 70%
	{ "pos": Vector2(-1, -1), "rot": 1.0  }, # 80%
	{ "pos": Vector2(-3, 0),  "rot": 1.0  }, # 90%
	{ "pos": Vector2(1, 1),   "rot": 0.0  }  # 100%
]

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var speed: float = char_fx.env.get("speed", 1.0)
	var px: float = char_fx.env.get("px", 0.0)
	var py: float = char_fx.env.get("py", 0.0)
	var pivot := Vector2(px, py)
	
	# Cycle length is 0.5s in CUSTOMSTYLE
	var cycle_len: float = 0.5
	# Avoid divide by zero if speed is 0
	if speed > 0.0:
		cycle_len = 0.5 / speed
	
	var t_abs: float = fmod(char_fx.elapsed_time, cycle_len)
	# Normalize to 0.0 - 1.0
	var t: float = t_abs / cycle_len
	
	# Determine current keyframe index (0 to 10)
	# 11 Keyframes distributed evenly at 10% intervals (0.0, 0.1, ... 1.0)
	# We multiply t by 10 to find the slot
	var slot: float = t * 10.0
	var idx: int = int(slot)
	var next_idx: int = idx + 1
	
	# Interpolation factor between frames
	var p: float = slot - float(idx)
	
	# Clamp indices
	if idx >= KEYFRAMES.size(): idx = KEYFRAMES.size() - 1
	if next_idx >= KEYFRAMES.size(): next_idx = 0 # Loop back to start logic? 
	# CUSTOMSTYLE shake usually loops 0->100% then resets. 
	# The list has 11 entries (0-10). The last gap is 100% -> 0% wrap? 
	# CUSTOMSTYLE animation-iteration-count: infinite implies strict wrap.
	if next_idx >= KEYFRAMES.size(): next_idx = 0
	
	var k1 = KEYFRAMES[idx]
	var k2 = KEYFRAMES[next_idx]
	
	# Lerp values
	var final_pos: Vector2 = k1["pos"].lerp(k2["pos"], p)
	var final_rot: float = lerpf(k1["rot"], k2["rot"], p)
	
	# Apply Transforms
	char_fx.offset += final_pos
	
	if final_rot != 0.0:
		var rot_rad: float = deg_to_rad(final_rot)
		if px != 0.0 or py != 0.0:
			char_fx.transform = char_fx.transform.translated(pivot).rotated(rot_rad).translated(-pivot)
		else:
			char_fx.transform = char_fx.transform.rotated(rot_rad)
			
	return true
