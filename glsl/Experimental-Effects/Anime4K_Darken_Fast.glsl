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

//!DESC Anime4K-v3.2-Darken-DoG-(HQ)-Luma
//!HOOK MAIN
//!BIND HOOKED
//!SAVE LINELUMA
//!COMPONENTS 1

float get_luma(vec4 rgba) {
	return dot(vec4(0.299, 0.587, 0.114, 0.0), rgba);
}

vec4 hook() {
    return vec4(get_luma(HOOKED_tex(HOOKED_pos)), 0.0, 0.0, 0.0);
}

//!DESC Anime4K-v3.2-Darken-DoG-(Fast)-Difference-X
//!HOOK MAIN
//!BIND HOOKED
//!BIND LINELUMA
//!SAVE LINEKERNEL
//!WIDTH HOOKED.w 2 /
//!HEIGHT HOOKED.h 2 /
//!COMPONENTS 1

#define SPATIAL_SIGMA (1.0 * float(HOOKED_size.y) / 1080.0) //Spatial window size, must be a positive real number.

#define KERNELSIZE (max(int(ceil(SPATIAL_SIGMA * 2.0)), 1) * 2 + 1) //Kernel size, must be an positive odd integer.
#define KERNELHALFSIZE (int(KERNELSIZE/2)) //Half of the kernel size without remainder. Must be equal to trunc(KERNELSIZE/2).
#define KERNELLEN (KERNELSIZE * KERNELSIZE) //Total area of kernel. Must be equal to KERNELSIZE * KERNELSIZE.

float gaussian(float x, float s, float m) {
	float scaled = (x - m) / s;
	return exp(-0.5 * scaled * scaled);
}

float comp_gaussian_x() {

	float g = 0.0;
	float gn = 0.0;
	
	for (int i=0; i<KERNELSIZE; i++) {
		float di = float(i - KERNELHALFSIZE);
		float gf = gaussian(di, SPATIAL_SIGMA, 0.0);
		
		g = g + LINELUMA_texOff(vec2(di, 0.0)).x * gf;
		gn = gn + gf;
		
	}
	
	return g / gn;
}

vec4 hook() {
    return vec4(comp_gaussian_x(), 0.0, 0.0, 0.0);
}

//!DESC Anime4K-v3.2-Darken-DoG-(Fast)-Difference-Y
//!HOOK MAIN
//!BIND HOOKED
//!BIND LINELUMA
//!BIND LINEKERNEL
//!SAVE LINEKERNEL
//!WIDTH HOOKED.w 2 /
//!HEIGHT HOOKED.h 2 /
//!COMPONENTS 1

#define SPATIAL_SIGMA (0.5 * float(HOOKED_size.y) / 1080.0) //Spatial window size, must be a positive real number.

#define KERNELSIZE (max(int(ceil(SPATIAL_SIGMA * 2.0)), 1) * 2 + 1) //Kernel size, must be an positive odd integer.
#define KERNELHALFSIZE (int(KERNELSIZE/2)) //Half of the kernel size without remainder. Must be equal to trunc(KERNELSIZE/2).
#define KERNELLEN (KERNELSIZE * KERNELSIZE) //Total area of kernel. Must be equal to KERNELSIZE * KERNELSIZE.

float gaussian(float x, float s, float m) {
	float scaled = (x - m) / s;
	return exp(-0.5 * scaled * scaled);
}

float comp_gaussian_y() {

	float g = 0.0;
	float gn = 0.0;
	
	for (int i=0; i<KERNELSIZE; i++) {
		float di = float(i - KERNELHALFSIZE);
		float gf = gaussian(di, SPATIAL_SIGMA, 0.0);
		
		g = g + LINEKERNEL_texOff(vec2(0.0, di)).x * gf;
		gn = gn + gf;
		
	}
	
	return g / gn;
}

vec4 hook() {
    return vec4(min(LINELUMA_tex(HOOKED_pos).x - comp_gaussian_y(), 0.0), 0.0, 0.0, 0.0);
}

//!DESC Anime4K-v3.2-Darken-DoG-(Fast)-Gaussian-X
//!HOOK MAIN
//!BIND HOOKED
//!BIND LINEKERNEL
//!SAVE LINEKERNEL
//!WIDTH HOOKED.w 2 /
//!HEIGHT HOOKED.h 2 /
//!COMPONENTS 1

#define SPATIAL_SIGMA (0.5 * float(HOOKED_size.y) / 1080.0) //Spatial window size, must be a positive real number.

#define KERNELSIZE (max(int(ceil(SPATIAL_SIGMA * 2.0)), 1) * 2 + 1) //Kernel size, must be an positive odd integer.
#define KERNELHALFSIZE (int(KERNELSIZE/2)) //Half of the kernel size without remainder. Must be equal to trunc(KERNELSIZE/2).
#define KERNELLEN (KERNELSIZE * KERNELSIZE) //Total area of kernel. Must be equal to KERNELSIZE * KERNELSIZE.

float gaussian(float x, float s, float m) {
	float scaled = (x - m) / s;
	return exp(-0.5 * scaled * scaled);
}

float comp_gaussian_x() {

	float g = 0.0;
	float gn = 0.0;
	
	for (int i=0; i<KERNELSIZE; i++) {
		float di = float(i - KERNELHALFSIZE);
		float gf = gaussian(di, SPATIAL_SIGMA, 0.0);
		
		g = g + LINEKERNEL_texOff(vec2(di, 0.0)).x * gf;
		gn = gn + gf;
		
	}
	
	return g / gn;
}

vec4 hook() {
    return vec4(comp_gaussian_x(), 0.0, 0.0, 0.0);
}

//!DESC Anime4K-v3.2-Darken-DoG-(Fast)-Gaussian-Y
//!HOOK MAIN
//!BIND HOOKED
//!BIND LINEKERNEL
//!SAVE LINEKERNEL
//!WIDTH HOOKED.w 2 /
//!HEIGHT HOOKED.h 2 /
//!COMPONENTS 1

#define SPATIAL_SIGMA (0.5 * float(HOOKED_size.y) / 1080.0) //Spatial window size, must be a positive real number.

#define KERNELSIZE (max(int(ceil(SPATIAL_SIGMA * 2.0)), 1) * 2 + 1) //Kernel size, must be an positive odd integer.
#define KERNELHALFSIZE (int(KERNELSIZE/2)) //Half of the kernel size without remainder. Must be equal to trunc(KERNELSIZE/2).
#define KERNELLEN (KERNELSIZE * KERNELSIZE) //Total area of kernel. Must be equal to KERNELSIZE * KERNELSIZE.

float gaussian(float x, float s, float m) {
	float scaled = (x - m) / s;
	return exp(-0.5 * scaled * scaled);
}

float comp_gaussian_y() {

	float g = 0.0;
	float gn = 0.0;
	
	for (int i=0; i<KERNELSIZE; i++) {
		float di = float(i - KERNELHALFSIZE);
		float gf = gaussian(di, SPATIAL_SIGMA, 0.0);
		
		g = g + LINEKERNEL_texOff(vec2(0.0, di)).x * gf;
		gn = gn + gf;
		
	}
	
	return g / gn;
}

vec4 hook() {
    return vec4(comp_gaussian_y(), 0.0, 0.0, 0.0);
}


//!DESC Anime4K-v3.2-Darken-DoG-(Fast)-Upsample
//!HOOK MAIN
//!BIND HOOKED
//!BIND LINEKERNEL

#define STRENGTH 1.5 //Line darken proportional strength, higher is darker.

vec4 hook() {
	//This trick is only possible if the inverse Y->RGB matrix has 1 for every row... (which is the case for BT.709)
	//Otherwise we would need to convert RGB to YUV, modify Y then convert back to RGB.
    return HOOKED_tex(HOOKED_pos) + (LINEKERNEL_tex(HOOKED_pos).x * STRENGTH);
}

