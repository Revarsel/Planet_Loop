shader_type canvas_item;
uniform vec4 bg_color;
uniform vec2 camera_offset = vec2(0.0, 0.0);
uniform float parallax_factor = 0.5;

float rand(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

void fragment() {
	float size = 100.0;
	float prob = 0.9;
	vec2 coord = FRAGCOORD.xy + camera_offset;

	vec2 pos = floor(1.0 / size * coord);
	float color = 0.0;
	float starValue = rand(pos);
	if (starValue > prob)
	{
		vec2 center = size * pos + vec2(size, size) * 0.5;
		float t = 0.9 + 0.2 * sin(TIME * 8.0 + (starValue - prob) / (1.0 - prob) * 45.0);
		float dx = max(abs(coord.x - center.x), 0.5);
		float dy = max(abs(coord.y - center.y), 0.5);
		color = 1.0 - distance(coord, center) / (0.5 * size);
		color = color * t / dy * t / dx;
		color = clamp(color, 0.0, 3.0);
	}
	else
	{
		float smallSize = 10.0; // cell spacing - lower = denser
		float dotRadius = 1.2;  // visual size of each star point
		vec2 cell = floor(coord / smallSize);
		float cellRand = rand(cell);
		if (cellRand > 0.992)
		{
			vec2 center = cell * smallSize + vec2(smallSize * 0.5);
			float r = rand(cell + vec2(17.0, 31.0)); // separate seed for phase variety
			float twinkle = 0.85 * sin(TIME * (r * 5.0) + 720.0 * r) + 0.95;
			float dot = 1.0 - smoothstep(0.0, dotRadius, distance(coord, center));
			color = dot * twinkle;
		}
	}
	COLOR = vec4(vec3(color),1.0) + bg_color;
}