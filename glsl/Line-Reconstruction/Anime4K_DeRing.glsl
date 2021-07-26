//Anime4K v4.0 GLSL

// MIT License

// Copyright (c) 2019-2021 bloc97
// All rights reserved.

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

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