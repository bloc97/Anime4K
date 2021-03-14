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

//!DESC Anime4K-v3.1-DarkLines-Kernel(X)
//!HOOK NATIVE
//!BIND HOOKED
//!SAVE MMKERNEL
//!COMPONENTS 1

#define L_tex HOOKED_tex

#define SIGMA 1.0

float gaussian(float x, float s, float m) {
	return (1.0 / (s * sqrt(2.0 * 3.14159))) * exp(-0.5 * pow(abs(x - m) / s, 2.0));
}

float lumGaussian(vec2 pos, vec2 d) {
	float s = SIGMA * HOOKED_size.y / 1080.0;
	float kernel_size = s * 2.0 + 1.0;
	
	float g = (L_tex(pos).x) * gaussian(0.0, s, 0.0);
	float gn = gaussian(0.0, s, 0.0);
	
	g += (L_tex(pos - d).x + L_tex(pos + d).x) * gaussian(1.0, s, 0.0);
	gn += gaussian(1.0, s, 0.0) * 2.0;
	
	for (int i=2; float(i)<kernel_size; i++) {
		g += (L_tex(pos - (d * float(i))).x + L_tex(pos + (d * float(i))).x) * gaussian(float(i), s, 0.0);
		gn += gaussian(float(i), s, 0.0) * 2.0;
	}
	
	return g / gn;
}

vec4 hook() {
    return vec4(lumGaussian(HOOKED_pos, vec2(HOOKED_pt.x, 0)));
}

//!DESC Anime4K-v3.1-DarkLines-Kernel(Y)
//!HOOK NATIVE
//!BIND HOOKED
//!BIND MMKERNEL
//!SAVE MMKERNEL
//!COMPONENTS 1

#define L_tex MMKERNEL_tex

#define SIGMA 1.0

float gaussian(float x, float s, float m) {
	return (1.0 / (s * sqrt(2.0 * 3.14159))) * exp(-0.5 * pow(abs(x - m) / s, 2.0));
}

float lumGaussian(vec2 pos, vec2 d) {
	float s = SIGMA * HOOKED_size.y / 1080.0;
	float kernel_size = s * 2.0 + 1.0;
	
	float g = (L_tex(pos).x) * gaussian(0.0, s, 0.0);
	float gn = gaussian(0.0, s, 0.0);
	
	g += (L_tex(pos - d).x + L_tex(pos + d).x) * gaussian(1.0, s, 0.0);
	gn += gaussian(1.0, s, 0.0) * 2.0;
	
	for (int i=2; float(i)<kernel_size; i++) {
		g += (L_tex(pos - (d * float(i))).x + L_tex(pos + (d * float(i))).x) * gaussian(float(i), s, 0.0);
		gn += gaussian(float(i), s, 0.0) * 2.0;
	}
	
	return g / gn;
}

vec4 hook() {
    return vec4(min(HOOKED_tex(HOOKED_pos).x - lumGaussian(HOOKED_pos, vec2(0, HOOKED_pt.y)), 0.0));
}

//!DESC Anime4K-v3.1-DarkLines-Kernel(X)
//!HOOK NATIVE
//!BIND HOOKED
//!BIND MMKERNEL
//!SAVE MMKERNEL
//!COMPONENTS 1

#define L_tex MMKERNEL_tex

#define SIGMA 1.0

float gaussian(float x, float s, float m) {
	return (1.0 / (s * sqrt(2.0 * 3.14159))) * exp(-0.5 * pow(abs(x - m) / s, 2.0));
}

float lumGaussian(vec2 pos, vec2 d) {
	float s = SIGMA * HOOKED_size.y / 1080.0;
	float kernel_size = s * 2.0 + 1.0;
	
	float g = (L_tex(pos).x) * gaussian(0.0, s, 0.0);
	float gn = gaussian(0.0, s, 0.0);
	
	g += (L_tex(pos - d).x + L_tex(pos + d).x) * gaussian(1.0, s, 0.0);
	gn += gaussian(1.0, s, 0.0) * 2.0;
	
	for (int i=2; float(i)<kernel_size; i++) {
		g += (L_tex(pos - (d * float(i))).x + L_tex(pos + (d * float(i))).x) * gaussian(float(i), s, 0.0);
		gn += gaussian(float(i), s, 0.0) * 2.0;
	}
	
	return g / gn;
}

vec4 hook() {
    return vec4(lumGaussian(HOOKED_pos, vec2(HOOKED_pt.x, 0)));
}

//!DESC Anime4K-v3.1-DarkLines-Kernel(Y)
//!HOOK NATIVE
//!BIND HOOKED
//!BIND MMKERNEL
//!SAVE MMKERNEL
//!COMPONENTS 1

#define L_tex MMKERNEL_tex

#define SIGMA 1.0

float gaussian(float x, float s, float m) {
	return (1.0 / (s * sqrt(2.0 * 3.14159))) * exp(-0.5 * pow(abs(x - m) / s, 2.0));
}

float lumGaussian(vec2 pos, vec2 d) {
	float s = SIGMA * HOOKED_size.y / 1080.0;
	float kernel_size = s * 2.0 + 1.0;
	
	float g = (L_tex(pos).x) * gaussian(0.0, s, 0.0);
	float gn = gaussian(0.0, s, 0.0);
	
	g += (L_tex(pos - d).x + L_tex(pos + d).x) * gaussian(1.0, s, 0.0);
	gn += gaussian(1.0, s, 0.0) * 2.0;
	
	for (int i=2; float(i)<kernel_size; i++) {
		g += (L_tex(pos - (d * float(i))).x + L_tex(pos + (d * float(i))).x) * gaussian(float(i), s, 0.0);
		gn += gaussian(float(i), s, 0.0) * 2.0;
	}
	
	return g / gn;
}

vec4 hook() {
    return vec4(lumGaussian(HOOKED_pos, vec2(0, HOOKED_pt.y)));
}

//!DESC Anime4K-v3.1-DarkLines
//!HOOK NATIVE
//!BIND HOOKED
//!BIND MMKERNEL

#define STRENGTH 1.5 //Line darken proportional strength, higher is darker.
#define L_tex HOOKED_tex

vec4 hook() {
	float c = (MMKERNEL_tex(HOOKED_pos).x) * STRENGTH;
	return vec4(clamp(c + L_tex(HOOKED_pos).x, 0.0, L_tex(HOOKED_pos).x), HOOKED_tex(HOOKED_pos).yz, 0);
}



