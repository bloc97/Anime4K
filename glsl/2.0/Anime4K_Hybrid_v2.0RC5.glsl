//Anime4K Hybrid + CAS GLSL v2.0 Release Candidate 5

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


//!DESC Anime4K-Hybrid-CAS-v2.0RC5
//!HOOK LUMA
//!BIND HOOKED


/* ---------------------- CAS SETTINGS ---------------------- */

//CAS Sharpness, initial sharpen filter strength (traditional sharpening)
#define SHARPNESS 0.5

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
	float sharpval = clamp(LUMA_size.x / 3840, 0, 1) * SHARPNESS;
	
	// fetch a 3x3 neighborhood around the pixel 'e',
	//	a b c
	//	d(e)f
	//	g h i
	
	float pixelX = HOOKED_pt.x;
	float pixelY = HOOKED_pt.y;
	float a = HOOKED_tex(HOOKED_pos + vec2(-pixelX, -pixelY)).x;
	float b = HOOKED_tex(HOOKED_pos + vec2(0.0, -pixelY)).x;
	float c = HOOKED_tex(HOOKED_pos + vec2(pixelX, -pixelY)).x;
	float d = HOOKED_tex(HOOKED_pos + vec2(-pixelX, 0.0)).x;
	float e = HOOKED_tex(HOOKED_pos).x;
	float f = HOOKED_tex(HOOKED_pos + vec2(pixelX, 0.0)).x;
	float g = HOOKED_tex(HOOKED_pos + vec2(-pixelX, pixelY)).x;
	float h = HOOKED_tex(HOOKED_pos + vec2(0.0, pixelY)).x;
	float i = HOOKED_tex(HOOKED_pos + vec2(pixelX, pixelY)).x;
  
	// Soft min and max.
	//	a b c			  b
	//	d e f * 0.5	 +	d e f * 0.5
	//	g h i			  h
	// These are 2.0x bigger (factored out the extra multiply).
	
	float mnR = minf3( minf3(d, e, f), b, h);
	
	float mnR2 = minf3( minf3(mnR, a, c), g, i);
	mnR = mnR + mnR2;
	
	float mxR = maxf3( maxf3(d, e, f), b, h);
	
	float mxR2 = maxf3( maxf3(mxR, a, c), g, i);
	mxR = mxR + mxR2;
	
	// Smooth minimum distance to signal limit divided by smooth max.
	float rcpMR = rcp(mxR);

	float ampR = saturate(min(mnR, 2.0 - mxR) * rcpMR);
	
	// Shaping amount of sharpening.
	ampR = sqrt(ampR);
	
	// Filter shape.
	//  0 w 0
	//  w 1 w
	//  0 w 0  
	float peak = -rcp(lerp(8.0, 5.0, saturate(sharpval)));

	float wR = ampR * peak;

	float rcpWeightR = rcp(1.0 + 4.0 * wR);

	vec4 outColor = vec4(saturate((b*wR+d*wR+f*wR+h*wR+e)*rcpWeightR), 0, 0, 0);
	return outColor;
}


//!DESC Anime4K-Hybrid-Bilateral-v2.0RC5
//!HOOK NATIVE
//!BIND HOOKED

/* ---------------------- BILATERAL MODE FILTERING SETTINGS ---------------------- */

#define STRENGTH 0.1
#define SPREAD_STRENGTH 2.0
#define MODE_REGULARIZATION 20.0

/* --- MOST OF THE OTHER SETTINGS CAN BE FOUND AT THE END --- */

#define KERNELSIZE 3
#define KERNELHALFSIZE 1
#define KERNELLEN 9

#define GETOFFSET(i) vec2((i % KERNELSIZE) - KERNELHALFSIZE, (i / KERNELSIZE) - KERNELHALFSIZE)


float gaussian(float x, float s, float m) {
	return (1 / (s * sqrt(2 * 3.14159))) * exp(-0.5 * pow(abs(x - m) / s, 2.0));
}


vec4 getMean(vec4 histogram_v[KERNELLEN], float histogram_w[KERNELLEN]) {
	vec4 valsum = vec4(0);
	float normsum = 0.000001; //Avoid divide by zero
	
	for (int i=0; i<KERNELLEN; i++) {
		valsum += histogram_v[i] * histogram_w[i];
		normsum += histogram_w[i];
	}
	
	return valsum / normsum;
}


vec4 getMode(vec4 histogram_v[KERNELLEN], float histogram_w[KERNELLEN]) {
	vec4 maxv = vec4(0);
	float maxw = 0;
	
	for (int i=0; i<KERNELLEN; i++) {
		if (histogram_w[i] > maxw) {
			maxw = histogram_w[i];
			maxv = histogram_v[i];
		}
	}
	
	return maxv;
}

vec4 hook() {
	vec2 d = HOOKED_pt;
	
	float sharpval = clamp(HOOKED_size.x / 1920, 0, 1);
	
	
	vec4 histogram_v[KERNELLEN];
	float histogram_w[KERNELLEN];
	float histogram_wn[KERNELLEN];
	
	float vc = HOOKED_tex(HOOKED_pos).x;
	
	float s = vc * STRENGTH + 0.0001;
	float ss = SPREAD_STRENGTH * sharpval + 0.0001;
	
	
	for (int i=0; i<KERNELLEN; i++) {
		vec2 ipos = GETOFFSET(i);
		histogram_v[i] = HOOKED_tex(HOOKED_pos + ipos * d);
		histogram_w[i] = gaussian(vc - histogram_v[i].x, s, 0) * gaussian(distance(vec2(0), ipos), ss, 0);
		histogram_wn[i] = 0;
	}
	
	float sr = MODE_REGULARIZATION / 255.0;
	
	
	for (int i=0; i<KERNELLEN; i++) {
		for (int j=0; j<KERNELLEN; j++) {
			histogram_wn[j] += gaussian(histogram_v[j].x, sr, histogram_v[i].x) * histogram_w[i];
		}
	}
	
	
	return vec4(getMode(histogram_v, histogram_wn).x, getMean(histogram_v, histogram_wn).yz, 0);
}




//!DESC Anime4K-Hybrid-ComputeGradientX-v2.0RC5
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


//!DESC Anime4K-Hybrid-ComputeGradientY-v2.0RC5
//!HOOK SCALED
//!BIND HOOKED
//!BIND LUMA
//!BIND LUMAD
//!WHEN OUTPUT.w LUMA.w / 1.200 > OUTPUT.h LUMA.h / 1.200 > *
//!SAVE LUMAD
//!COMPONENTS 2


/* --------------------- SETTINGS --------------------- */

//Strength of edge refinement, good values are between 0.2 and 4
#define REFINE_STRENGTH 1


/* --- MODIFY THESE SETTINGS BELOW AT YOUR OWN RISK --- */

//Bias of the refinement function, good values are between 0 and 1
#define REFINE_BIAS 0

//Polynomial fit obtained by minimizing MSE error on image
#define P5 ( 11.68129591)
#define P4 (-42.46906057)
#define P3 ( 60.28286266)
#define P2 (-41.84451327)
#define P1 ( 14.05517353)
#define P0 (-1.081521930)

//Power curve used to ease in upscaling smaller than 2x upscaling factors.
#define UPSCALE_RATIO_HYSTERESIS 1

/* ----------------- END OF SETTINGS ----------------- */

float power_function(float x) {
	float x2 = x * x;
	float x3 = x2 * x;
	float x4 = x2 * x2;
	float x5 = x2 * x3;
	
	return P5*x5 + P4*x4 + P3*x3 + P2*x2 + P1*x + P0;
}

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
	float sobel_norm = clamp(sqrt(xgrad * xgrad + ygrad * ygrad), 0, 1);
	
	float upratio = clamp(SCALED_size.x / LUMA_size.x - 1, 0, 6);
	
	float dval = clamp(power_function(clamp(sobel_norm * max(pow(upratio, UPSCALE_RATIO_HYSTERESIS), 1), 0, 1)) * REFINE_STRENGTH + REFINE_BIAS, 0, 1);
	
	if (upratio < 1) {
		dval = dval * pow(upratio, UPSCALE_RATIO_HYSTERESIS);
	}
	
	return vec4(sobel_norm, dval, 0, 0);
}

//!DESC Anime4K-Hybrid-ComputeSecondGradientX-v2.0RC5
//!HOOK SCALED
//!BIND HOOKED
//!BIND LUMAD
//!WHEN OUTPUT.w LUMA.w / 1.200 > OUTPUT.h LUMA.h / 1.200 > *
//!SAVE LUMAMM
//!COMPONENTS 2


vec4 hook() {
	vec2 d = HOOKED_pt;
	
	if (LUMAD_tex(HOOKED_pos).y < 0.1) {
		return vec4(0);
	}
	
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
	
	
	return vec4(xgrad, ygrad, 0, 0);
}


//!DESC Anime4K-Hybrid-ComputeSecondGradientY-v2.0RC5
//!HOOK SCALED
//!BIND HOOKED
//!BIND LUMAD
//!BIND LUMAMM
//!WHEN OUTPUT.w LUMA.w / 1.200 > OUTPUT.h LUMA.h / 1.200 > *
//!SAVE LUMAMM
//!COMPONENTS 2

vec4 hook() {
	vec2 d = HOOKED_pt;
	
	if (LUMAD_tex(HOOKED_pos).y < 0.1) {
		return vec4(0);
	}
	
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
	
	float norm = sqrt(xgrad * xgrad + ygrad * ygrad);
	if (norm <= 0.001) {
		xgrad = 0;
		ygrad = 0;
		norm = 1;
	}
	
	return vec4(xgrad/norm, ygrad/norm, 0, 0);
}


//!DESC Anime4K-Hybrid-Refine-v2.0RC5
//!HOOK SCALED
//!BIND HOOKED
//!BIND LUMA
//!BIND LUMAD
//!BIND LUMAMM
//!WHEN OUTPUT.w LUMA.w / 1.200 > OUTPUT.h LUMA.h / 1.200 > *


vec4 hook() {
	vec2 d = HOOKED_pt;
	
	float dval = LUMAD_tex(HOOKED_pos).y;
	if (dval < 0.1) {
		return SCALED_tex(HOOKED_pos);
	}
	
	vec4 dc = LUMAMM_tex(HOOKED_pos);
	if (abs(dc.x + dc.y) <= 0.0001) {
		return SCALED_tex(HOOKED_pos);
	}
	
	float xpos = -sign(dc.x);
	float ypos = -sign(dc.y);
	
	vec4 xval = SCALED_tex(HOOKED_pos + vec2(d.x * xpos, 0));
	vec4 yval = SCALED_tex(HOOKED_pos + vec2(0, d.y * ypos));
	
	float xyratio = abs(dc.x) / (abs(dc.x) + abs(dc.y));
	
	vec4 avg = xyratio * xval + (1-xyratio) * yval;
	
	return avg * dval + SCALED_tex(HOOKED_pos) * (1 - dval);
	
}

