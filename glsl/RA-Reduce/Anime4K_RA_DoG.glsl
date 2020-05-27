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

//!DESC Anime4K-v3.1-RA-DoG-Downsample
//!HOOK NATIVE
//!BIND HOOKED
//!SAVE BACKUP

vec4 hook() {
	return HOOKED_tex(HOOKED_pos);
}

//!DESC Anime4K-v3.1-RA-DoG-Downsample
//!HOOK NATIVE
//!BIND HOOKED
//!WIDTH NATIVE.w 2 /
//!HEIGHT NATIVE.h 2 /

vec4 hook() {
	return HOOKED_tex(HOOKED_pos);
}

//!DESC Anime4K-v3.1-RA-DoG-Kernel(X)
//!HOOK NATIVE
//!BIND HOOKED
//!SAVE GAUSS_X2
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


//!DESC Anime4K-v3.1-RA-DoG-Kernel(Y)
//!HOOK NATIVE
//!BIND HOOKED
//!BIND GAUSS_X2
//!SAVE GAUSS_X2
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
	float g = (L_tex(pos - (d + d)).x + L_tex(pos + (d + d)).x) * 0.06136;
	g = g + (L_tex(pos - d).x + L_tex(pos + d).x) * 0.24477;
	g = g + (L_tex(pos).x) * 0.38774;
	
	return g;
}


vec4 hook() {
    return vec4(lumGaussian7(HOOKED_pos, vec2(0, HOOKED_pt.y)), minmax3(HOOKED_pos, vec2(0, HOOKED_pt.y)), 0);
}

//!DESC Anime4K-v3.1-RA-DoG
//!HOOK NATIVE
//!BIND HOOKED
//!BIND GAUSS_X2
//!WIDTH BACKUP.w
//!HEIGHT BACKUP.h
//!COMPONENTS 3
//!SAVE RESID

#define STRENGTH 0.8 //De-blur proportional strength, higher is sharper.

#define L_tex HOOKED_tex

vec4 hook() {
	float c = (L_tex(HOOKED_pos).x - GAUSS_X2_tex(HOOKED_pos).x) * STRENGTH;
	return vec4(clamp(c + L_tex(HOOKED_pos).x, GAUSS_X2_tex(HOOKED_pos).y, GAUSS_X2_tex(HOOKED_pos).z) - L_tex(HOOKED_pos).x);
}


//!DESC Anime4K-v3.1-RA-DoG-Resample
//!HOOK NATIVE
//!BIND HOOKED
//!BIND BACKUP
//!BIND RESID
//!WIDTH BACKUP.w
//!HEIGHT BACKUP.h

#define STRENGTH 1 //Strength of artifact reduction, high values might blur some edges.

vec4 hook() {
	float alpha = clamp(abs(RESID_tex(HOOKED_pos).x) * 20 * STRENGTH, 0, 1);
	float u = HOOKED_tex(HOOKED_pos).x + RESID_tex(HOOKED_pos).x;
	float o = BACKUP_tex(HOOKED_pos).x;
	
	return vec4(u * alpha + o * (1 - alpha), BACKUP_tex(HOOKED_pos).yz, 0);
}


