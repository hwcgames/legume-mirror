shader_type canvas_item;

uniform sampler2D viewport : filter_nearest;
uniform sampler2D quantize : filter_nearest;
uniform int block_size = 8;
uniform vec3 k = vec3(0.3333, 0.3333, 0.3333);
uniform float quality = 100.;

void fragment() {
	highp ivec2 pixel_position = ivec2(SCREEN_UV / SCREEN_PIXEL_SIZE);
	highp ivec2 block_position = (pixel_position/block_size)*block_size;
	highp ivec2 position_in_dct = pixel_position - block_position;
	highp vec3 color = vec3(0.);
	
	for (int i = 0; i < block_size; ++i) {
		for (int j = 0; j < block_size; ++j) {
			vec2 position_in_viewport = (vec2(block_position + ivec2(i, j)) + vec2(0.5)) * SCREEN_PIXEL_SIZE;
			vec3 viewport_v = texture(viewport, position_in_viewport).rgb;
			viewport_v = mat3(
				vec3(k.r, -0.5*k.r/(1.-k.b), 0.5),
				vec3(k.g, -0.5*k.g/(1.-k.b), -0.5*k.g/(1.-k.r)),
				vec3(k.b, 0.5, -0.5*k.b/(1.-k.r))
			) * viewport_v;
			color += viewport_v
				* cos((PI/float(block_size))*(float(j)+0.5)*float(position_in_dct.y))
				* cos((PI/float(block_size))*(float(i)+0.5)*float(position_in_dct.x));
		}
	}
	//color *= 2./float(block_size);
	if (quality <= 99.) {
		vec3 quant = texture(quantize, vec2(position_in_dct / block_size) + 0.5).rgb * (101. - quality);
		color /= quant;
		color = round(color);
		color *= quant;
	}
	COLOR.rgb = color;
}
