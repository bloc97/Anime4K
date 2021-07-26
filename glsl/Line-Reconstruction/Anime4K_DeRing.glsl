//!DESC Anime4K-v4.0-De-Ring-Compute-Statistics
//!HOOK LUMA
//!BIND HOOKED
//!SAVE GAUSS
//!COMPONENTS 2

#define KERNELSIZE 5 //Kernel size, must be an positive odd integer.
#define KERNELHALFSIZE 2 //Half of the kernel size without remainder. Must be equal to trunc(KERNELSIZE/2).

#define L_tex HOOKED_tex

float comp_max_x(vec2 pos) {

	float g = 0;
	
	for (int i=0; i<KERNELSIZE; i++) {
		float di = float(i - KERNELHALFSIZE);
		float df = HOOKED_pt.x * di;
		
		g = max(g, (L_tex(pos + vec2(df, 0)).x));
	}
	
	return g;
}
float comp_min_x(vec2 pos) {

	float g = 0;
	
	for (int i=0; i<KERNELSIZE; i++) {
		float di = float(i - KERNELHALFSIZE);
		float df = HOOKED_pt.x * di;
		
		g = min(g, (L_tex(pos + vec2(df, 0)).x));
	}
	
	return g;
}

vec4 hook() {
    return vec4(comp_max_x(HOOKED_pos), comp_min_x(HOOKED_pos), 0, 0);
}

//!DESC Anime4K-v4.0-De-Ring-Compute-Statistics
//!HOOK LUMA
//!BIND HOOKED
//!BIND GAUSS
//!SAVE GAUSS
//!COMPONENTS 2

#define KERNELSIZE 5 //Kernel size, must be an positive odd integer.
#define KERNELHALFSIZE 2 //Half of the kernel size without remainder. Must be equal to trunc(KERNELSIZE/2).

#define L_tex GAUSS_tex

float comp_max_y(vec2 pos) {

	float g = 0;
	
	for (int i=0; i<KERNELSIZE; i++) {
		float di = float(i - KERNELHALFSIZE);
		float df = HOOKED_pt.y * di;
		
		g = max(g, (L_tex(pos + vec2(0, df)).x));
	}
	
	return g;
}
float comp_min_y(vec2 pos) {

	float g = 0;
	
	for (int i=0; i<KERNELSIZE; i++) {
		float di = float(i - KERNELHALFSIZE);
		float df = HOOKED_pt.y * di;
		
		g = min(g, (L_tex(pos + vec2(0, df)).y));
	}
	
	return g;
}
vec4 hook() {
    return vec4(comp_max_y(HOOKED_pos), comp_min_y(HOOKED_pos), 0, 0);
}

//!DESC Anime4K-v4.0-De-Ring
//!HOOK NATIVE
//!BIND HOOKED
//!BIND GAUSS

vec4 hook() {
	float luma_clamp = min(HOOKED_tex(HOOKED_pos).x, (GAUSS_tex(HOOKED_pos).x));
	luma_clamp = max(luma_clamp, (GAUSS_tex(HOOKED_pos).y));
    return vec4(luma_clamp, HOOKED_tex(HOOKED_pos).yzw);
}