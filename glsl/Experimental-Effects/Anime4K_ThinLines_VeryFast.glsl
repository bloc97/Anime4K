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

//!DESC Anime4K-v3.1-ThinLines(VeryFast)-Kernel(X)
//!HOOK NATIVE
//!BIND HOOKED
//!SAVE LUMAD
//!WIDTH NATIVE.w 4 /
//!HEIGHT NATIVE.h 4 /
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


//!DESC Anime4K-v3.1-ThinLines(VeryFast)-Kernel(Y)
//!HOOK NATIVE
//!BIND HOOKED
//!BIND LUMAD
//!SAVE LUMAD
//!WIDTH NATIVE.w 4 /
//!HEIGHT NATIVE.h 4 /
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


//!DESC Anime4K-v3.1-ThinLines(VeryFast)-Kernel(X)
//!HOOK NATIVE
//!BIND HOOKED
//!BIND LUMAD
//!SAVE LUMADG
//!WIDTH NATIVE.w 4 /
//!HEIGHT NATIVE.h 4 /
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


//!DESC Anime4K-v3.1-ThinLines(VeryFast)-Kernel(Y)
//!HOOK NATIVE
//!BIND HOOKED
//!BIND LUMAD
//!BIND LUMADG
//!SAVE LUMAD
//!WIDTH NATIVE.w 4 /
//!HEIGHT NATIVE.h 4 /
//!COMPONENTS 3

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
    return vec4(0, 0, g, 0);
}




//!DESC Anime4K-v3.1-ThinLines(VeryFast)-Kernel(X)
//!HOOK NATIVE
//!BIND HOOKED
//!BIND LUMAD
//!SAVE LUMAD2
//!WIDTH NATIVE.w 2 /
//!HEIGHT NATIVE.h 2 /
//!COMPONENTS 2

vec4 hook() {
	vec2 d = HOOKED_pt;
	
	//[tl  t tr]
	//[ l  c  r]
	//[bl  b br]
	float l = LUMAD_tex(HOOKED_pos + vec2(-d.x, 0)).z;
	float c = LUMAD_tex(HOOKED_pos).z;
	float r = LUMAD_tex(HOOKED_pos + vec2(d.x, 0)).z;
	
	
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


//!DESC Anime4K-v3.1-ThinLines(VeryFast)-Kernel(Y)
//!HOOK NATIVE
//!BIND HOOKED
//!BIND LUMAD2
//!SAVE LUMAD2
//!WIDTH NATIVE.w 2 /
//!HEIGHT NATIVE.h 2 /
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

//!DESC Anime4K-v3.1-ThinLines(VeryFast)
//!HOOK NATIVE
//!BIND HOOKED
//!BIND LUMAD
//!BIND LUMAD2

#define STRENGTH 0.6 //Strength of warping for each iteration
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
