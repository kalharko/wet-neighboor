shader_type canvas_item;

uniform float alpha: hint_range(0.0,1,.01) = 0.5;
uniform float percentage: hint_range(0.0,1,.01) = 0.5;
uniform float top: hint_range(0.0, 1, .01) = 0;
uniform float bottom: hint_range(0.0, 1, .01) = 1;


void fragment() {
	// Called for every pixel the material is visible on.
	COLOR.a = texture(TEXTURE, UV).a * alpha;
	if (UV.y < top + (bottom - top) * percentage){
		discard;
	}
}