//Anime4K Hybrid + CAS GLSL v2.0 Release Candidate 2 Fast Version

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


//!DESC Anime4K-Hybrid-CAS-v2.0RC2-Fast
//!HOOK LUMA
//!BIND HOOKED


/* ---------------------- CAS SETTINGS ---------------------- */

//CAS Sharpness, initial sharpen filter strength (traditional sharpening)
#define SHARPNESS 0.4

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
    //  a b c
    //  d(e)f
    //  g h i
	
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
	//  a b c             b
	//  d e f * 0.5  +  d e f * 0.5
	//  g h i             h
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
   float peak = -rcp(lerp(8.0, 5.0, saturate(SHARPNESS)));
   
   float wR = ampR * peak;
   
   float rcpWeightR = rcp(1.0 + 4.0 * wR);
   
   vec4 outColor = vec4(saturate((b*wR+d*wR+f*wR+h*wR+e)*rcpWeightR), 0, 0, 0);
   return outColor;
}

//!DESC Anime4K-Hybrid-ComputeGradientX-v2.0RC2-Fast
//!HOOK LUMA
//!BIND HOOKED
//!WHEN OUTPUT.w LUMA.w / 1.200 > OUTPUT.h LUMA.h / 1.200 > *
//!SAVE LUMAD
//!COMPONENTS 2

vec4 hook() {
	vec2 d = HOOKED_pt;
	
	//[tl  t tr]
	//[ l  c  r]
	//[bl  b br]
	float l = HOOKED_tex(HOOKED_pos + vec2(-d.x, 0)).x;
    float c = HOOKED_tex(HOOKED_pos).x;
	float r = HOOKED_tex(HOOKED_pos + vec2(d.x, 0)).x;
	
	
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


//!DESC Anime4K-Hybrid-ComputeGradientY-v2.0RC2-Fast
//!HOOK LUMA
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
	float xgrad = (tx + cx + cx + bx) / 4;
	
	//Vertical Gradient
	//[-1 -2 -1]
	//[ 0  0  0]
	//[ 1  2  1]
	float ygrad = (-ty + by) / 4;
	
	//Computes the luminance's gradient
	return vec4(clamp(sqrt(xgrad * xgrad + ygrad * ygrad), 0, 1), 0, 0, 0);
}




//!DESC Anime4K-Hybrid-ComputeSecondGradientX-v2.0RC2-Fast
//!HOOK SCALED
//!BIND HOOKED
//!BIND LUMAD
//!WHEN OUTPUT.w LUMA.w / 1.200 > OUTPUT.h LUMA.h / 1.200 > *
//!SAVE LUMADD
//!COMPONENTS 2

vec4 hook() {
	vec2 d = HOOKED_pt;
	
    float c = LUMAD_tex(HOOKED_pos).x;
	
	if (c < 0.2) {
		return vec4(0);
	}
	
	//[tl  t tr]
	//[ l  c  r]
	//[bl  b br]
	float l = LUMAD_tex(HOOKED_pos + vec2(-d.x, 0)).x;
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


//!DESC Anime4K-Hybrid-ComputeSecondGradientY-v2.0RC2-Fast
//!HOOK SCALED
//!BIND HOOKED
//!BIND LUMAD
//!BIND LUMADD
//!WHEN OUTPUT.w LUMA.w / 1.200 > OUTPUT.h LUMA.h / 1.200 > *
//!SAVE LUMADD
//!COMPONENTS 2

vec4 hook() {
	vec2 d = HOOKED_pt;
	
	if (LUMAD_tex(HOOKED_pos).x < 0.2) {
		return vec4(0);
	}
	
	//[tl  t tr]
	//[ l cc  r]
	//[bl  b br]
	vec4 t = LUMADD_tex(HOOKED_pos + vec2(0, -d.y));
    float c = LUMADD_tex(HOOKED_pos).x;
	vec4 b = LUMADD_tex(HOOKED_pos + vec2(0, d.y));
	
	
	//Horizontal Gradient
	//[-1  0  1]
	//[-2  0  2]
	//[-1  0  1]
	float xgrad = (t.x + c + c + b.x);
	
	//Vertical Gradient
	//[-1 -2 -1]
	//[ 0  0  0]
	//[ 1  2  1]
	float ygrad = (-t.y + b.y);
	
	
	return vec4(xgrad, ygrad, 0, 0);
}


//!DESC Anime4K-Refine-v1.0RC2-Fast
//!HOOK SCALED
//!BIND HOOKED
//!BIND LUMA
//!BIND LUMAD
//!BIND LUMADD
//!WHEN OUTPUT.w LUMA.w / 1.200 > OUTPUT.h LUMA.h / 1.200 > *


/* --------------------- SETTINGS --------------------- */

//Edge detection / derivative sensitivity values (higher = more sensitive) higher values will have the algorithm apply deblur on more blurry scenes
#define DERIVATIVE_STRENGTH 2

//Strength of antialiasing, (higher = algorithm will not deblur edges as much), good values are between 0.3 and 2, also depending on DEBLUR_MEAN and DEBLUR_SIGMA
#define ANTIALIAS_STRENGTH 1.2


/* --- MODIFY THESE SETTINGS BELOW AT YOUR OWN RISK --- */

//An interactive version of this Gaussian curve used can be found on https://www.desmos.com/calculator/afqj2cgxag
//'s' is DEBLUR_SIGMA, 'm' is DEBLUR_MEAN and 'a' is ANTIALIAS_STRENGTH

//Mean of the gaussian curve used to determine which edges to deblur (higher = larger deblur on sharp edges, lower deblur on blurry edges)
#define DEBLUR_MEAN 0.3

//Variance of the gaussian curve used to determine which edges to deblur (higher = broader deblur filtering, will deblur very blurry edges and sharp edges alike, lower = will only deblur very specific edge types) 
#define DEBLUR_SIGMA 0.3

//Power curve used to ease in upscaling smaller than 2x upscaling factors.
#define UPSCALE_RATIO_HYSTERESIS 2

/* ----------------- END OF SETTINGS ----------------- */


float gaussian(float x, float s, float m, float a) {
	return (1 / (s * sqrt(2 * 3.14159))) * exp(-0.5 * pow((x - m) / s, 2.0)) / a;
}

vec4 hook() {
	vec2 d = HOOKED_pt;
	
	float dx = LUMADD_tex(HOOKED_pos).x;
	float dy = LUMADD_tex(HOOKED_pos).y;
	
	if (abs(dx + dy) <= 0.0001) {
		return SCALED_tex(HOOKED_pos);
	}
	
	
	float upratio = clamp(SCALED_size.x / LUMA_size.x - 1, 0, 6);
	
	
	float lval = clamp(LUMAD_tex(HOOKED_pos).x * DERIVATIVE_STRENGTH * upratio, 0, 1);
	if (upratio < 1) {
		lval = lval * pow(upratio, UPSCALE_RATIO_HYSTERESIS);
	}
	
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

