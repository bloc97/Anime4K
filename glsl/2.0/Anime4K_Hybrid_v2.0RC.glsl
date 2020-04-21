//Anime4K Hybrid + CAS GLSL v2.0 Release Candidate

// MIT License

// Copyright (c) 2019-2020 bloc97, DextroseRe
// Copyright (c) 2017-2019 Advanced Micro Devices, Inc.
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



//!DESC Anime4K-Hybrid-CAS-v2.0RC
//!HOOK SCALED
//!BIND HOOKED


/* ---------------------- CAS SETTINGS ---------------------- */

//CAS Sharpness, initial sharpen filter strength (traditional sharpening)
#define SHARPNESS 1.0

/* --- MOST OF THE OTHER SETTINGS CAN BE FOUND AT THE END --- */


float lerp(float x, float y, float a) {
	return mix(x, y, a);
}

float saturate(float x) {
	return clamp(x, 0, 1);
}

float minf3(float x, float y, float z) {
	return min(x, min(y, z));
}

float maxf3(float x, float y, float z) {
	return max(x, max(y, z));
}

float rcp(float x) {
	if (x < 0.000001) {
		x = 0.000001;
	}
	return 1.0 / x;
}

vec4 hook() {	 
	// fetch a 3x3 neighborhood around the pixel 'e',
	//	a b c
	//	d(e)f
	//	g h i
	
	float pixelX = HOOKED_pt.x;
	float pixelY = HOOKED_pt.y;
	vec3 a = HOOKED_tex(HOOKED_pos + vec2(-pixelX, -pixelY)).rgb;
	vec3 b = HOOKED_tex(HOOKED_pos + vec2(0.0, -pixelY)).rgb;
	vec3 c = HOOKED_tex(HOOKED_pos + vec2(pixelX, -pixelY)).rgb;
	vec3 d = HOOKED_tex(HOOKED_pos + vec2(-pixelX, 0.0)).rgb;
	vec3 e = HOOKED_tex(HOOKED_pos).rgb;
	vec3 f = HOOKED_tex(HOOKED_pos + vec2(pixelX, 0.0)).rgb;
	vec3 g = HOOKED_tex(HOOKED_pos + vec2(-pixelX, pixelY)).rgb;
	vec3 h = HOOKED_tex(HOOKED_pos + vec2(0.0, pixelY)).rgb;
	vec3 i = HOOKED_tex(HOOKED_pos + vec2(pixelX, pixelY)).rgb;
  
	// Soft min and max.
	//	a b c			  b
	//	d e f * 0.5	 +	d e f * 0.5
	//	g h i			  h
	// These are 2.0x bigger (factored out the extra multiply).
	float mnR = minf3( minf3(d.r, e.r, f.r), b.r, h.r);
	float mnG = minf3( minf3(d.g, e.g, f.g), b.g, h.g);
	float mnB = minf3( minf3(d.b, e.b, f.b), b.b, h.b);
	
	float mnR2 = minf3( minf3(mnR, a.r, c.r), g.r, i.r);
	float mnG2 = minf3( minf3(mnG, a.g, c.g), g.g, i.g);
	float mnB2 = minf3( minf3(mnB, a.b, c.b), g.b, i.b);
	mnR = mnR + mnR2;
	mnG = mnG + mnG2;
	mnB = mnB + mnB2;
	
	float mxR = maxf3( maxf3(d.r, e.r, f.r), b.r, h.r);
	float mxG = maxf3( maxf3(d.g, e.g, f.g), b.g, h.g);
	float mxB = maxf3( maxf3(d.b, e.b, f.b), b.b, h.b);
	
	float mxR2 = maxf3( maxf3(mxR, a.r, c.r), g.r, i.r);
	float mxG2 = maxf3( maxf3(mxG, a.g, c.g), g.g, i.g);
	float mxB2 = maxf3( maxf3(mxB, a.b, c.b), g.b, i.b);
	mxR = mxR + mxR2;
	mxG = mxG + mxG2;
	mxB = mxB + mxB2;
	
	// Smooth minimum distance to signal limit divided by smooth max.
	float rcpMR = rcp(mxR);
	float rcpMG = rcp(mxG);
	float rcpMB = rcp(mxB);

	float ampR = saturate(min(mnR, 2.0 - mxR) * rcpMR);
	float ampG = saturate(min(mnG, 2.0 - mxG) * rcpMG);
	float ampB = saturate(min(mnB, 2.0 - mxB) * rcpMB);
	
	// Shaping amount of sharpening.
	ampR = sqrt(ampR);
	ampG = sqrt(ampG);
	ampB = sqrt(ampB);
	
	// Filter shape.
	//  0 w 0
	//  w 1 w
	//  0 w 0  
	float peak = -rcp(lerp(8.0, 5.0, saturate(SHARPNESS)));

	float wR = ampR * peak;
	float wG = ampG * peak;
	float wB = ampB * peak;

	float rcpWeightR = rcp(1.0 + 4.0 * wR);
	float rcpWeightG = rcp(1.0 + 4.0 * wG);
	float rcpWeightB = rcp(1.0 + 4.0 * wB);

	vec4 outColor = vec4(saturate((b.r*wR+d.r*wR+f.r*wR+h.r*wR+e.r)*rcpWeightR),
							saturate((b.g*wG+d.g*wG+f.g*wG+h.g*wG+e.g)*rcpWeightG),
							saturate((b.b*wB+d.b*wB+f.b*wB+h.b*wB+e.b)*rcpWeightB), 0);
	return outColor;
}



//!DESC Anime4K-Hybrid-ComputeGradientX-v2.0RC
//!HOOK SCALED
//!BIND HOOKED
//!WHEN OUTPUT.w LUMA.w / 1.200 > OUTPUT.h LUMA.h / 1.200 > *
//!SAVE LUMAD
//!COMPONENTS 2

float getLum(vec4 rgb) {
	return 0.299*rgb.r + 0.587*rgb.g + 0.114*rgb.b;
}

vec4 hook() {
	vec2 d = HOOKED_pt;
	
	//[tl  t tr]
	//[ l  c  r]
	//[bl  b br]
	float l = getLum(HOOKED_tex(HOOKED_pos + vec2(-d.x, 0)));
	float c = getLum(HOOKED_tex(HOOKED_pos));
	float r = getLum(HOOKED_tex(HOOKED_pos + vec2(d.x, 0)));
	
	
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


//!DESC Anime4K-Hybrid-ComputeGradientY-v2.0RC
//!HOOK SCALED
//!BIND HOOKED
//!BIND LUMAD
//!WHEN OUTPUT.w LUMA.w / 1.200 > OUTPUT.h LUMA.h / 1.200 > *
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
	float xgrad = (tx + cx + cx + bx);
	
	//Vertical Gradient
	//[-1 -2 -1]
	//[ 0  0  0]
	//[ 1  2  1]
	float ygrad = (-ty + by);
	
	//Computes the luminance's gradient
	return vec4(clamp(sqrt(xgrad * xgrad + ygrad * ygrad), 0, 1), 0, 0, 0);
}

//!DESC Anime4K-Hybrid-ComputeMinMaxX-v2.0RC
//!HOOK SCALED
//!BIND HOOKED
//!BIND LUMAD
//!WHEN OUTPUT.w LUMA.w / 1.200 > OUTPUT.h LUMA.h / 1.200 > *
//!SAVE LUMAMM
//!COMPONENTS 4

float max9(float a, float b, float c, float d, float e, float f, float g, float h, float i) {
	return max(max(max(max(a, b), max(c, d)), max(max(e, f), max(g, h))), i);
}
float min9(float a, float b, float c, float d, float e, float f, float g, float h, float i) {
	return min(min(min(min(a, b), min(c, d)), min(min(e, f), min(g, h))), i);
}

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
	
	float a0 = LUMAD_tex(HOOKED_pos + vec2(-d.x * 4, 0)).x;
	float b0 = LUMAD_tex(HOOKED_pos + vec2(-d.x * 3, 0)).x;
	float c0 = LUMAD_tex(HOOKED_pos + vec2(-d.x * 2, 0)).x;
	float d0 = LUMAD_tex(HOOKED_pos + vec2(-d.x * 1, 0)).x;
	float e0 = LUMAD_tex(HOOKED_pos).x;
	float f0 = LUMAD_tex(HOOKED_pos + vec2( d.x * 1, 0)).x;
	float g0 = LUMAD_tex(HOOKED_pos + vec2( d.x * 2, 0)).x;
	float h0 = LUMAD_tex(HOOKED_pos + vec2( d.x * 3, 0)).x;
	float i0 = LUMAD_tex(HOOKED_pos + vec2( d.x * 4, 0)).x;
	
	
	return vec4(xgrad, ygrad, max9(a0,b0,c0,d0,e0,f0,g0,h0,i0), min9(a0,b0,c0,d0,e0,f0,g0,h0,i0));
}


//!DESC Anime4K-Hybrid-ComputeMinMaxY-v2.0RC
//!HOOK SCALED
//!BIND HOOKED
//!BIND LUMAMM
//!WHEN OUTPUT.w LUMA.w / 1.200 > OUTPUT.h LUMA.h / 1.200 > *
//!SAVE LUMAMM
//!COMPONENTS 4

float max9(float a, float b, float c, float d, float e, float f, float g, float h, float i) {
	return max(max(max(max(a, b), max(c, d)), max(max(e, f), max(g, h))), i);
}
float min9(float a, float b, float c, float d, float e, float f, float g, float h, float i) {
	return min(min(min(min(a, b), min(c, d)), min(min(e, f), min(g, h))), i);
}

vec4 hook() {
	vec2 d = HOOKED_pt;
	
	//[tl  t tr]
	//[ l cc  r]
	//[bl  b br]
	float tx = LUMAMM_tex(HOOKED_pos + vec2(0, -d.y)).x;
	float cx = LUMAMM_tex(HOOKED_pos).x;
	float bx = LUMAMM_tex(HOOKED_pos + vec2(0, d.y)).x;
	
	
	float ty = LUMAMM_tex(HOOKED_pos + vec2(0, -d.y)).y;
	//float cy = LUMAMM_tex(HOOKED_pos).y;
	float by = LUMAMM_tex(HOOKED_pos + vec2(0, d.y)).y;
	
	
	//Horizontal Gradient
	//[-1  0  1]
	//[-2  0  2]
	//[-1  0  1]
	float xgrad = (tx + cx + cx + bx);
	
	//Vertical Gradient
	//[-1 -2 -1]
	//[ 0  0  0]
	//[ 1  2  1]
	float ygrad = (-ty + by);
	
	
	float a0 = LUMAMM_tex(HOOKED_pos + vec2(0, -d.y * 4)).z;
	float b0 = LUMAMM_tex(HOOKED_pos + vec2(0, -d.y * 3)).z;
	float c0 = LUMAMM_tex(HOOKED_pos + vec2(0, -d.y * 2)).z;
	float d0 = LUMAMM_tex(HOOKED_pos + vec2(0, -d.y * 1)).z;
	float e0 = LUMAMM_tex(HOOKED_pos).z;
	float f0 = LUMAMM_tex(HOOKED_pos + vec2(0,	d.y * 1)).z;
	float g0 = LUMAMM_tex(HOOKED_pos + vec2(0,	d.y * 2)).z;
	float h0 = LUMAMM_tex(HOOKED_pos + vec2(0,	d.y * 3)).z;
	float i0 = LUMAMM_tex(HOOKED_pos + vec2(0,	d.y * 4)).z;
	
	float a1 = LUMAMM_tex(HOOKED_pos + vec2(0, -d.y * 4)).w;
	float b1 = LUMAMM_tex(HOOKED_pos + vec2(0, -d.y * 3)).w;
	float c1 = LUMAMM_tex(HOOKED_pos + vec2(0, -d.y * 2)).w;
	float d1 = LUMAMM_tex(HOOKED_pos + vec2(0, -d.y * 1)).w;
	float e1 = LUMAMM_tex(HOOKED_pos).w;
	float f1 = LUMAMM_tex(HOOKED_pos + vec2(0,	d.y * 1)).w;
	float g1 = LUMAMM_tex(HOOKED_pos + vec2(0,	d.y * 2)).w;
	float h1 = LUMAMM_tex(HOOKED_pos + vec2(0,	d.y * 3)).w;
	float i1 = LUMAMM_tex(HOOKED_pos + vec2(0,	d.y * 4)).w;
	
	float norm = sqrt(xgrad * xgrad + ygrad * ygrad);
	if (norm <= 0.001) {
		xgrad = 0;
		ygrad = 0;
		norm = 1;
	}
	
	return vec4(xgrad/norm, ygrad/norm, max9(a0,b0,c0,d0,e0,f0,g0,h0,i0), min9(a1,b1,c1,d1,e1,f1,g1,h1,i1));
}


//!DESC Anime4K-Refine-v1.0RC2
//!HOOK SCALED
//!BIND HOOKED
//!BIND LUMA
//!BIND LUMAD
//!BIND LUMAMM
//!WHEN OUTPUT.w LUMA.w / 1.200 > OUTPUT.h LUMA.h / 1.200 > *


/* --------------------- SETTINGS --------------------- */

//Edge detection / derivative sensitivity values (higher = more sensitive) higher values will have the algorithm apply deblur on more blurry scenes
#define EDGE_DETECT_STRENGTH 2
#define DERIVATIVE_STRENGTH 4

//Strength of antialiasing, (higher = algorithm will not deblur edges as much), good values are between 0.3 and 2, also depending on DEBLUR_MEAN and DEBLUR_SIGMA
#define ANTIALIAS_STRENGTH 0.6


/* --- MODIFY THESE SETTINGS BELOW AT YOUR OWN RISK --- */

//An interactive version of this Gaussian curve used can be found on https://www.desmos.com/calculator/afqj2cgxag
//'s' is DEBLUR_SIGMA, 'm' is DEBLUR_MEAN and 'a' is ANTIALIAS_STRENGTH

//Mean of the gaussian curve used to determine which edges to deblur (higher = larger deblur on sharp edges, lower deblur on blurry edges)
#define DEBLUR_MEAN 0.4

//Variance of the gaussian curve used to determine which edges to deblur (higher = broader deblur filtering, will deblur very blurry edges and sharp edges alike, lower = will only deblur very specific edge types) 
#define DEBLUR_SIGMA 0.43

//Power curve used to ease in upscaling smaller than 2x upscaling factors.
#define UPSCALE_RATIO_HYSTERESIS 2

/* ----------------- END OF SETTINGS ----------------- */


float gaussian(float x, float s, float m, float a) {
	return (1 / (s * sqrt(2 * 3.14159))) * exp(-0.5 * pow((x - m) / s, 2.0)) / a;
}

vec4 hook() {
	vec2 d = HOOKED_pt;
	
	float upratio = clamp(SCALED_size.x / LUMA_size.x - 1, 0, 6);
	
	
	float lval = clamp(abs(LUMAMM_tex(HOOKED_pos).z - LUMAMM_tex(HOOKED_pos).w) * EDGE_DETECT_STRENGTH * upratio, 0, 1) * clamp(LUMAD_tex(HOOKED_pos).x * DERIVATIVE_STRENGTH * upratio, 0, 1);
	if (upratio < 1) {
		lval = lval * pow(upratio, UPSCALE_RATIO_HYSTERESIS);
	}
	
	float dx = LUMAMM_tex(HOOKED_pos).x;
	float dy = LUMAMM_tex(HOOKED_pos).y;
	float dval = lval * clamp(gaussian(lval, DEBLUR_SIGMA, DEBLUR_MEAN, ANTIALIAS_STRENGTH), 0, 1);
	
	
	float xpos = -sign(dx);
	float ypos = -sign(dy);
	
	vec4 xval = SCALED_tex(HOOKED_pos + vec2(d.x * xpos, 0));
	vec4 yval = SCALED_tex(HOOKED_pos + vec2(0, d.y * ypos));
	
	float xyratio = abs(dx) / (abs(dx) + abs(dy));
	if (dx + dy == 0) {
		xyratio = 0;
	}
	vec4 avg = xyratio * xval + (1-xyratio) * yval;
	
	return avg * dval + SCALED_tex(HOOKED_pos) * (1 - dval);
	
}

