shader_type spatial;
render_mode world_vertex_coords;

uniform int blocks_ids[18*18*18];
uniform sampler2DArray textures: source_color, filter_nearest, repeat_enable;
varying vec3 my_vertex;
varying vec3 my_normal;
varying flat int normal_index;

void vertex() {
	my_vertex = VERTEX;
	my_normal = NORMAL;
	normal_index = 6;
	if (NORMAL.x == 1.) { normal_index = 1; }
	if (NORMAL.y == 1.) { normal_index = 2; }
	if (NORMAL.z == 1.) { normal_index = 3; }
	if (NORMAL.x == -1.) { normal_index = 4; }
	if (NORMAL.y == -1.) { normal_index = 5; }
	if (NORMAL.z == -1.) { normal_index = 6; }
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec3 n_vertex = (my_vertex - (my_normal / vec3(2,2,2)));
	vec3 chunkspos = floor(n_vertex / vec3(16,16,16)) * vec3(16,16,16);
	vec3 pos = (n_vertex - chunkspos) + vec3(1,1,1);
	int bi = (int(pos.x) * (18 * 18)) + (int(pos.y) * 18) + int(pos.z);

	// Called for every pixel the material is visible on.
	//vec3 color = vec3(pos.x / 16.0, pos.y / 16.0, pos.z / 16.0);
	vec3 color = normalize(my_normal * 2.0 - 1.0);
	vec3 color2 = vec3(0,0,0);
	//if (blocks_ids[bi] == 2) {
	//	ALBEDO = color;
	//} else {
	//	ALBEDO = color2;
	//}
	int block_id = blocks_ids[bi];
	if (block_id == 3 && normal_index == 5) { block_id = 2; }
	if (block_id == 3 && normal_index != 2) { block_id = 4; }
	vec4 albedo_tex = texture(textures,vec3(UV,float(block_id)));
	ALBEDO = albedo_tex.rgb;
	ROUGHNESS = 1.0;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
