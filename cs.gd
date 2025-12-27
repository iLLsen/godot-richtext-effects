# rte_css.gd
# Effect: [css]
# Description: Simulates the 8 provided CUSTOMSTYLE styles using RichTextEffect properties.
#
# IMPROVED: Uses a "State Loop" instead of a sine wave to create distinct 
# "Hover In", "Hold", and "Hover Out" phases, mimicking CUSTOMSTYLE transition-delay.
#
# Parameters:
# - style: v1..v8 (CUSTOMSTYLE class equivalents)
# - speed: Speed of the transition (default 1.0)

@tool
class_name RichTextFxCUSTOMSTYLE
extends RichTextEffect

var bbcode: String = "css"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var style: String = char_fx.env.get("style", "v1")
	var speed: float = char_fx.env.get("speed", 1.0)
	
	# --- Timing Logic: "Simulated Hover Loop" ---
	# Cycle Duration: ~4.0 seconds (at speed 1.0)
	# 0.0 - 1.5: Idle
	# 1.5 - 2.0: Transition In
	# 2.0 - 3.5: Active (Hold)
	# 3.5 - 4.0: Transition Out
	
	var cycle_len: float = 4.0 / speed
	var time_in_cycle: float = fmod(char_fx.elapsed_time, cycle_len)
	var t: float = 0.0
	
	# Create a sharp "Ease In-Out" curve based on the timeline
	if time_in_cycle < 1.5:
		t = 0.0 # Idle
	elif time_in_cycle < 2.0:
		# Transition 0 -> 1
		t = smoothstep(0.0, 1.0, (time_in_cycle - 1.5) / 0.5)
	elif time_in_cycle < 3.5:
		t = 1.0 # Active
	else:
		# Transition 1 -> 0
		t = smoothstep(1.0, 0.0, (time_in_cycle - 3.5) / 0.5)

	# --- Style Implementations ---
	match style:
		"v1": # Underline (CUSTOMSTYLE: background-size 0% -> 100%)
			# We simulate the "Left-to-Right" growth by offsetting 't' based on character index.
			# This creates a "wipe" effect for the color change.
			var wipe_t = clamp(t * 1.5 - (char_fx.relative_index * 0.05), 0.0, 1.0)
			char_fx.color = char_fx.color.lerp(Color.RED, wipe_t)
			
		"v2": # Highlight (CUSTOMSTYLE: yellow bg 0% -> 100%)
			# Assuming text is on [bgcolor=yellow], we snap text color to BLACK for contrast.
			# Uses the same "Wipe" logic to match the background fill direction.
			var wipe_t = clamp(t * 1.5 - (char_fx.relative_index * 0.05), 0.0, 1.0)
			char_fx.color = char_fx.color.lerp(Color.BLACK, wipe_t)
			
		"v3": # Spoiler (CUSTOMSTYLE: transparent -> black)
			# Replaced Noise Dissolve with Linear Wipe Reveal.
			# Matches CUSTOMSTYLE 'background-size' wiping away to reveal text.
			var wipe_t = clamp(t * 1.5 - (char_fx.relative_index * 0.05), 0.0, 1.0)
			# Idle: Alpha 0 (Redacted/Invisible). Active: Alpha 1 (Visible).
			char_fx.color.a = wipe_t
			
		"v4": # Dashes (CUSTOMSTYLE: purple dash) -> Pulse Purple + slight lift
			char_fx.color = char_fx.color.lerp(Color.REBECCA_PURPLE, t)
			char_fx.offset.y -= t * 2.0 # Slight lift to emphasize active state
			
		"v5": # Deleted v1 -> Red + Violent Shake
			char_fx.color = char_fx.color.lerp(Color.RED, t)
			if t > 0.1:
				var shake = t * 2.0
				char_fx.offset.x += randf_range(-shake, shake)
				char_fx.offset.y += randf_range(-shake, shake)
				
		"v6": # Italic -> Skew + Offset
			var skew = lerp(0.0, 0.25, t)
			# Apply skew to transform (Y-axis shearing)
			char_fx.transform.x.y = skew
			char_fx.color = char_fx.color.lerp(Color(0.2, 0.2, 0.2), t) # Dim slightly
			
		"v7": # Crazy -> Rainbow Jitter
			if t > 0.1:
				var hue = fmod(char_fx.elapsed_time * 2.0 + (char_fx.relative_index * 0.1), 1.0)
				char_fx.color = Color.from_hsv(hue, 0.8, 1.0)
				char_fx.offset.y += sin(char_fx.elapsed_time * 20.0) * 1.0
				
		"v8": # Swipe -> Gradient Pass
			# Simulates a bright band passing through the text
			var band_pos = (char_fx.elapsed_time * 3.0) - (char_fx.relative_index * 0.3)
			var band = sin(band_pos) # -1 to 1
			# Only apply when 'Hover' (t) is active
			if t > 0.1:
				var grad_color = Color.YELLOW.lerp(Color("#9ae6b4"), (band + 1.0) / 2.0)
				char_fx.color = char_fx.color.lerp(grad_color, t)

	return true
