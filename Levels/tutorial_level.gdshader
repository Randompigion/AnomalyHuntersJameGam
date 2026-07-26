shader_type canvas_item;

uniform float noise_scale : hint_range(1.0, 50.0) = 8.0;
uniform float min_opacity : hint_range(0.0, 1.0) = 0.5;
uniform float max_opacity : hint_range(0.0, 1.0) = 1.0;
uniform vec2 seed_offset = vec2(37.2, 91.7);

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

void fragment() {
	vec2 world_uv = (UV + seed_offset) * noise_scale;
	float n = noise(world_uv);
	// suaviza un poco combinando dos octavas
	n = (n + noise(world_uv * 2.3) * 0.5) / 1.5;
	float opacity = mix(min_opacity, max_opacity, n);
	COLOR = vec4(0.0, 0.0, 0.0, opacity);
}
