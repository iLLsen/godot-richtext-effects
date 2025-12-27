# rte_molten.gd
# Effect: [magma]
# Description: Bottom vertices fixed, top vertices wave like heat haze. Orange/Red gradient.
# Parameters:
# - freq: Heat wave speed (default 3.0)

@tool
class_name RichTextMolten
extends RichTextEffect

var bbcode: String = "magma"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var freq: float = char_fx.env.get("freq", 3.0)
	
	var time: float = char_fx.elapsed_time
	# FIXED: Changed absolute_index to relative_index for Godot 4.0/4.1 compatibility
	var idx: float = float(char_fx.relative_index)
	
	# Heat Haze Motion (Moves upward and sways)
	var wave: float = sin(time * freq + idx * 0.5) * 2.0
	var rise: float = (sin(time * freq * 0.5 + idx) + 1.0) * 0.5 # 0 to 1
	
	char_fx.offset.x += wave
	char_fx.offset.y -= rise * 2.0
	
	# Color: Hot at top, cooler at bottom (Simulated via time/idx since we lack vertex data access in simple FX)
	# Instead, we cycle Orange -> Red -> Yellow
	var heat: float = (sin(time * 2.0 - idx * 0.2) + 1.0) * 0.5
	var magma_red: Color = Color(1.0, 0.2, 0.0)
	var magma_yellow: Color = Color(1.0, 0.8, 0.0)
	
	char_fx.color = magma_red.lerp(magma_yellow, heat)
	
	return true
