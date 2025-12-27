# rte_swing.gd
# Effect: [swing radius=1 spread=0.1 speed=2.0]
# Description: Replicates a CUSTOMSTYLE 'Swing' effect where a spotlight mask reveals 
# rainbow gradient text while swinging from left to right.
#
# Parameters:
# - speed: Swing speed (default 1.0 = 5s loop)
# - width: Estimated text length in characters for normalization (default 20.0)
# - radius: Spotlight radius in normalized units (default 3.0)
# - spread: Softness of the spotlight edge (default 2.0)

@tool
class_name RichTextSwing
extends RichTextEffect

var bbcode: String = "swing"

# Rainbow Gradient Colors (CUSTOMSTYLE: Red, Orange, Yellow, Green, Blue, Purple)
var GRADIENT_COLORS: Array[Color] = [
	Color("#f70000"), # Red
	Color("#f89200"), # Orange
	Color("#f8f501"), # Yellow
	Color("#038f00"), # Green
	Color("#0168f8"), # Blue
	Color("#a200f7")  # Purple
]

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	# Parameters
	var speed: float = char_fx.env.get("speed", 1.0)
	var est_width: float = char_fx.env.get("width", 20.0) # Approx chars in the line
	var radius: float = char_fx.env.get("radius", 3.0) # Radius in char units
	var spread: float = char_fx.env.get("spread", 2.0) # Edge softness
	
	# Capture the original color (e.g. White or Black) to use as the "Base"
	var base_color: Color = char_fx.color
	
	# Time Management (5s loop in CUSTOMSTYLE, we normalize speed)
	# CUSTOMSTYLE Animation: 0% -> 50% -> 100% (Alternate direction)
	# We simulate a Sine wave for smooth swinging (-1 to 1)
	var time: float = char_fx.elapsed_time * speed
	# Offset time by -0.5 PI so we start at -1 (Left) instead of 0 (Center)
	var swing_phase: float = (sin((time * 0.5 * PI) - (0.5 * PI)) + 1.0) * 0.5 # 0.0 to 1.0 oscillating
	
	# Current Character Position (Normalized X coordinate)
	# FIXED: Use relative_index to get the position 0, 1, 2... within the tag.
	# range.x was causing all chars to stack at the start index.
	var char_idx: float = float(char_fx.relative_index)
	
	# --- 1. Spotlight Position Logic ---
	# CUSTOMSTYLE Keyframes:
	# 0%: Left (-2.5%), Top (-9%)
	# 50%: Center (49%), Bottom (64%)
	# 100%: Right (102%), Top (-1%)
	# We map this to Character Index units.
	
	var start_x: float = -2.0 # Slightly left of text start
	var mid_x: float = est_width * 0.5
	var end_x: float = est_width + 2.0 # Slightly right of text end
	
	var current_spot_x: float
	var current_spot_y: float # Simulated Y depth (0 = on text, >0 = below)
	
	if swing_phase < 0.5:
		# 0% to 50% (Left -> Center)
		var t: float = swing_phase * 2.0 # 0.0 to 1.0
		# Ease In Out
		t = smoothstep(0.0, 1.0, t)
		current_spot_x = lerp(start_x, mid_x, t)
		current_spot_y = lerp(0.0, 1.0, t) # Dipping down
	else:
		# 50% to 100% (Center -> Right)
		var t: float = (swing_phase - 0.5) * 2.0
		# Ease In Out
		t = smoothstep(0.0, 1.0, t)
		current_spot_x = lerp(mid_x, end_x, t)
		current_spot_y = lerp(1.0, 0.0, t) # Coming up
	
	# --- 2. Rainbow Gradient Logic ---
	# Map character index to the gradient array
	var grad_pos: float = char_idx / est_width
	grad_pos = clamp(grad_pos, 0.0, 1.0) * (GRADIENT_COLORS.size() - 1)
	
	var col_idx: int = int(floor(grad_pos))
	var col_rem: float = grad_pos - col_idx
	var next_idx: int = min(col_idx + 1, GRADIENT_COLORS.size() - 1)
	
	var rainbow_col: Color = GRADIENT_COLORS[col_idx].lerp(GRADIENT_COLORS[next_idx], col_rem)
	
	# --- 3. Masking Logic ---
	# Calculate 1D distance (since we assume single line) modified by the "Swing Y" depth
	# The deeper the swing (Y), the wider the spotlight effectively covers if it's a cone, 
	# but CUSTOMSTYLE implies the ellipse ITSELF moves.
	# Let's treat distance simply as X distance.
	
	var dist: float = abs(char_idx - current_spot_x)
	
	# Modify effective radius based on Y swing (Dipping down makes it "cover" the middle well)
	# CUSTOMSTYLE ellipse is 120x120px constant.
	# We stick to the X-distance check.
	
	var visibility: float = 0.0
	
	if dist < radius:
		visibility = 1.0
	elif dist < radius + spread:
		# Soft edge
		visibility = 1.0 - ((dist - radius) / spread)
	
	# Apply Colors
	# Blend from Base Color to Rainbow based on visibility
	# This ensures text is never fully transparent unless the base color is transparent
	char_fx.color = base_color.lerp(rainbow_col, visibility)
	
	# Optional: Slight scale punch for the spotlight effect
	if visibility > 0.1:
		var scale_boost: float = 1.0 + (visibility * 0.2 * current_spot_y) # Scale up slightly in the middle dip
		var pivot: Vector2 = char_fx.transform.get_origin()
		char_fx.transform = char_fx.transform.scaled_local(Vector2(scale_boost, scale_boost))

	return true
