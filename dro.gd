@tool
class_name DropInEffect
extends RichTextEffect

# syntax: [drop_in height=500.0 overshoot=12.0 duration=0.15 interval=0.2 repeat=yes]Content[/drop_in]

# The tag name used in the BBCode.
var bbcode: String = "drop_in"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	# CUSTOMSTYLE: translate3d(0, -60vh, 0) -> translate3d(0, 1.5vh, 0) -> 0
	# Godot Y-axis: Negative is Up, Positive is Down.
	
	# Parameters matching CUSTOMSTYLE variables:
	# height: Approx 60vh. Defaulting to 500px.
	# overshoot: Approx 1.5vh. Defaulting to 12px.
	# duration: CUSTOMSTYLE animation-duration .15s.
	# interval: CUSTOMSTYLE animation-delay $i * 0.2s.
	
	var height: float = char_fx.env.get("height", 500.0)
	var overshoot: float = char_fx.env.get("overshoot", 12.0)
	var duration: float = char_fx.env.get("duration", 0.15)
	var interval: float = char_fx.env.get("interval", 0.2)
	
	# Check for repeat parameter. Supports "yes", "true", "1".
	var repeat_raw = char_fx.env.get("repeat", "no")
	var repeat: bool = str(repeat_raw).to_lower() in ["yes", "true", "1"]
	
	# Calculate delay based on character index (CUSTOMSTYLE: $i * 0.2s)
	# relative_index is 0-based index of char in the effect block.
	var delay: float = char_fx.relative_index * interval
	
	# Current time relative to this specific character
	var t_abs: float = char_fx.elapsed_time - delay
	
	# If we haven't started yet (delay phase)
	if t_abs < 0.0:
		char_fx.color.a = 0.0
		char_fx.offset.y -= height
		return true

	# Handle Repeat Logic
	# If repeat is enabled and the specific character animation has finished, loop it.
	if repeat and t_abs > duration:
		t_abs = fmod(t_abs, duration)
		
	# Normalized progress (0.0 to 1.0)
	var t: float = t_abs / duration
	
	if t >= 1.0:
		# Animation Finished
		char_fx.offset.y = 0.0
		char_fx.color.a = 1.0
	elif t < 0.75:
		# 0% to 75%: Drop from -height to +overshoot
		# CUSTOMSTYLE: 0% { opacity: 0; transform: -60vh }
		# CUSTOMSTYLE: 75% { opacity: 1; transform: 1.5vh }
		
		# Normalize t for this segment (0.0 to 1.0 represents 0% to 75%)
		var st: float = t / 0.75
		
		# Linear interpolation for position
		char_fx.offset.y = lerpf(-height, overshoot, st)
		
		# Linear interpolation for opacity
		char_fx.color.a = lerpf(0.0, 1.0, st)
		
	else:
		# 75% to 100%: Settle from +overshoot to 0
		# CUSTOMSTYLE: 75% { ... transform: 1.5vh }
		# CUSTOMSTYLE: 100% { ... transform: 0 }
		
		# Normalize t for this segment (0.0 to 1.0 represents 75% to 100%)
		var st: float = (t - 0.75) / 0.25
		
		char_fx.offset.y = lerpf(overshoot, 0.0, st)
		char_fx.color.a = 1.0
		
	return true
