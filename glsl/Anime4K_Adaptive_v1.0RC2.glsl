//Anime4K GLSL v1.0 Release Candidate 2

// MIT License

// Copyright (c) 2019 bloc97, DextroseRe

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

//!DESC Anime4K-Luma-v1.0RC2
//!WHEN OUTPUT.w LUMA.w / 1.400 > OUTPUT.h LUMA.h / 1.400 > *
//!HOOK LUMA
//!BIND HOOKED
//!WIDTH OUTPUT.w
//!HEIGHT OUTPUT.h
//!SAVE LUMAX
//!COMPONENTS 1

vec4 hook() {
	return HOOKED_tex(HOOKED_pos);
}

//!DESC Anime4K-ComputeGaussianX-v1.0RC2
//!WHEN OUTPUT.w LUMA.w / 1.400 > OUTPUT.h LUMA.h / 1.400 > *
//!HOOK LUMA
//!BIND HOOKED
//!BIND LUMAX
//!SAVE LUMAG
//!COMPONENTS 1

float lumGaussian7(vec2 pos, vec2 d) {
	float g = LUMA_tex(pos - (d * 3)).x * 0.121597;
	g = g + LUMA_tex(pos - (d * 2)).x * 0.142046;
	g = g + LUMA_tex(pos - d).x * 0.155931;
	g = g + LUMA_tex(pos).x * 0.160854;
	g = g + LUMA_tex(pos + d).x * 0.155931;
	g = g + LUMA_tex(pos + (d * 2)).x * 0.142046;
	g = g + LUMA_tex(pos + (d * 3)).x * 0.121597;
	
	return clamp(g, 0, 1); //Clamp for sanity check
}

vec4 hook() {
	float g = lumGaussian7(HOOKED_pos, vec2(LUMAX_pt.x, 0));
    return vec4(g, 0, 0, 0);
}



//!DESC Anime4K-ComputeGaussianY-v1.0RC2
//!WHEN OUTPUT.w LUMA.w / 1.400 > OUTPUT.h LUMA.h / 1.400 > *
//!HOOK LUMA
//!BIND HOOKED
//!BIND LUMAX
//!BIND LUMAG
//!SAVE LUMAG
//!COMPONENTS 1

float lumGaussian7(vec2 pos, vec2 d) {
	float g = LUMAG_tex(pos - (d * 3)).x * 0.121597;
	g = g + LUMAG_tex(pos - (d * 2)).x * 0.142046;
	g = g + LUMAG_tex(pos - d).x * 0.155931;
	g = g + LUMAG_tex(pos).x * 0.160854;
	g = g + LUMAG_tex(pos + d).x * 0.155931;
	g = g + LUMAG_tex(pos + (d * 2)).x * 0.142046;
	g = g + LUMAG_tex(pos + (d * 3)).x * 0.121597;
	
	return clamp(g, 0, 1); //Clamp for sanity check
}

vec4 hook() {
	float g = lumGaussian7(HOOKED_pos, vec2(0, LUMAX_pt.y));
    return vec4(g, 0, 0, 0);
}


//!DESC Anime4K-LineDetect-v1.0RC2
//!WHEN OUTPUT.w LUMA.w / 1.400 > OUTPUT.h LUMA.h / 1.400 > *
//!HOOK LUMA
//!BIND HOOKED
//!BIND LUMAG
//!SAVE LUMAG
//!COMPONENTS 1

#define BlendColorDodgef(base, blend) 	(((blend) == 1.0) ? (blend) : min((base) / (1.0 - (blend)), 1.0))
#define BlendColorDividef(top, bottom) 	(((bottom) == 1.0) ? (bottom) : min((top) / (bottom), 1.0))

// Component wise blending
#define Blend(base, blend, funcf) 		vec3(funcf(base.r, blend.r), funcf(base.g, blend.g), funcf(base.b, blend.b))
#define BlendColorDodge(base, blend) 	Blend(base, blend, BlendColorDodgef)


vec4 hook() {
	float lum = clamp(LUMA_tex(HOOKED_pos).x, 0.001, 0.999);
	float lumg = clamp(LUMAG_tex(HOOKED_pos).x, 0.001, 0.999);
	
	float pseudolines = BlendColorDividef(lum, lumg);
	pseudolines = 1 - clamp(pseudolines - 0.05, 0, 1);
	
    return vec4(pseudolines, 0, 0, 0);
}



//!DESC Anime4K-ComputeLineGaussianX-v1.0RC2
//!WHEN OUTPUT.w LUMA.w / 1.400 > OUTPUT.h LUMA.h / 1.400 > *
//!HOOK LUMA
//!BIND HOOKED
//!BIND LUMAX
//!BIND LUMAG
//!SAVE LUMAG
//!COMPONENTS 1

float lumGaussian7(vec2 pos, vec2 d) {
	float g = LUMAG_tex(pos - (d * 3)).x * 0.121597;
	g = g + LUMAG_tex(pos - (d * 2)).x * 0.142046;
	g = g + LUMAG_tex(pos - d).x * 0.155931;
	g = g + LUMAG_tex(pos).x * 0.160854;
	g = g + LUMAG_tex(pos + d).x * 0.155931;
	g = g + LUMAG_tex(pos + (d * 2)).x * 0.142046;
	g = g + LUMAG_tex(pos + (d * 3)).x * 0.121597;
	
	return clamp(g, 0, 1); //Clamp for sanity check
}

vec4 hook() {
	float g = lumGaussian7(HOOKED_pos, vec2(LUMAX_pt.x, 0));
    return vec4(g, 0, 0, 0);
}



//!DESC Anime4K-ComputeLineGaussianY-v1.0RC2
//!WHEN OUTPUT.w LUMA.w / 1.400 > OUTPUT.h LUMA.h / 1.400 > *
//!HOOK LUMA
//!BIND HOOKED
//!BIND LUMAX
//!BIND LUMAG
//!SAVE LUMAG
//!COMPONENTS 1

float lumGaussian7(vec2 pos, vec2 d) {
	float g = LUMAG_tex(pos - (d * 3)).x * 0.121597;
	g = g + LUMAG_tex(pos - (d * 2)).x * 0.142046;
	g = g + LUMAG_tex(pos - d).x * 0.155931;
	g = g + LUMAG_tex(pos).x * 0.160854;
	g = g + LUMAG_tex(pos + d).x * 0.155931;
	g = g + LUMAG_tex(pos + (d * 2)).x * 0.142046;
	g = g + LUMAG_tex(pos + (d * 3)).x * 0.121597;
	
	return clamp(g, 0, 1); //Clamp for sanity check
}

vec4 hook() {
	float g = lumGaussian7(HOOKED_pos, vec2(0, LUMAX_pt.y));
    return vec4(g, 0, 0, 0);
}


//!DESC Anime4K-ComputeGradientX-v1.0RC2
//!WHEN OUTPUT.w LUMA.w / 1.400 > OUTPUT.h LUMA.h / 1.400 > *
//!HOOK LUMA
//!BIND HOOKED
//!BIND LUMAX
//!SAVE LUMAD
//!COMPONENTS 2

vec4 hook() {
	vec2 d = LUMAX_pt;
	
	//[tl  t tr]
	//[ l  c  r]
	//[bl  b br]
	float l = LUMA_tex(HOOKED_pos + vec2(-d.x, 0)).x;
    float c = LUMA_tex(HOOKED_pos).x;
	float r = LUMA_tex(HOOKED_pos + vec2(d.x, 0)).x;
	
	
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


//!DESC Anime4K-ComputeGradientY-v1.0RC2
//!HOOK LUMA
//!BIND HOOKED
//!BIND LUMAX
//!WHEN OUTPUT.w LUMA.w / 1.400 > OUTPUT.h LUMA.h / 1.400 > *
//!BIND LUMAD
//!SAVE LUMAD
//!COMPONENTS 1

vec4 hook() {
	vec2 d = LUMAX_pt;
	
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
	return vec4(1 - clamp(sqrt(xgrad * xgrad + ygrad * ygrad), 0, 1), 0, 0, 0);
}


//!DESC Anime4K-ThinLines-v1.0RC2
//!HOOK SCALED
//!BIND HOOKED
//!BIND LUMA
//!WHEN OUTPUT.w LUMA.w / 1.400 > OUTPUT.h LUMA.h / 1.400 > *
//!BIND LUMAG

#define LINE_DETECT_THRESHOLD 0.06

#define lineprob (LUMAG_tex(HOOKED_pos).x)

float getLum(vec4 rgb) {
	return (rgb.r + rgb.r + rgb.g + rgb.g + rgb.g + rgb.b) / 6.0;
}

vec4 getLargest(vec4 cc, vec4 lightestColor, vec4 a, vec4 b, vec4 c) {
	float strength = min((SCALED_size.x) / (LUMA_size.x) / 6.0, 1);
	vec4 newColor = cc * (1 - strength) + ((a + b + c) / 3.0) * strength;
	if (newColor.a > lightestColor.a) {
		return newColor;
	}
	return lightestColor;
}

vec4 getRGBL(vec2 pos) {
    return vec4(HOOKED_tex(pos).rgb, LUMA_tex(pos).x);
}

float min3v(vec4 a, vec4 b, vec4 c) {
	return min(min(a.a, b.a), c.a);
}
float max3v(vec4 a, vec4 b, vec4 c) {
	return max(max(a.a, b.a), c.a);
}


vec4 hook()  {

	if (lineprob < LINE_DETECT_THRESHOLD) {
		return HOOKED_tex(HOOKED_pos);
	}

	vec2 d = HOOKED_pt;
	
    vec4 cc = getRGBL(HOOKED_pos);
	
	
	vec4 t = getRGBL(HOOKED_pos + vec2(0, -d.y));
	vec4 tl = getRGBL(HOOKED_pos + vec2(-d.x, -d.y));
	vec4 tr = getRGBL(HOOKED_pos + vec2(d.x, -d.y));
	
	vec4 l = getRGBL(HOOKED_pos + vec2(-d.x, 0));
	vec4 r = getRGBL(HOOKED_pos + vec2(d.x, 0));
	
	vec4 b = getRGBL(HOOKED_pos + vec2(0, d.y));
	vec4 bl = getRGBL(HOOKED_pos + vec2(-d.x, d.y));
	vec4 br = getRGBL(HOOKED_pos + vec2(d.x, d.y));
	
	vec4 lightestColor = cc;

	//Kernel 0 and 4
	float maxDark = max3v(br, b, bl);
	float minLight = min3v(tl, t, tr);
	
	if (minLight > cc.a && minLight > maxDark) {
		lightestColor = getLargest(cc, lightestColor, tl, t, tr);
	} else {
		maxDark = max3v(tl, t, tr);
		minLight = min3v(br, b, bl);
		if (minLight > cc.a && minLight > maxDark) {
			lightestColor = getLargest(cc, lightestColor, br, b, bl);
		}
	}
	
	//Kernel 1 and 5
	maxDark = max3v(cc, l, b);
	minLight = min3v(r, t, tr);
	
	if (minLight > maxDark) {
		lightestColor = getLargest(cc, lightestColor, r, t, tr);
	} else {
		maxDark = max3v(cc, r, t);
		minLight = min3v(bl, l, b);
		if (minLight > maxDark) {
			lightestColor = getLargest(cc, lightestColor, bl, l, b);
		}
	}
	
	//Kernel 2 and 6
	maxDark = max3v(l, tl, bl);
	minLight = min3v(r, br, tr);
	
	if (minLight > cc.a && minLight > maxDark) {
		lightestColor = getLargest(cc, lightestColor, r, br, tr);
	} else {
		maxDark = max3v(r, br, tr);
		minLight = min3v(l, tl, bl);
		if (minLight > cc.a && minLight > maxDark) {
			lightestColor = getLargest(cc, lightestColor, l, tl, bl);
		}
	}
	
	//Kernel 3 and 7
	maxDark = max3v(cc, l, t);
	minLight = min3v(r, br, b);
	
	if (minLight > maxDark) {
		lightestColor = getLargest(cc, lightestColor, r, br, b);
	} else {
		maxDark = max3v(cc, r, b);
		minLight = min3v(t, l, tl);
		if (minLight > maxDark) {
			lightestColor = getLargest(cc, lightestColor, t, l, tl);
		}
	}
	
	
	return lightestColor;
}


//!DESC Anime4K-Refine-v1.0RC2
//!HOOK SCALED
//!BIND HOOKED
//!WHEN OUTPUT.w LUMA.w / 1.400 > OUTPUT.h LUMA.h / 1.400 > *
//!BIND LUMA
//!BIND LUMAD
//!BIND LUMAG

#define LINE_DETECT_MUL 6
#define LINE_DETECT_THRESHOLD 0.06
#define MAX_STRENGTH 1

#define strength (min((SCALED_size.x) / (LUMA_size.x), 1))
#define lineprob (LUMAG_tex(HOOKED_pos).x)

vec4 getAverage(vec4 cc, vec4 a, vec4 b, vec4 c) {
	float realstrength = clamp(strength * lineprob * LINE_DETECT_MUL, 0, MAX_STRENGTH);
	return cc * (1 - realstrength) + ((a + b + c) / 3) * realstrength;
}

vec4 getRGBL(vec2 pos) {
    return vec4(HOOKED_tex(pos).rgb, LUMAD_tex(pos).x);
}

float min3v(vec4 a, vec4 b, vec4 c) {
	return min(min(a.a, b.a), c.a);
}
float max3v(vec4 a, vec4 b, vec4 c) {
	return max(max(a.a, b.a), c.a);
}


vec4 hook()  {

	if (lineprob < LINE_DETECT_THRESHOLD) {
		return HOOKED_tex(HOOKED_pos);
	}

	vec2 d = HOOKED_pt;
	
    vec4 cc = getRGBL(HOOKED_pos);
	vec4 t = getRGBL(HOOKED_pos + vec2(0, -d.y));
	vec4 tl = getRGBL(HOOKED_pos + vec2(-d.x, -d.y));
	vec4 tr = getRGBL(HOOKED_pos + vec2(d.x, -d.y));
	
	vec4 l = getRGBL(HOOKED_pos + vec2(-d.x, 0));
	vec4 r = getRGBL(HOOKED_pos + vec2(d.x, 0));
	
	vec4 b = getRGBL(HOOKED_pos + vec2(0, d.y));
	vec4 bl = getRGBL(HOOKED_pos + vec2(-d.x, d.y));
	vec4 br = getRGBL(HOOKED_pos + vec2(d.x, d.y));
	
	//Kernel 0 and 4
	float maxDark = max3v(br, b, bl);
	float minLight = min3v(tl, t, tr);
	
	if (minLight > cc.a && minLight > maxDark) {
		return getAverage(cc, tl, t, tr);
	} else {
		maxDark = max3v(tl, t, tr);
		minLight = min3v(br, b, bl);
		if (minLight > cc.a && minLight > maxDark) {
			return getAverage(cc, br, b, bl);
		}
	}
	
	//Kernel 1 and 5
	maxDark = max3v(cc, l, b);
	minLight = min3v(r, t, tr);
	
	if (minLight > maxDark) {
		return getAverage(cc, r, t, tr);
	} else {
		maxDark = max3v(cc, r, t);
		minLight = min3v(bl, l, b);
		if (minLight > maxDark) {
			return getAverage(cc, bl, l, b);
		}
	}
	
	//Kernel 2 and 6
	maxDark = max3v(l, tl, bl);
	minLight = min3v(r, br, tr);
	
	if (minLight > cc.a && minLight > maxDark) {
		return getAverage(cc, r, br, tr);
	} else {
		maxDark = max3v(r, br, tr);
		minLight = min3v(l, tl, bl);
		if (minLight > cc.a && minLight > maxDark) {
			return getAverage(cc, l, tl, bl);
		}
	}
	
	//Kernel 3 and 7
	maxDark = max3v(cc, l, t);
	minLight = min3v(r, br, b);
	
	if (minLight > maxDark) {
		return getAverage(cc, r, br, b);
	} else {
		maxDark = max3v(cc, r, b);
		minLight = min3v(t, l, tl);
		if (minLight > maxDark) {
			return getAverage(cc, t, l, tl);
		}
	}
	
	
	return cc;
}


//Fast FXAA (1 Iteration) courtesy of Geeks3D
//https://www.geeks3d.com/20110405/fxaa-fast-approximate-anti-aliasing-demo-glsl-opengl-test-radeon-geforce/3/

//!DESC Anime4K-PostFXAA-v1.0RC2
//!HOOK SCALED
//!BIND HOOKED
//!WHEN OUTPUT.w LUMA.w / 1.400 > OUTPUT.h LUMA.h / 1.400 > *
//!BIND LUMA
//!BIND LUMAG

#define FXAA_MIN (1.0 / 128.0)
#define FXAA_MUL (1.0 / 8.0)
#define FXAA_SPAN 8.0

#define LINE_DETECT_MUL 6
#define LINE_DETECT_THRESHOLD 0.06

#define strength (min((SCALED_size.x) / (LUMA_size.x), 1))
#define lineprob (LUMAG_tex(HOOKED_pos).x)

vec4 getAverage(vec4 cc, vec4 xc) {
	float prob = clamp(lineprob, 0, 1);
	if (prob < LINE_DETECT_THRESHOLD) {
		prob = 0;
	}
	float realstrength = clamp(strength * prob * LINE_DETECT_MUL, 0, 1);
	return cc * (1 - realstrength) + xc * realstrength;
}

float getLum(vec4 rgb) {
	return (rgb.r + rgb.r + rgb.g + rgb.g + rgb.g + rgb.b) / 6;
}

vec4 hook()  {

	if (lineprob < LINE_DETECT_THRESHOLD) {
		return HOOKED_tex(HOOKED_pos);
	}


	vec2 d = HOOKED_pt;
	
	
    vec4 cc = HOOKED_tex(HOOKED_pos);
    vec4 xc = cc;
	
	float t = HOOKED_tex(HOOKED_pos + vec2(0, -d.y)).x;
	float l = HOOKED_tex(HOOKED_pos + vec2(-d.x, 0)).x;
	float r = HOOKED_tex(HOOKED_pos + vec2(d.x, 0)).x;
	float b = HOOKED_tex(HOOKED_pos + vec2(0, d.y)).x;
	
    float tl = HOOKED_tex(HOOKED_pos + vec2(-d.x, -d.y)).x;
    float tr = HOOKED_tex(HOOKED_pos + vec2(d.x, -d.y)).x;
    float bl = HOOKED_tex(HOOKED_pos + vec2(-d.x, d.y)).x;
    float br = HOOKED_tex(HOOKED_pos + vec2(d.x, d.y)).x;
    float cl  = HOOKED_tex(HOOKED_pos).x;
	
    float minl = min(cl, min(min(tl, tr), min(bl, br)));
    float maxl = max(cl, max(max(tl, tr), max(bl, br)));
    
    vec2 dir = vec2(- tl - tr + bl + br, tl - tr + bl - br);
    
    float dirReduce = max((tl + tr + bl + br) *
                          (0.25 * FXAA_MUL), FXAA_MIN);
    
    float rcpDirMin = 1.0 / (min(abs(dir.x), abs(dir.y)) + dirReduce);
    dir = min(vec2(FXAA_SPAN, FXAA_SPAN),
              max(vec2(-FXAA_SPAN, -FXAA_SPAN),
              dir * rcpDirMin)) * d;
    
    vec4 rgbA = 0.5 * (
        HOOKED_tex(HOOKED_pos + dir * -(1.0/6.0)) +
        HOOKED_tex(HOOKED_pos + dir * (1.0/6.0)));
    vec4 rgbB = rgbA * 0.5 + 0.25 * (
        HOOKED_tex(HOOKED_pos + dir * -0.5) +
        HOOKED_tex(HOOKED_pos + dir * 0.5));

		
    float lumb = getLum(rgbB);
	
    if ((lumb < minl) || (lumb > maxl)) {
        xc = rgbA;
    } else {
        xc = rgbB;
	}
    return getAverage(cc, xc);
}