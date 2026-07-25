shader_type canvas_item;

uniform float pulse_speed: hint_range(0.5, 5.0) = 2.0;

void fragment() {
	vec2 uv = UV - vec2(0.5);
	float dist = length(uv);
	float pulse = 0.5 + 0.5 * sin(TIME * pulse_speed);
	float circle = smoothstep(0.5, 0.45, dist);
	float glow = smoothstep(0.7, 0.0, dist) * pulse * 0.6;
	vec4 color = vec4(0.1, 0.4, 1.0, 1.0);
	COLOR = vec4(color.rgb, (circle + glow) * color.a);
}