//Anime4K v3.1 GLSL

// MIT License

// Copyright (c) 2019-2020 bloc97
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


//!DESC Anime4K-v3.1-Upscale(x2)-DTD-Kernel(X)
//!WHEN OUTPUT.w NATIVE.w / 1.200 > OUTPUT.h NATIVE.h / 1.200 > *
//!HOOK NATIVE
//!BIND HOOKED
//!SAVE MMKERNEL
//!COMPONENTS 1

#define L_tex HOOKED_tex

#define SIGMA 1

float gaussian(float x, float s, float m) {
	return (1 / (s * sqrt(2 * 3.14159))) * exp(-0.5 * pow(abs(x - m) / s, 2.0));
}

float lumGaussian(vec2 pos, vec2 d) {
	float s = SIGMA * HOOKED_size.y / 1080;
	float kernel_size = s * 2 + 1;
	
	float g = (L_tex(pos).x) * gaussian(0, s, 0);
	float gn = gaussian(0, s, 0);
	
	g += (L_tex(pos - d).x + L_tex(pos + d).x) * gaussian(1, s, 0);
	gn += gaussian(1, s, 0) * 2;
	
	for (int i=2; i<kernel_size; i++) {
		g += (L_tex(pos - (d * i)).x + L_tex(pos + (d * i)).x) * gaussian(i, s, 0);
		gn += gaussian(i, s, 0) * 2;
	}
	
	return g / gn;
}

vec4 hook() {
    return vec4(lumGaussian(HOOKED_pos, vec2(HOOKED_pt.x, 0)));
}

//!DESC Anime4K-v3.1-Upscale(x2)-DTD-Kernel(Y)
//!WHEN OUTPUT.w NATIVE.w / 1.200 > OUTPUT.h NATIVE.h / 1.200 > *
//!HOOK NATIVE
//!BIND HOOKED
//!BIND MMKERNEL
//!SAVE MMKERNEL
//!COMPONENTS 1

#define L_tex MMKERNEL_tex

#define SIGMA 1

float gaussian(float x, float s, float m) {
	return (1 / (s * sqrt(2 * 3.14159))) * exp(-0.5 * pow(abs(x - m) / s, 2.0));
}

float lumGaussian(vec2 pos, vec2 d) {
	float s = SIGMA * HOOKED_size.y / 1080;
	float kernel_size = s * 2 + 1;
	
	float g = (L_tex(pos).x) * gaussian(0, s, 0);
	float gn = gaussian(0, s, 0);
	
	g += (L_tex(pos - d).x + L_tex(pos + d).x) * gaussian(1, s, 0);
	gn += gaussian(1, s, 0) * 2;
	
	for (int i=2; i<kernel_size; i++) {
		g += (L_tex(pos - (d * i)).x + L_tex(pos + (d * i)).x) * gaussian(i, s, 0);
		gn += gaussian(i, s, 0) * 2;
	}
	
	return g / gn;
}

vec4 hook() {
    return vec4(min(HOOKED_tex(HOOKED_pos).x - lumGaussian(HOOKED_pos, vec2(0, HOOKED_pt.y)), 0));
}

//!DESC Anime4K-v3.1-Upscale(x2)-DTD-Kernel(X)
//!WHEN OUTPUT.w NATIVE.w / 1.200 > OUTPUT.h NATIVE.h / 1.200 > *
//!HOOK NATIVE
//!BIND HOOKED
//!BIND MMKERNEL
//!SAVE MMKERNEL
//!COMPONENTS 1

#define L_tex MMKERNEL_tex

#define SIGMA 0.4

float gaussian(float x, float s, float m) {
	return (1 / (s * sqrt(2 * 3.14159))) * exp(-0.5 * pow(abs(x - m) / s, 2.0));
}

float lumGaussian(vec2 pos, vec2 d) {
	float s = SIGMA * HOOKED_size.y / 1080;
	float kernel_size = s * 2 + 1;
	
	float g = (L_tex(pos).x) * gaussian(0, s, 0);
	float gn = gaussian(0, s, 0);
	
	g += (L_tex(pos - d).x + L_tex(pos + d).x) * gaussian(1, s, 0);
	gn += gaussian(1, s, 0) * 2;
	
	for (int i=2; i<kernel_size; i++) {
		g += (L_tex(pos - (d * i)).x + L_tex(pos + (d * i)).x) * gaussian(i, s, 0);
		gn += gaussian(i, s, 0) * 2;
	}
	
	return g / gn;
}

vec4 hook() {
    return vec4(lumGaussian(HOOKED_pos, vec2(HOOKED_pt.x, 0)));
}

//!DESC Anime4K-v3.1-Upscale(x2)-DTD-Kernel(Y)
//!WHEN OUTPUT.w NATIVE.w / 1.200 > OUTPUT.h NATIVE.h / 1.200 > *
//!HOOK NATIVE
//!BIND HOOKED
//!BIND MMKERNEL
//!SAVE MMKERNEL
//!COMPONENTS 1

#define L_tex MMKERNEL_tex

#define SIGMA 0.4

float gaussian(float x, float s, float m) {
	return (1 / (s * sqrt(2 * 3.14159))) * exp(-0.5 * pow(abs(x - m) / s, 2.0));
}

float lumGaussian(vec2 pos, vec2 d) {
	float s = SIGMA * HOOKED_size.y / 1080;
	float kernel_size = s * 2 + 1;
	
	float g = (L_tex(pos).x) * gaussian(0, s, 0);
	float gn = gaussian(0, s, 0);
	
	g += (L_tex(pos - d).x + L_tex(pos + d).x) * gaussian(1, s, 0);
	gn += gaussian(1, s, 0) * 2;
	
	for (int i=2; i<kernel_size; i++) {
		g += (L_tex(pos - (d * i)).x + L_tex(pos + (d * i)).x) * gaussian(i, s, 0);
		gn += gaussian(i, s, 0) * 2;
	}
	
	return g / gn;
}

vec4 hook() {
    return vec4(lumGaussian(HOOKED_pos, vec2(0, HOOKED_pt.y)));
}

//!DESC Anime4K-v3.1-Upscale(x2)-DTD
//!WHEN OUTPUT.w NATIVE.w / 1.200 > OUTPUT.h NATIVE.h / 1.200 > *
//!HOOK NATIVE
//!BIND HOOKED
//!BIND MMKERNEL

#define STRENGTH 1.8 //Line darken proportional strength, higher is darker.
#define L_tex HOOKED_tex

vec4 hook() {
	float c = (MMKERNEL_tex(HOOKED_pos).x) * STRENGTH;
	return vec4(clamp(c + L_tex(HOOKED_pos).x, 0, L_tex(HOOKED_pos).x), HOOKED_tex(HOOKED_pos).yz, 0);
}



//!DESC Anime4K-v3.1-Upscale(x2)-DTD-Kernel(X)
//!WHEN OUTPUT.w NATIVE.w / 1.200 > OUTPUT.h NATIVE.h / 1.200 > *
//!HOOK NATIVE
//!BIND HOOKED
//!SAVE LUMAD
//!COMPONENTS 2

#define L_tex NATIVE_tex

vec4 hook() {
	vec2 d = HOOKED_pt;
	
	//[tl  t tr]
	//[ l  c  r]
	//[bl  b br]
	float l = L_tex(HOOKED_pos + vec2(-d.x, 0)).x;
	float c = L_tex(HOOKED_pos).x;
	float r = L_tex(HOOKED_pos + vec2(d.x, 0)).x;
	
	
	//Horizontal Gradient
	//[-1  0  1]
	//[-2  0  2]
	//[-1  0  1]
	float xgrad = (-l + r);
	
	//Vertical Gradient
	//[-1 -2 -1]
	//[ 0  0  0]
	//[ 1  2  1]
	float ygrad = (l + c + c + r);
	
	//Computes the luminance's gradient
	return vec4(xgrad, ygrad, 0, 0);
}


//!DESC Anime4K-v3.1-Upscale(x2)-DTD-Kernel(Y)
//!WHEN OUTPUT.w NATIVE.w / 1.200 > OUTPUT.h NATIVE.h / 1.200 > *
//!HOOK NATIVE
//!BIND HOOKED
//!BIND LUMAD
//!SAVE LUMAD
//!COMPONENTS 1

vec4 hook() {
	vec2 d = HOOKED_pt;
	
	//[tl  t tr]
	//[ l cc  r]
	//[bl  b br]
	float tx = LUMAD_tex(HOOKED_pos + vec2(0, -d.y)).x;
	float cx = LUMAD_tex(HOOKED_pos).x;
	float bx = LUMAD_tex(HOOKED_pos + vec2(0, d.y)).x;
	
	
	float ty = LUMAD_tex(HOOKED_pos + vec2(0, -d.y)).y;
	//float cy = LUMAD_tex(HOOKED_pos).y;
	float by = LUMAD_tex(HOOKED_pos + vec2(0, d.y)).y;
	
	
	//Horizontal Gradient
	//[-1  0  1]
	//[-2  0  2]
	//[-1  0  1]
	float xgrad = (tx + cx + cx + bx) / 8;
	
	//Vertical Gradient
	//[-1 -2 -1]
	//[ 0  0  0]
	//[ 1  2  1]
	float ygrad = (-ty + by) / 8;
	
	//Computes the luminance's gradient
	float norm = sqrt(xgrad * xgrad + ygrad * ygrad);
	return vec4(pow(norm, 0.7));
}


//!DESC Anime4K-v3.1-Upscale(x2)-DTD-Kernel(X)
//!WHEN OUTPUT.w NATIVE.w / 1.200 > OUTPUT.h NATIVE.h / 1.200 > *
//!HOOK NATIVE
//!BIND HOOKED
//!BIND LUMAD
//!SAVE LUMADG
//!COMPONENTS 1

#define L_tex LUMAD_tex

#define SIGMA (HOOKED_size.y / 1080) * 2
#define KERNELSIZE (SIGMA * 2 + 1)

float gaussian(float x, float s, float m) {
	return (1 / (s * sqrt(2 * 3.14159))) * exp(-0.5 * pow(abs(x - m) / s, 2.0));
}

float lumGaussian(vec2 pos, vec2 d) {
	float g = (L_tex(pos).x) * gaussian(0, SIGMA, 0);
	g = g + (L_tex(pos - d).x + L_tex(pos + d).x) * gaussian(1, SIGMA, 0);
	for (int i=2; i<KERNELSIZE; i++) {
		g = g + (L_tex(pos - (d * i)).x + L_tex(pos + (d * i)).x) * gaussian(i, SIGMA, 0);
	}
	
	return g;
}

vec4 hook() {
    return vec4(lumGaussian(HOOKED_pos, vec2(HOOKED_pt.x, 0)));
}


//!DESC Anime4K-v3.1-Upscale(x2)-DTD-Kernel(Y)
//!WHEN OUTPUT.w NATIVE.w / 1.200 > OUTPUT.h NATIVE.h / 1.200 > *
//!HOOK NATIVE
//!BIND HOOKED
//!BIND LUMAD
//!BIND LUMADG
//!SAVE LUMAD
//!COMPONENTS 1

#define L_tex LUMADG_tex

#define SIGMA (HOOKED_size.y / 1080) * 2
#define KERNELSIZE (SIGMA * 2 + 1)

float gaussian(float x, float s, float m) {
	return (1 / (s * sqrt(2 * 3.14159))) * exp(-0.5 * pow(abs(x - m) / s, 2.0));
}

float lumGaussian(vec2 pos, vec2 d) {
	float g = (L_tex(pos).x) * gaussian(0, SIGMA, 0);
	g = g + (L_tex(pos - d).x + L_tex(pos + d).x) * gaussian(1, SIGMA, 0);
	for (int i=2; i<KERNELSIZE; i++) {
		g = g + (L_tex(pos - (d * i)).x + L_tex(pos + (d * i)).x) * gaussian(i, SIGMA, 0);
	}
	
	return g;
}

vec4 hook() {
	float g = lumGaussian(HOOKED_pos, vec2(0, HOOKED_pt.y));
    return vec4(g);
}




//!DESC Anime4K-v3.1-Upscale(x2)-DTD-Kernel(X)
//!WHEN OUTPUT.w NATIVE.w / 1.200 > OUTPUT.h NATIVE.h / 1.200 > *
//!HOOK NATIVE
//!BIND HOOKED
//!BIND LUMAD
//!SAVE LUMAD2
//!COMPONENTS 2

vec4 hook() {
	vec2 d = HOOKED_pt;
	
	//[tl  t tr]
	//[ l  c  r]
	//[bl  b br]
	float l = LUMAD_tex(HOOKED_pos + vec2(-d.x, 0)).x;
	float c = LUMAD_tex(HOOKED_pos).x;
	float r = LUMAD_tex(HOOKED_pos + vec2(d.x, 0)).x;
	
	
	//Horizontal Gradient
	//[-1  0  1]
	//[-2  0  2]
	//[-1  0  1]
	float xgrad = (-l + r);
	
	//Vertical Gradient
	//[-1 -2 -1]
	//[ 0  0  0]
	//[ 1  2  1]
	float ygrad = (l + c + c + r);
	
	//Computes the luminance's gradient
	return vec4(xgrad, ygrad, 0, 0);
}


//!DESC Anime4K-v3.1-Upscale(x2)-DTD-Kernel(Y)
//!WHEN OUTPUT.w NATIVE.w / 1.200 > OUTPUT.h NATIVE.h / 1.200 > *
//!HOOK NATIVE
//!BIND HOOKED
//!BIND LUMAD2
//!SAVE LUMAD2
//!COMPONENTS 2

vec4 hook() {
	vec2 d = HOOKED_pt;
	
	//[tl  t tr]
	//[ l cc  r]
	//[bl  b br]
	float tx = LUMAD2_tex(HOOKED_pos + vec2(0, -d.y)).x;
	float cx = LUMAD2_tex(HOOKED_pos).x;
	float bx = LUMAD2_tex(HOOKED_pos + vec2(0, d.y)).x;
	
	
	float ty = LUMAD2_tex(HOOKED_pos + vec2(0, -d.y)).y;
	//float cy = LUMAD2_tex(HOOKED_pos).y;
	float by = LUMAD2_tex(HOOKED_pos + vec2(0, d.y)).y;
	
	
	//Horizontal Gradient
	//[-1  0  1]
	//[-2  0  2]
	//[-1  0  1]
	float xgrad = (tx + cx + cx + bx) / 8;
	
	//Vertical Gradient
	//[-1 -2 -1]
	//[ 0  0  0]
	//[ 1  2  1]
	float ygrad = (-ty + by) / 8;
	
	//Computes the luminance's gradient
	return vec4(xgrad, ygrad, 0, 0);
}

//!DESC Anime4K-v3.1-Upscale(x2)-DTD
//!WHEN OUTPUT.w NATIVE.w / 1.200 > OUTPUT.h NATIVE.h / 1.200 > *
//!HOOK NATIVE
//!BIND HOOKED
//!BIND LUMAD
//!BIND LUMAD2
//!WIDTH OUTPUT.w
//!HEIGHT OUTPUT.h

#define STRENGTH 0.4 //Strength of warping for each iteration
#define ITERATIONS 1 //Number of iterations for the forwards solver, decreasing strength and increasing iterations improves quality at the cost of speed.

#define L_tex HOOKED_tex

vec4 hook() {
	vec2 d = HOOKED_pt;
	
	float relstr = HOOKED_size.y / 1080 * STRENGTH;
	
	vec2 pos = HOOKED_pos;
	for (int i=0; i<ITERATIONS; i++) {
		vec2 dn = LUMAD2_tex(pos).xy;
		vec2 dd = (dn / (length(dn) + 0.01)) * d * relstr; //Quasi-normalization for large vectors, avoids divide by zero
		pos -= dd;
	}
	
	return HOOKED_tex(pos);
	
}


//!DESC Anime4K-v3.1-Upscale(x2)-DTD-Kernel(X)
//!WHEN OUTPUT.w LUMAD2.w / 1.200 > OUTPUT.h LUMAD2.h / 1.200 > *
//!HOOK NATIVE
//!BIND HOOKED
//!SAVE MMKERNEL
//!WIDTH NATIVE.w 2 /
//!HEIGHT NATIVE.h 2 /
//!COMPONENTS 3

#define L_tex HOOKED_tex

float max3v(float a, float b, float c) {
	return max(max(a, b), c);
}
float min3v(float a, float b, float c) {
	return min(min(a, b), c);
}

vec2 minmax3(vec2 pos, vec2 d) {
	float a = L_tex(pos - d).x;
	float b = L_tex(pos).x;
	float c = L_tex(pos + d).x;
	
	return vec2(min3v(a, b, c), max3v(a, b, c));
}

float lumGaussian7(vec2 pos, vec2 d) {
	float g = (L_tex(pos - (d + d)).x + L_tex(pos + (d + d)).x) * 0.06136;
	g = g + (L_tex(pos - d).x + L_tex(pos + d).x) * 0.24477;
	g = g + (L_tex(pos).x) * 0.38774;
	
	return g;
}


vec4 hook() {
    return vec4(lumGaussian7(HOOKED_pos, vec2(HOOKED_pt.x, 0)), minmax3(HOOKED_pos, vec2(HOOKED_pt.x, 0)), 0);
}


//!DESC Anime4K-v3.1-Upscale(x2)-DTD-Kernel(Y)
//!WHEN OUTPUT.w LUMAD2.w / 1.200 > OUTPUT.h LUMAD2.h / 1.200 > *
//!HOOK NATIVE
//!BIND HOOKED
//!BIND MMKERNEL
//!SAVE MMKERNEL
//!WIDTH NATIVE.w 2 /
//!HEIGHT NATIVE.h 2 /
//!COMPONENTS 3

#define L_tex MMKERNEL_tex

float max3v(float a, float b, float c) {
	return max(max(a, b), c);
}
float min3v(float a, float b, float c) {
	return min(min(a, b), c);
}

vec2 minmax3(vec2 pos, vec2 d) {
	float a0 = L_tex(pos - d).y;
	float b0 = L_tex(pos).y;
	float c0 = L_tex(pos + d).y;
	
	float a1 = L_tex(pos - d).z;
	float b1 = L_tex(pos).z;
	float c1 = L_tex(pos + d).z;
	
	return vec2(min3v(a0, b0, c0), max3v(a1, b1, c1));
}

float lumGaussian7(vec2 pos, vec2 d) {
	float g = (L_tex(pos - (d + d)).x + L_tex(pos + (d + d)).x) * 0.06136;
	g = g + (L_tex(pos - d).x + L_tex(pos + d).x) * 0.24477;
	g = g + (L_tex(pos).x) * 0.38774;
	
	return g;
}


vec4 hook() {
    return vec4(lumGaussian7(HOOKED_pos, vec2(0, HOOKED_pt.y)), minmax3(HOOKED_pos, vec2(0, HOOKED_pt.y)), 0);
}

//!DESC Anime4K-v3.1-Upscale(x2)-DTD
//!WHEN OUTPUT.w LUMAD2.w / 1.200 > OUTPUT.h LUMAD2.h / 1.200 > *
//!HOOK NATIVE
//!BIND HOOKED
//!BIND MMKERNEL

#define STRENGTH 0.8 //De-blur proportional strength, higher is sharper. However, it is better to tweak BLUR_CURVE instead to avoid ringing.
#define BLUR_CURVE 0.6 //De-blur power curve, lower is sharper. Good values are between 0.3 - 1. Values greater than 1 softens the image;
#define BLUR_THRESHOLD 0.1 //Value where curve kicks in, used to not de-blur already sharp edges. Only de-blur values that fall below this threshold.
#define NOISE_THRESHOLD 0.004 //Value where curve stops, used to not sharpen noise. Only de-blur values that fall above this threshold.

#define L_tex HOOKED_tex

vec4 hook() {
	float c = (L_tex(HOOKED_pos).x - MMKERNEL_tex(HOOKED_pos).x) * STRENGTH;
	
	float t_range = BLUR_THRESHOLD - NOISE_THRESHOLD;
	
	float c_t = abs(c);
	if (c_t > NOISE_THRESHOLD) {
		c_t = (c_t - NOISE_THRESHOLD) / t_range;
		c_t = pow(c_t, BLUR_CURVE);
		c_t = c_t * t_range + NOISE_THRESHOLD;
		c_t = c_t * sign(c);
	} else {
		c_t = c;
	}
	return vec4(clamp(c_t + L_tex(HOOKED_pos).x, MMKERNEL_tex(HOOKED_pos).y, MMKERNEL_tex(HOOKED_pos).z), HOOKED_tex(HOOKED_pos).yz, 0);
}



