# rte_cursed.gd
# Effect: [cursed]
# Description: Jagged jittering and red tinting. Looks unstable.
# Parameters:
# - level: Chaos level (default 10)
# - freq: Jitter speed (default 20)

@tool
class_name RichTextCursed
extends RichTextEffect

var bbcode: String = "cursed"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var level: float = char_fx.env.get("level", 3.0)
	var freq: float = char_fx.env.get("freq", 20.0)
	
	var time: float = char_fx.elapsed_time
	# FIXED: Changed absolute_index to relative_index for Godot 4.0/4.1 compatibility
	var idx: int = char_fx.relative_index
	
	# Create pseudo-random deterministic noise based on time steps
	# We floor the time to create "steps" instead of smooth motion
	var time_step: float = floor(time * freq)
	
	# Random X/Y offsets
	var rand_x: float = sin(float(idx) * 55.1 + time_step * 13.3)
	var rand_y: float = cos(float(idx) * 32.2 + time_step * 21.9)
	
	char_fx.offset.x += rand_x * level
	char_fx.offset.y += rand_y * level
	
	# Random Red Tinting
	var rand_col: float = sin(float(idx) * 11.1 + time_step)
	if rand_col > 0.5:
		char_fx.color = Color.RED.lerp(Color.BLACK, 0.3)
		
	return true
