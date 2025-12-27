# rte_lights.gd
# Effect: [lights]
# Description: Replicates the CUSTOMSTYLE 'lights' color animation. 
# SIMULATION NOTE: Since Godot RichTextLabel cannot render multi-layer colored text-shadows like CUSTOMSTYLE,
# this effect approximates the look by blending the vibrant shadow colors (Pink, Orange, Cyan) 
# into the text face and adding a gentle swaying motion to mimic the shifting light source.
#
# Parameters:
# - freq: Speed multiplier (default 1.0 = 5 seconds loop)
# - span: Spatial offset for the wave (default 10.0). Set to 0 for global sync like CUSTOMSTYLE.

@tool
class_name RichTextLights
extends RichTextEffect

var bbcode: String = "lights"

# -- CUSTOMSTYLE Color Palette (Approximate Mapping) --
# Text Base (Blue-White): HSL(230, 40-100%, 80-95%)
var COL_BASE_DIM: Color = Color.from_hsv(230.0 / 360.0, 0.4, 0.8)
var COL_BASE_BRIGHT: Color = Color.from_hsv(230.0 / 360.0, 0.2, 0.98)

# "Light" Source Colors (from the CUSTOMSTYLE text-shadows)
# Pink: HSLA(320, 100%, 50%)
var LIGHT_PINK: Color = Color.from_hsv(320.0 / 360.0, 0.8, 0.9)
# Orange: HSLA(40, 100%, 60%)
var LIGHT_ORANGE: Color = Color.from_hsv(40.0 / 360.0, 0.8, 0.9)
# Cyan: HSLA(200, 100%, 60%)
var LIGHT_CYAN: Color = Color.from_hsv(200.0 / 360.0, 0.8, 0.9)

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var speed: float = char_fx.env.get("freq", 1.0)
	var span: float = char_fx.env.get("span", 10.0)
	
	# Global time loop (5 seconds base)
	var time: float = char_fx.elapsed_time * speed
	# Use range.x for Godot 4.5+ compatibility
	var idx: float = float(char_fx.range.x)
	
	# Calculate phase (0.0 to 1.0)
	# We add a small spatial offset if 'span' > 0 to make it ripple slightly
	var loop_len: float = 5.0
	var phase_offset: float = (idx * 0.1) if span > 0.0 else 0.0
	var t: float = fmod(time + phase_offset, loop_len) / loop_len
	
	# --- Color Interpolation Logic ---
	# We emulate the CUSTOMSTYLE keyframes by blending the base text color with the "Light" colors
	var target_color: Color
	
	if t < 0.3:
		# 0% -> 30%: Dim Blue -> Bright Pinkish
		# Simulates shadows moving: Pink/Orange glint
		var local_t: float = map_range(t, 0.0, 0.3, 0.0, 1.0)
		# Blend from Base Dim to a mix of Bright + Pink
		var start: Color = COL_BASE_DIM.lerp(LIGHT_ORANGE, 0.1)
		var end: Color = COL_BASE_BRIGHT.lerp(LIGHT_PINK, 0.3)
		target_color = start.lerp(end, local_t)
		
	elif t < 0.4:
		# 30% -> 40%: Bright Pinkish -> Pure Bright Cyan/White
		# Peak brightness
		var local_t: float = map_range(t, 0.3, 0.4, 0.0, 1.0)
		var start: Color = COL_BASE_BRIGHT.lerp(LIGHT_PINK, 0.3)
		var end: Color = COL_BASE_BRIGHT.lerp(LIGHT_CYAN, 0.2)
		target_color = start.lerp(end, local_t)
		
	elif t < 0.7:
		# 40% -> 70%: Bright Cyan -> Dimmer Blue
		var local_t: float = map_range(t, 0.4, 0.7, 0.0, 1.0)
		var start: Color = COL_BASE_BRIGHT.lerp(LIGHT_CYAN, 0.2)
		var end: Color = COL_BASE_BRIGHT.lerp(COL_BASE_DIM, 0.5)
		target_color = start.lerp(end, local_t)
		
	else:
		# 70% -> 100%: Dimmer Blue -> Back to Start (Orange tint)
		var local_t: float = map_range(t, 0.7, 1.0, 0.0, 1.0)
		var start: Color = COL_BASE_BRIGHT.lerp(COL_BASE_DIM, 0.5)
		var end: Color = COL_BASE_DIM.lerp(LIGHT_ORANGE, 0.1)
		target_color = start.lerp(end, local_t)
	
	char_fx.color = target_color
	
	# --- Motion Simulation ---
	# The CUSTOMSTYLE shadows move +/- 1em. We simulate this by offsetting the text 
	# opposite to the "light source" to give it weight.
	# We use a slow circular motion synced with the color loop.
	var motion_strength: float = 2.0 # Pixels of movement
	var angle: float = t * TAU # 0 to 2PI
	
	char_fx.offset.x += cos(angle) * motion_strength
	char_fx.offset.y += sin(angle * 2.0) * (motion_strength * 0.5) # Figure-8 ish
	
	return true

func map_range(val: float, in_min: float, in_max: float, out_min: float, out_max: float) -> float:
	return (val - in_min) / (in_max - in_min) * (out_max - out_min) + out_min
