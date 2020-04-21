//Anime4K v3.0 GLSL

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

//!HOOK NATIVE
//!BIND HOOKED
//!SAVE GAUSS_X2
//!DESC Anime4K-v3.0-Upscale(x2)-DoG-Kernel(X)
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
	float g = (L_tex(pos - (d * 2)).x + L_tex(pos + (d * 2)).x) * 0.06136;
	g = g + (L_tex(pos - (d * 1)).x + L_tex(pos + (d * 1)).x) * 0.24477;
	g = g + (L_tex(pos).x) * 0.38774;
	
	return clamp(g, 0, 1); //Clamp for sanity check
}


vec4 hook() {
    return vec4(lumGaussian7(HOOKED_pos, vec2(HOOKED_pt.x, 0)), minmax3(HOOKED_pos, vec2(HOOKED_pt.x, 0)), 0);
}


//!HOOK NATIVE
//!BIND HOOKED
//!BIND GAUSS_X2
//!SAVE GAUSS_X2
//!DESC Anime4K-v3.0-Upscale(x2)-DoG-Kernel(Y)
//!COMPONENTS 3

#define L_tex GAUSS_X2_tex

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
	float g = (L_tex(pos - (d * 2)).x + L_tex(pos + (d * 2)).x) * 0.06136;
	g = g + (L_tex(pos - (d * 1)).x + L_tex(pos + (d * 1)).x) * 0.24477;
	g = g + (L_tex(pos).x) * 0.38774;
	
	return clamp(g, 0, 1); //Clamp for sanity check
}


vec4 hook() {
    return vec4(lumGaussian7(HOOKED_pos, vec2(0, HOOKED_pt.y)), minmax3(HOOKED_pos, vec2(0, HOOKED_pt.y)), 0);
}


//!HOOK NATIVE
//!BIND HOOKED
//!BIND GAUSS_X2
//!WIDTH NATIVE.w 2 *
//!HEIGHT NATIVE.h 2 *
//!DESC Anime4K-v3.0-Upscale(x2)-DoG

#define L_tex HOOKED_tex

vec4 hook() {
	float c = L_tex(HOOKED_pos).x + L_tex(HOOKED_pos).x - GAUSS_X2_tex(HOOKED_pos).x;
	return vec4(clamp(c, GAUSS_X2_tex(HOOKED_pos).y, GAUSS_X2_tex(HOOKED_pos).z), HOOKED_tex(HOOKED_pos).yz, 0);
}



