shader_type canvas_item;
// Nebula clouds, drawn in chunky pixels with a few colour bands to match the
// pixel-art style. Rendered at low resolution by nebula_layer.gd, which adds
// the result over the stars and sets camera_offset.

uniform vec2 camera_offset = vec2(0.0, 0.0);
// Screen pixels per rendered pixel, so the clouds keep their full-res size.
uniform float resolution_scale = 1.0;
uniform float strength = 0.45;
uniform float noise_scale = 0.0018;
uniform float pixel_size = 4.0;
// Noise values that map to no cloud / full cloud. Lower = more sky covered.
uniform float cloud_low = 0.4;
uniform float cloud_high = 0.7;
uniform vec3 color_a : source_color = vec3(0.45, 0.12, 0.7);
uniform vec3 color_b : source_color = vec3(0.05, 0.45, 0.62);

float rand(vec2 st) {
	return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

vec2 gradient(vec2 cell) {
	float a = rand(cell) * 6.2831853;
	return vec2(cos(a), sin(a));
}

// Gradient noise: smoother than value noise, without straight grid-aligned edges.
float gradient_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	float a = dot(gradient(i), f);
	float b = dot(gradient(i + vec2(1.0, 0.0)), f - vec2(1.0, 0.0));
	float c = dot(gradient(i + vec2(0.0, 1.0)), f - vec2(0.0, 1.0));
	float d = dot(gradient(i + vec2(1.0, 1.0)), f - vec2(1.0, 1.0));
	return 0.5 + 0.7 * mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

float fbm(vec2 p) {
	// Rotate each octave so the layers never line up on the same grid.
	mat2 rot = mat2(vec2(0.8, 0.6), vec2(-0.6, 0.8));
	float v = 0.0;
	float amp = 0.5;
	for (int i = 0; i < 5; i++) {
		v += amp * gradient_noise(p);
		p = rot * p * 2.03 + vec2(17.1, 9.2);
		amp *= 0.5;
	}
	return v;
}

void fragment() {
	vec2 coord = floor((FRAGCOORD.xy * resolution_scale + camera_offset) / pixel_size) * pixel_size;
	vec2 p = coord * noise_scale;
	float drift = TIME * 0.01;
	// Domain warp: bend the lookup by another noise so cloud edges stay organic
	// instead of following the noise grid in long straight lines.
	vec2 warp = vec2(fbm(p * 1.3 + vec2(3.1, drift)), fbm(p * 1.3 + vec2(-7.4, 2.9)));
	vec2 wp = p + (warp - 0.5) * 2.5;
	float density = smoothstep(cloud_low, cloud_high, fbm(wp + vec2(drift, 0.0)));
	density = floor(density * 4.0) / 4.0; // colour bands
	float tint = smoothstep(0.4, 0.6, fbm(wp * 0.7 + vec2(40.0, -drift)));
	COLOR = vec4(mix(color_a, color_b, tint) * density * strength, 1.0);
}
