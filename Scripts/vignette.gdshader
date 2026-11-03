shader_type canvas_item;
// Darkens the screen edges to frame the action.

uniform float strength = 0.5;
uniform float inner = 0.55; // distance from centre where darkening starts (1 = corner)
uniform float outer = 1.25;

void fragment() {
	vec2 uv = SCREEN_UV - 0.5;
	uv.x *= SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x; // keep it round on wide screens
	float d = length(uv) * 2.0;
	COLOR = vec4(0.0, 0.0, 0.0, smoothstep(inner, outer, d) * strength);
}
