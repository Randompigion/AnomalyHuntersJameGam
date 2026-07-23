shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(1.0, 0.1, 0.1, 1.0);
uniform float glow_strength : hint_range(0.0, 3.0) = 1.5;
uniform float pulse_speed : hint_range(0.1, 10.0) = 2.0;
uniform float outline_width : hint_range(0.0, 0.05) = 0.01;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);

	float pulse = 0.5 + 0.5 * sin(TIME * pulse_speed);
	float intensity = glow_strength * (0.6 + 0.4 * pulse);

	vec4 base = tex_color;
	vec3 glow = glow_color.rgb * intensity;

	COLOR = vec4(base.rgb + glow * base.a, base.a);
}