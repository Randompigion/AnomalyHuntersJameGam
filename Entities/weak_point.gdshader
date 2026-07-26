shader_type canvas_item;

uniform float pulse_speed: hint_range(0.5, 5.0) = 2.0;
uniform vec4 base_color: source_color = vec4(0.1, 0.4, 1.0, 1.0);
uniform float circle_radius: hint_range(0.1, 0.5) = 0.4;
uniform float edge_softness: hint_range(0.0, 0.2) = 0.05;
uniform float glow_radius: hint_range(0.3, 1.0) = 0.55;
uniform float glow_intensity: hint_range(0.0, 1.0) = 0.4;

void fragment() {
	vec2 uv = UV - vec2(0.5);
	float dist = length(uv);
	float pulse = 0.5 + 0.5 * sin(TIME * pulse_speed);

	float circle = smoothstep(circle_radius, circle_radius - edge_softness, dist);
	float glow = smoothstep(glow_radius, circle_radius, dist) * pulse * glow_intensity;

	COLOR = vec4(base_color.rgb, clamp(circle + glow, 0.0, 1.0) * base_color.a);
}