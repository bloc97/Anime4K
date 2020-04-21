//Anime4K GLSL v1.0 Release Candidate

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


//!HOOK SCALED
//!BIND HOOKED
//!BIND POSTKERNEL
//!BIND NATIVE
//!DESC Anime4K-ThinLines-v1.0RC

float getLum(vec4 rgb) {
	return (rgb.r + rgb.r + rgb.g + rgb.g + rgb.g + rgb.b) / 6.0;
}

vec4 getLargest(vec4 cc, vec4 lightestColor, vec4 a, vec4 b, vec4 c) {
	float strength = min((SCALED_size.x) / (NATIVE_size.x) / 6.0, 1);
	vec4 newColor = cc * (1 - strength) + ((a + b + c) / 3.0) * strength;
	if (newColor.a > lightestColor.a) {
		return newColor;
	}
	return lightestColor;
}

vec4 getRGBL(vec2 pos) {
    return vec4(HOOKED_tex(pos).rgb, getLum(HOOKED_tex(pos)));
}

float min3v(vec4 a, vec4 b, vec4 c) {
	return min(min(a.a, b.a), c.a);
}
float max3v(vec4 a, vec4 b, vec4 c) {
	return max(max(a.a, b.a), c.a);
}


vec4 hook()  {
	vec2 d = HOOKED_pt;
	
    vec4 cc = getRGBL(HOOKED_pos);
	
	float scale = (SCALED_size.x) / (NATIVE_size.x);
	if (scale <= 1) {
		return cc; //Don't thin lines when there's no upscaling
	}
	
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



//!HOOK SCALED
//!BIND HOOKED
//!BIND POSTKERNEL
//!SAVE POSTKERNEL
//!DESC Anime4K-ComputeLuma-v1.0RC

float getLum(vec4 rgb) {
	return (rgb.r + rgb.r + rgb.g + rgb.g + rgb.g + rgb.b) / 6.0;
}

vec4 hook() { //Save lum on OUTPUT
	vec4 rgb = HOOKED_tex(HOOKED_pos);
	float lum = getLum(rgb);
    return vec4(lum);
}


//!HOOK SCALED
//!BIND HOOKED
//!BIND POSTKERNEL
//!SAVE POSTKERNEL
//!DESC Anime4K-ComputeGaussianX-v1.0RC

float lumGaussian7(vec2 pos, vec2 d) {
	float g = POSTKERNEL_tex(pos - (d * 3)).y * 0.121597;
	g = g + POSTKERNEL_tex(pos - (d * 2)).y * 0.142046;
	g = g + POSTKERNEL_tex(pos - d).y * 0.155931;
	g = g + POSTKERNEL_tex(pos).y * 0.160854;
	g = g + POSTKERNEL_tex(pos + d).y * 0.155931;
	g = g + POSTKERNEL_tex(pos + (d * 2)).y * 0.142046;
	g = g + POSTKERNEL_tex(pos + (d * 3)).y * 0.121597;
	
	return clamp(g, 0, 1); //Clamp for sanity check
}

vec4 hook() {
	float g = lumGaussian7(HOOKED_pos, vec2(HOOKED_pt.x, 0));
    return vec4(POSTKERNEL_tex(HOOKED_pos).x, g, POSTKERNEL_tex(HOOKED_pos).zw);
}


//!HOOK SCALED
//!BIND HOOKED
//!BIND POSTKERNEL
//!SAVE POSTKERNEL
//!DESC Anime4K-ComputeGaussianY

float lumGaussian7(vec2 pos, vec2 d) {
	float g = POSTKERNEL_tex(pos - (d * 3)).y * 0.121597;
	g = g + POSTKERNEL_tex(pos - (d * 2)).y * 0.142046;
	g = g + POSTKERNEL_tex(pos - d).y * 0.155931;
	g = g + POSTKERNEL_tex(pos).y * 0.160854;
	g = g + POSTKERNEL_tex(pos + d).y * 0.155931;
	g = g + POSTKERNEL_tex(pos + (d * 2)).y * 0.142046;
	g = g + POSTKERNEL_tex(pos + (d * 3)).y * 0.121597;
	
	return clamp(g, 0, 1); //Clamp for sanity check
}

vec4 hook() {
	float g = lumGaussian7(HOOKED_pos, vec2(0, HOOKED_pt.y));
    return vec4(POSTKERNEL_tex(HOOKED_pos).x, g, POSTKERNEL_tex(HOOKED_pos).zw);
}

//!HOOK SCALED
//!BIND HOOKED
//!BIND POSTKERNEL
//!SAVE POSTKERNEL
//!DESC Anime4K-LineDetect-v1.0RC

#define BlendColorDodgef(base, blend) 	(((blend) == 1.0) ? (blend) : min((base) / (1.0 - (blend)), 1.0))
#define BlendColorDividef(top, bottom) 	(((bottom) == 1.0) ? (bottom) : min((top) / (bottom), 1.0))

// Component wise blending
#define Blend(base, blend, funcf) 		vec3(funcf(base.r, blend.r), funcf(base.g, blend.g), funcf(base.b, blend.b))
#define BlendColorDodge(base, blend) 	Blend(base, blend, BlendColorDodgef)


vec4 hook() {
	float lum = clamp(POSTKERNEL_tex(HOOKED_pos).x, 0.001, 0.999);
	float lumg = clamp(POSTKERNEL_tex(HOOKED_pos).y, 0.001, 0.999);

	vec4 rgb = HOOKED_tex(HOOKED_pos);
	
	float pseudolines = BlendColorDividef(lum, lumg);
	pseudolines = 1 - clamp(pseudolines - 0.05, 0, 1);
	//float gradlines = abs(lum - lumg);
	
	//float lines = clamp(pseudolines - gradlines, 0, 1);
	//float linesDiv = 1 - clamp((1 - pseudolines) / (1 - gradlines), 0, 1);
	
    return vec4(lum, pseudolines, 0, 0);
}



//!HOOK SCALED
//!BIND HOOKED
//!BIND POSTKERNEL
//!SAVE POSTKERNEL
//!DESC Anime4K-ComputeLineGaussianX-v1.0RC

float lumGaussian7(vec2 pos, vec2 d) {
	float g = POSTKERNEL_tex(pos - (d * 3)).y * 0.121597;
	g = g + POSTKERNEL_tex(pos - (d * 2)).y * 0.142046;
	g = g + POSTKERNEL_tex(pos - d).y * 0.155931;
	g = g + POSTKERNEL_tex(pos).y * 0.160854;
	g = g + POSTKERNEL_tex(pos + d).y * 0.155931;
	g = g + POSTKERNEL_tex(pos + (d * 2)).y * 0.142046;
	g = g + POSTKERNEL_tex(pos + (d * 3)).y * 0.121597;
	
	return clamp(g, 0, 1); //Clamp for sanity check
}

vec4 hook() {
	float g = lumGaussian7(HOOKED_pos, vec2(HOOKED_pt.x, 0));
    return vec4(POSTKERNEL_tex(HOOKED_pos).x, g, POSTKERNEL_tex(HOOKED_pos).zw);
}


//!HOOK SCALED
//!BIND HOOKED
//!BIND POSTKERNEL
//!SAVE POSTKERNEL
//!DESC Anime4K-ComputeLineGaussianY-v1.0RC

float lumGaussian7(vec2 pos, vec2 d) {
	float g = POSTKERNEL_tex(pos - (d * 3)).y * 0.121597;
	g = g + POSTKERNEL_tex(pos - (d * 2)).y * 0.142046;
	g = g + POSTKERNEL_tex(pos - d).y * 0.155931;
	g = g + POSTKERNEL_tex(pos).y * 0.160854;
	g = g + POSTKERNEL_tex(pos + d).y * 0.155931;
	g = g + POSTKERNEL_tex(pos + (d * 2)).y * 0.142046;
	g = g + POSTKERNEL_tex(pos + (d * 3)).y * 0.121597;
	
	return clamp(g, 0, 1); //Clamp for sanity check
}

vec4 hook() {
	float g = lumGaussian7(HOOKED_pos, vec2(0, HOOKED_pt.y));
    return vec4(POSTKERNEL_tex(HOOKED_pos).x, g, POSTKERNEL_tex(HOOKED_pos).zw);
}


//!HOOK SCALED
//!BIND HOOKED
//!BIND POSTKERNEL
//!SAVE POSTKERNEL
//!DESC Anime4K-ComputeGradient-v1.0RC

vec4 getRGBL(vec2 pos) {
    return vec4(HOOKED_tex(pos).rgb, POSTKERNEL_tex(pos).x);
}

float getLum(vec4 rgb) {
	return (rgb.r + rgb.r + rgb.g + rgb.g + rgb.g + rgb.b) / 6.0;
}

vec4 hook() { //Save grad on OUTPUT
	vec2 d = HOOKED_pt;
	
	//[tl  t tr]
	//[ l cc  r]
	//[bl  b br]
    vec4 cc = getRGBL(HOOKED_pos);
	vec4 t = getRGBL(HOOKED_pos + vec2(0, -d.y));
	vec4 tl = getRGBL(HOOKED_pos + vec2(-d.x, -d.y));
	vec4 tr = getRGBL(HOOKED_pos + vec2(d.x, -d.y));
	
	vec4 l = getRGBL(HOOKED_pos + vec2(-d.x, 0));
	vec4 r = getRGBL(HOOKED_pos + vec2(d.x, 0));
	
	vec4 b = getRGBL(HOOKED_pos + vec2(0, d.y));
	vec4 bl = getRGBL(HOOKED_pos + vec2(-d.x, d.y));
	vec4 br = getRGBL(HOOKED_pos + vec2(d.x, d.y));
	
	
	//Horizontal Gradient
	//[-1  0  1]
	//[-2  0  2]
	//[-1  0  1]
	float xgrad = (-tl.a + tr.a - l.a - l.a + r.a + r.a - bl.a + br.a);
	
	//Vertical Gradient
	//[-1 -2 -1]
	//[ 0  0  0]
	//[ 1  2  1]
	float ygrad = (-tl.a - t.a - t.a - tr.a + bl.a + b.a + b.a + br.a);
	
	//Computes the luminance's gradient
	return vec4(POSTKERNEL_tex(HOOKED_pos).xy, 1 - clamp(sqrt(xgrad * xgrad + ygrad * ygrad), 0, 1), 0);
}


//!HOOK SCALED
//!BIND HOOKED
//!BIND POSTKERNEL
//!BIND NATIVE
//!DESC Anime4K-Refine-v1.0RC

#define LINE_DETECT_MUL 8
#define LINE_DETECT_THRESHOLD 0.2

#define strength (min((SCALED_size.x) / (NATIVE_size.x), 1))
#define lineprob (POSTKERNEL_tex(HOOKED_pos).y)

vec4 getAverage(vec4 cc, vec4 a, vec4 b, vec4 c) {
	float prob = clamp(lineprob * LINE_DETECT_MUL, 0, 1);
	if (prob < LINE_DETECT_THRESHOLD) {
		prob = 0;
	}
	float realstrength = clamp(strength * prob, 0, 1);
	return cc * (1 - realstrength) + ((a + b + c) / 3) * realstrength;
}

vec4 getRGBL(vec2 pos) {
    return vec4(HOOKED_tex(pos).rgb, POSTKERNEL_tex(pos).z);
}

float min3v(vec4 a, vec4 b, vec4 c) {
	return min(min(a.a, b.a), c.a);
}
float max3v(vec4 a, vec4 b, vec4 c) {
	return max(max(a.a, b.a), c.a);
}


vec4 hook()  {
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

//!HOOK SCALED
//!BIND HOOKED
//!BIND POSTKERNEL
//!BIND NATIVE
//!DESC Anime4K-PostFXAA-v1.0RC

#define FXAA_MIN (1.0 / 128.0)
#define FXAA_MUL (1.0 / 8.0)
#define FXAA_SPAN 8.0

#define LINE_DETECT_MUL 4
#define LINE_DETECT_THRESHOLD 0.2

#define strength (min((SCALED_size.x) / (NATIVE_size.x), 1))
#define lineprob (POSTKERNEL_tex(HOOKED_pos).y)

vec4 getAverage(vec4 cc, vec4 xc) {
	float prob = clamp(lineprob * LINE_DETECT_MUL, 0, 1);
	if (prob < LINE_DETECT_THRESHOLD) {
		prob = 0;
	}
	float realstrength = clamp(strength * prob, 0, 1);
	return cc * (1 - realstrength) + xc * realstrength;
}

float getLum(vec4 rgb) {
	return (rgb.r + rgb.r + rgb.g + rgb.g + rgb.g + rgb.b) / 6.0;
}

vec4 hook()  {
	vec2 d = HOOKED_pt;
	
	
    vec4 cc = HOOKED_tex(HOOKED_pos);
    vec4 xc = cc;
	
	float t = POSTKERNEL_tex(HOOKED_pos + vec2(0, -d.y)).x;
	float l = POSTKERNEL_tex(HOOKED_pos + vec2(-d.x, 0)).x;
	float r = POSTKERNEL_tex(HOOKED_pos + vec2(d.x, 0)).x;
	float b = POSTKERNEL_tex(HOOKED_pos + vec2(0, d.y)).x;
	
    float tl = POSTKERNEL_tex(HOOKED_pos + vec2(-d.x, -d.y)).x;
    float tr = POSTKERNEL_tex(HOOKED_pos + vec2(d.x, -d.y)).x;
    float bl = POSTKERNEL_tex(HOOKED_pos + vec2(-d.x, d.y)).x;
    float br = POSTKERNEL_tex(HOOKED_pos + vec2(d.x, d.y)).x;
    float cl  = POSTKERNEL_tex(HOOKED_pos).x;
	
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

    //vec4 luma = vec4(0.299, 0.587, 0.114, 0);
    //float lumb = dot(rgbB, luma);
    float lumb = getLum(rgbB);
	
    if ((lumb < minl) || (lumb > maxl)) {
        xc = rgbA;
    } else {
        xc = rgbB;
	}
    return getAverage(cc, xc);
}

