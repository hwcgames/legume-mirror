shader_type spatial;
render_mode unshaded;

uniform vec4 albedo_color : source_color;
uniform sampler2D albedo_texture : source_color;
uniform vec4 shade_color : source_color;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler3D wobble;
uniform sampler2D exp_curve;
uniform float exp_mul = 4.;
uniform float line_weight = 1;
uniform float base_line_interval = 20.;
uniform float wobble_amt = 2.;
uniform bool skip = false;

//void vertex() {
	// Called for every vertex the material is visible on.
//}

float _hatch(float interval, float weight, vec2 fragcoord, vec2 direction, vec2 center) {
	highp float diagonal = dot(fragcoord, normalize(direction)) - dot(center, normalize(direction));
	highp float distance_from_diagonal = abs(mod(diagonal + (interval / 2.), interval) - (interval / 2.));
	return smoothstep(weight - 0.5, weight + 0.5, distance_from_diagonal);
	//return mod(diagonal, interval);
}

void fragment() {
	float brightness = 0.;
	for (int dx = -3; dx <= 3; dx++) {
		for (int dy = -3; dy <= 3; dy++) {
			brightness += length(texture(screen_texture, SCREEN_UV + (vec2(float(dx), float(dy)) / VIEWPORT_SIZE)).rgb);
		}
	}
	brightness /= 49.;
	highp float time = TIME / 5.;
	vec2 wobble_by = vec2(texture(wobble, vec3(UV, time)).r, texture(wobble, vec3(UV, time + 0.58)).r) * wobble_amt;
	//vec3 camera_x = (vec4(1, 0, 0, 0) * INV_VIEW_MATRIX * MODEL_MATRIX).xyz;
	//vec3 camera_y = (vec4(0, 1, 0, 0) * INV_VIEW_MATRIX * MODEL_MATRIX).xyz;
	//vec2 pos = vec2(dot(VERTEX, camera_x), dot(VERTEX, camera_y));
	float hatch_exp = texture(exp_curve, vec2(clamp(brightness, 0.01, 0.99), 0.)).r;
	float exponent = exp_mul * hatch_exp;
	float line_interval = base_line_interval / pow(2, floor(exponent));
	float progress = smoothstep(0., 1., mod(exponent, 1.));
	vec4 forward = INV_VIEW_MATRIX * vec4(0, 0, 1, 0);
	float angle = atan(forward.z, forward.x);
	mat2 rotation = mat2(
		vec2(cos(angle), -sin(angle)),
		vec2(sin(angle), cos(angle))
	);
	vec2 center = VIEWPORT_SIZE / 2.;
	//vec2 direction = (PROJECTION_MATRIX * VIEW_MATRIX * MODEL_MATRIX * vec4(1, 0, 1, 0)).xy;
	vec2 direction = rotation * vec2(1, 0);
	vec2 other_direction = vec2(direction.y, -direction.x);
	float less_hatch = min(_hatch(
		line_interval,
		line_weight,
		SCREEN_UV * VIEWPORT_SIZE + wobble_by,
		direction,
		center
	), _hatch(
		line_interval,
		line_weight,
		SCREEN_UV * VIEWPORT_SIZE + wobble_by,
		other_direction,
		center
	));
	float more_hatch = min(_hatch(
		line_interval / 2.,
		line_weight * progress,
		SCREEN_UV * VIEWPORT_SIZE + wobble_by,
		direction,
		center
	), _hatch(
		line_interval / 2.,
		line_weight * progress,
		SCREEN_UV * VIEWPORT_SIZE + wobble_by,
		other_direction,
		center
	));
	if (progress == 0.) {
		more_hatch = 1.;
	}
	if (exponent <= 1.) {
		less_hatch = 1.;
	}
	float hatch = min(less_hatch, more_hatch);//less_hatch * (1. - progress) + more_hatch * progress;
	hatch = clamp(hatch, 0., 1.);
	vec4 tex = texture(albedo_texture, UV);
	vec4 albedo = tex * tex.a + albedo_color * (1. - tex.a);
	vec4 color = shade_color * (1. - hatch) + albedo * hatch;
	ALPHA = color.a;
	ALBEDO = color.rgb;
	if (skip) {
		ALPHA = 0.;
	}
}

//void light() {
	//DIFFUSE_LIGHT += dot(LIGHT, NORMAL);
//}
