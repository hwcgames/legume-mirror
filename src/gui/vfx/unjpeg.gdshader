shader_type canvas_item;

uniform sampler2D dct : filter_nearest;
uniform int block_size = 8;
uniform vec3 k = vec3(0.3333, 0.3333, 0.3333);

void fragment() {
	ivec2 pixel_position = ivec2(floor(SCREEN_UV / SCREEN_PIXEL_SIZE));
	ivec2 block_position = (pixel_position/block_size)*block_size;
	ivec2 position_in_yiq = pixel_position - block_position;
	highp vec3 color = vec3(0.);

	//for (int i = 0; i < block_size; ++i) {
		//for (int j = 0; j < block_size; ++j) {
			//vec2 position_in_yiq = (block_position + vec2(float(i), float(j))) * SCREEN_PIXEL_SIZE;
			//vec3 yiq_v = texture(yiq, position_in_yiq).rgb;
			//color += yiq_v
				//* vec3(cos((PI/float(block_size))*(float(j)+0.5)*position_in_dct.y))
				//* vec3(cos((PI/float(block_size))*(float(i)+0.5)*position_in_dct.x));
		//}
	//}

	for (int i = 0; i < block_size; ++i) {
		for (int j = 0; j < block_size; ++j) {
			highp vec2 position_in_dct = (vec2(block_position + ivec2(i, j)) + vec2(0.5)) * SCREEN_PIXEL_SIZE;
			vec3 dct_v = texture(dct, position_in_dct).rgb;
			if (i == 0 && j == 0) {
				color += dct_v / 2.;
				continue;
			}
			//float alpha_i = i == 0 ? 1./sqrt(2.) : sqrt(1.);
			//float alpha_j = j == 0 ? 1./sqrt(2.) : sqrt(1.);
			color += dct_v
				//* alpha_i
				//* alpha_j
				* cos((PI/float(block_size)) * (float(position_in_yiq.y) + 0.5) * float(j))
				* cos((PI/float(block_size)) * (float(position_in_yiq.x) + 0.5) * float(i));
		}
	}
	//color *= sqrt(2./float(block_size)) / 7.;
	color *= 2./float(block_size*8);
	COLOR.rgb = color;
	COLOR.rgb = mat3(
		vec3(1.,		1.,						1.),
		vec3(0.,		(-k.b/k.g)*(2.-2.*k.b),	2.-2.*k.b),
		vec3(2.-2.*k.r,	(-k.r/k.g)*(2.-2.*k.r),	0.)
	) * COLOR.rgb;

	//for (int i = 0; i < block_size; ++i) {
		//for (int j = 0; j < block_size; ++j) {
			//vec2 uv = (block_position + vec2(float(i), float(j))) * SCREEN_PIXEL_SIZE;
			//vec3 X = texture(dct, uv).rgb;
			//COLOR.rgb += X
				//* cos((PI/float(block_size))*(float(i)+1./2.)*u)
				//* cos((PI/float(block_size))*(float(j)+1./2.)*v);
		//}
	//}
}
