shader_type spatial;

uniform vec3 raw_color : source_color = vec3(0.8, 0.4, 0.4);
uniform vec3 cooked_color : source_color = vec3(0.3, 0.2, 0.1);
uniform vec3 burnt_color : source_color = vec3(0.05, 0.05, 0.05);
uniform float cook_progress : hint_range(0.0, 2.0) = 0.0;

void fragment() {
	vec3 final_color = raw_color;
	
	if (cook_progress > 0.0 && cook_progress <= 1.0) {
		final_color = mix(raw_color, cooked_color, cook_progress);
	} else if (cook_progress > 1.0) {
		final_color = mix(cooked_color, burnt_color, clamp(cook_progress - 1.0, 0.0, 1.0));
	}
	
	ALBEDO = final_color;
	// Add a slight "grease" shine
	ROUGHNESS = 0.3;
	SPECULAR = 0.5;
}
