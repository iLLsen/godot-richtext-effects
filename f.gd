# rte_noise.gd
# Effect: [jitter]
# Description: Applies a random jitter/noise effect to the text.
# Useful for "glitch" text, scary dialogue, or unstable systems.
#
# Parameters:
# - level: The intensity of the jitter in pixels (default 5.0).
# - freq: Speed of the noise updates (default 0.0 = every frame/chaotic).
#         If > 0, it uses a sine-wave based pseudo-noise for smoother movement.

@tool
class_name RichTextFxNoise
extends RichTextEffect

var bbcode: String = "jitter"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	# Get parameters
	var level: float = char_fx.env.get("level", 5.0)
	var freq: float = char_fx.env.get("freq", 0.0)
	
	var offset: Vector2 = Vector2.ZERO
	
	if freq > 0.0:
		# Smoother, "wandering" noise using Sine waves
		var t: float = char_fx.elapsed_time * freq
		var idx: float = float(char_fx.relative_index) * 45.0 # Arbitrary large step
		
		# Combine sines to create pseudo-random movement
		offset.x = sin(t + idx) * level
		offset.y = cos(t * 0.8 + idx * 1.2) * level
	else:
		# Chaotic white noise (jitter every frame)
		# We use randf_range for per-frame randomness.
		# Note: This is very fast and jittery.
		offset.x = randf_range(-level, level)
		offset.y = randf_range(-level, level)
	
	char_fx.offset += offset
	return true
